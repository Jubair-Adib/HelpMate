from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List
from app.core.database import get_db
from app.models.order import Order, Review
from app.models.user import User
from app.schemas.order import OrderCreate, OrderUpdate, OrderResponse, ReviewCreate, ReviewResponse
from app.routers.auth import get_current_user

router = APIRouter(prefix="/orders", tags=["orders"])


@router.post("/", response_model=OrderResponse)
async def create_order(
    order: OrderCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Create a new order (only users can create orders)"""
    # Verify the user is creating the order
    if not isinstance(current_user, User):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only users can create orders"
        )
    
    # Check if the service exists and is available
    from app.models.service import Service
    service = db.query(Service).filter(Service.id == order.service_id).first()
    if not service:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Service not found"
        )
    
    if not service.is_available:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Service is not available"
        )
    
    # Calculate total amount
    total_amount = service.hourly_rate * order.hours
    
    # Create order
    db_order = Order(
        user_id=current_user.id,
        worker_id=service.worker_id,
        service_id=order.service_id,
        description=order.description,
        hours=order.hours,
        total_amount=total_amount,
        scheduled_date=order.scheduled_date
    )
    db.add(db_order)
    db.commit()
    db.refresh(db_order)
    return db_order


@router.get("/", response_model=List[OrderResponse])
async def get_orders(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Get all orders for the current user"""
    if not isinstance(current_user, User):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only users can access this endpoint"
        )
    
    orders = db.query(Order).filter(Order.user_id == current_user.id).all()
    return orders


@router.get("/{order_id}", response_model=OrderResponse)
async def get_order(
    order_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Get a specific order by ID"""
    if not isinstance(current_user, User):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only users can access this endpoint"
        )
    
    order = db.query(Order).filter(
        Order.id == order_id,
        Order.user_id == current_user.id
    ).first()
    
    if not order:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Order not found"
        )
    
    return order


@router.put("/{order_id}", response_model=OrderResponse)
async def update_order(
    order_id: int,
    order_update: OrderUpdate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Update an order (only the order owner can update)"""
    if not isinstance(current_user, User):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only users can update orders"
        )
    
    db_order = db.query(Order).filter(
        Order.id == order_id,
        Order.user_id == current_user.id
    ).first()
    
    if not db_order:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Order not found or you don't have permission to update it"
        )
    
    # Update order fields
    for field, value in order_update.dict(exclude_unset=True).items():
        setattr(db_order, field, value)
    
    db.commit()
    db.refresh(db_order)
    return db_order


@router.delete("/{order_id}")
async def cancel_order(
    order_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Cancel an order (only the order owner can cancel)"""
    if not isinstance(current_user, User):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only users can cancel orders"
        )
    
    db_order = db.query(Order).filter(
        Order.id == order_id,
        Order.user_id == current_user.id
    ).first()
    
    if not db_order:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Order not found or you don't have permission to cancel it"
        )
    
    if db_order.status in ["completed", "cancelled"]:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Cannot cancel a completed or already cancelled order"
        )
    
    db_order.status = "cancelled"
    db.commit()
    return {"message": "Order cancelled successfully"}


# Reviews
@router.post("/{order_id}/review", response_model=ReviewResponse)
async def create_review(
    order_id: int,
    review: ReviewCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Create a review for an order (only users can create reviews)"""
    if not isinstance(current_user, User):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only users can create reviews"
        )
    
    # Check if order exists and belongs to the user
    order = db.query(Order).filter(
        Order.id == order_id,
        Order.user_id == current_user.id
    ).first()
    
    if not order:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Order not found"
        )
    
    if order.status != "completed":
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Can only review completed orders"
        )
    
    # Check if review already exists
    existing_review = db.query(Review).filter(Review.order_id == order_id).first()
    if existing_review:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Review already exists for this order"
        )
    
    # Validate rating
    if review.rating < 1 or review.rating > 5:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Rating must be between 1 and 5"
        )
    
    # Create review
    db_review = Review(
        user_id=current_user.id,
        worker_id=order.worker_id,
        order_id=order_id,
        rating=review.rating,
        comment=review.comment
    )
    db.add(db_review)
    
    # Update worker's rating
    from app.models.worker import Worker
    worker = db.query(Worker).filter(Worker.id == order.worker_id).first()
    if worker:
        # Calculate new average rating
        total_reviews = worker.total_reviews + 1
        new_rating = ((worker.rating * worker.total_reviews) + review.rating) / total_reviews
        worker.rating = new_rating
        worker.total_reviews = total_reviews
    
    db.commit()
    db.refresh(db_review)
    return db_review


@router.get("/{order_id}/review", response_model=ReviewResponse)
async def get_review(
    order_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Get review for a specific order"""
    if not isinstance(current_user, User):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only users can access this endpoint"
        )
    
    review = db.query(Review).filter(
        Review.order_id == order_id,
        Review.user_id == current_user.id
    ).first()
    
    if not review:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Review not found"
        )
    
    return review 