from fastapi import APIRouter, Depends, HTTPException, status, Request, UploadFile, File
from sqlalchemy.orm import Session
from typing import List
from app.core.database import get_db
from app.models.worker import Worker, WorkerOrder
from app.models.order import Review
from app.schemas.worker import (
    WorkerUpdate, WorkProfileUpdate, WorkerResponse, 
    WorkerOrderCreate, WorkerOrderResponse
)
from app.schemas.order import ReviewResponse
from app.routers.auth import get_current_user
from app.services.worker_service import WorkerService
from sqlalchemy.orm import joinedload
import os

router = APIRouter(prefix="/workers", tags=["workers"])


def get_public_image_url(image_path: str, request: Request) -> str:
    if not image_path:
        return None
    if image_path.startswith("http://") or image_path.startswith("https://"):
        return image_path
    if image_path.startswith("/static/"):
        return f"{request.url.scheme}://{request.url.netloc}{image_path}"
    filename = os.path.basename(image_path)
    return f"{request.url.scheme}://{request.url.netloc}/static/{filename}"


@router.get("/profile", response_model=WorkerResponse)
async def get_worker_profile(request: Request, current_worker: Worker = Depends(get_current_user)):
    """Get current worker's profile"""
    worker_dict = current_worker.__dict__.copy()
    worker_dict["image"] = get_public_image_url(current_worker.image, request) if current_worker.image else None
    return worker_dict


@router.put("/profile", response_model=WorkerResponse)
async def update_worker_profile(
    worker_update: WorkerUpdate,
    request: Request,
    current_worker: Worker = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Update worker's basic profile"""
    for field, value in worker_update.dict(exclude_unset=True).items():
        setattr(current_worker, field, value)
    
    db.commit()
    db.refresh(current_worker)
    worker_dict = current_worker.__dict__.copy()
    worker_dict["image"] = get_public_image_url(current_worker.image, request) if current_worker.image else None
    return worker_dict


@router.put("/work-profile", response_model=WorkerResponse)
async def update_work_profile(
    work_profile: WorkProfileUpdate,
    current_worker: Worker = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Update worker's work profile"""
    old_skills = current_worker.skills
    
    for field, value in work_profile.dict(exclude_unset=True).items():
        setattr(current_worker, field, value)
    
    # If skills were updated, update services as well
    if 'skills' in work_profile.dict(exclude_unset=True) and work_profile.skills != old_skills:
        WorkerService.update_worker_services(db, current_worker.id, work_profile.skills or [])
    
    db.commit()
    db.refresh(current_worker)
    return current_worker


@router.post("/upload-profile-image")
async def upload_worker_profile_image(request: Request, file: UploadFile = File(...)):
    """Upload a profile image for the worker. Returns the public URL."""
    static_dir = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), '..', 'static')
    os.makedirs(static_dir, exist_ok=True)
    file_ext = os.path.splitext(file.filename)[1]
    filename = f"worker_{os.urandom(8).hex()}{file_ext}"
    file_path = os.path.join(static_dir, filename)
    with open(file_path, "wb") as f:
        content = await file.read()
        f.write(content)
    public_url = f"{request.url.scheme}://{request.url.netloc}/static/{filename}"
    return {"url": public_url}


@router.get("/", response_model=List[WorkerResponse])
def get_workers(
    category_id: int = None,
    available_only: bool = True,
    db: Session = Depends(get_db)
):
    """Get all workers with optional filtering"""
    query = db.query(Worker).filter(Worker.is_active == True)
    
    if available_only:
        query = query.filter(Worker.is_available == True)
    
    if category_id:
        # Filter by category through services
        from app.models.service import Service
        query = query.join(Service, Worker.id == Service.worker_id).filter(Service.category_id == category_id)
    
    workers = query.all()
    return workers


@router.get("/{worker_id}", response_model=WorkerResponse)
def get_worker(worker_id: int, db: Session = Depends(get_db)):
    """Get a specific worker by ID"""
    worker = db.query(Worker).filter(Worker.id == worker_id).first()
    if not worker:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Worker not found"
        )
    return worker


# Worker Orders (workers ordering services from other workers)
@router.post("/orders", response_model=WorkerOrderResponse)
async def create_worker_order(
    order: WorkerOrderCreate,
    current_worker: Worker = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Create a new order for a worker"""
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
    
    # Create worker order
    db_order = WorkerOrder(
        worker_id=current_worker.id,
        service_id=order.service_id,
        description=order.description,
        scheduled_date=order.scheduled_date
    )
    db.add(db_order)
    db.commit()
    db.refresh(db_order)
    return db_order


@router.get("/orders", response_model=List[WorkerOrderResponse])
async def get_worker_orders(
    current_worker: Worker = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Get all orders placed by the current worker"""
    orders = db.query(WorkerOrder).filter(WorkerOrder.worker_id == current_worker.id).all()
    return orders


@router.put("/orders/{order_id}", response_model=WorkerOrderResponse)
async def update_worker_order(
    order_id: int,
    status: str,
    current_worker: Worker = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Update worker order status"""
    order = db.query(WorkerOrder).filter(
        WorkerOrder.id == order_id,
        WorkerOrder.worker_id == current_worker.id
    ).first()
    
    if not order:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Order not found"
        )
    
    valid_statuses = ["pending", "accepted", "completed", "cancelled"]
    if status not in valid_statuses:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Invalid status. Must be one of: {valid_statuses}"
        )
    
    order.status = status
    db.commit()
    db.refresh(order)
    return order


@router.get("/{worker_id}/reviews", response_model=List[ReviewResponse])
def get_worker_reviews(worker_id: int, db: Session = Depends(get_db)):
    """Get all reviews for a specific worker"""
    # Check if worker exists
    worker = db.query(Worker).filter(Worker.id == worker_id).first()
    if not worker:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Worker not found"
        )
    
    reviews = db.query(Review).options(
        joinedload(Review.user)
    ).filter(Review.worker_id == worker_id).all()
    return reviews 