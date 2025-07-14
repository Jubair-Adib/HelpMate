from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.models.user import User
from app.models.worker import Worker
from app.models.category import Category
from app.models.order import Order
from app.schemas.category import CategoryCreate, CategoryResponse
from app.routers.auth import get_current_user
from app.models.service import Service

router = APIRouter(prefix="/admin", tags=["admin"])

def admin_required(current_user: User = Depends(get_current_user)):
    if not getattr(current_user, "is_admin", False):
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Admin access required")
    return current_user

# Add Category
@router.post("/categories", response_model=CategoryResponse)
def add_category(
    category: CategoryCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(admin_required),
):
    db_category = Category(
        name=category.name,
        description=category.description,
        icon=category.icon,
        color=category.color,
        is_active=True,
    )
    db.add(db_category)
    db.commit()
    db.refresh(db_category)
    return db_category

# Activate/Deactivate User
@router.put("/users/{user_id}/activate")
def activate_user(user_id: int, active: bool, db: Session = Depends(get_db), current_user: User = Depends(admin_required)):
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    user.is_active = active
    db.commit()
    return {"success": True, "user_id": user_id, "is_active": user.is_active}

# Activate/Deactivate Worker
@router.put("/workers/{worker_id}/activate")
def activate_worker(worker_id: int, active: bool, db: Session = Depends(get_db), current_user: User = Depends(admin_required)):
    worker = db.query(Worker).filter(Worker.id == worker_id).first()
    if not worker:
        raise HTTPException(status_code=404, detail="Worker not found")
    worker.is_active = active
    db.commit()
    return {"success": True, "worker_id": worker_id, "is_active": worker.is_active}

# Change Order Status
@router.put("/orders/{order_id}/status")
def change_order_status(order_id: int, status: str, db: Session = Depends(get_db), current_user: User = Depends(admin_required)):
    order = db.query(Order).filter(Order.id == order_id).first()
    if not order:
        raise HTTPException(status_code=404, detail="Order not found")
    if status not in ["pending", "completed", "cancelled"]:
        raise HTTPException(status_code=400, detail="Invalid status")
    order.status = status
    db.commit()
    return {"success": True, "order_id": order_id, "status": order.status}

# List all users
@router.get("/users")
def list_users(db: Session = Depends(get_db), current_user: User = Depends(admin_required)):
    users = db.query(User).all()
    return users

# List all workers
@router.get("/workers")
def list_workers(db: Session = Depends(get_db), current_user: User = Depends(admin_required)):
    workers = db.query(Worker).all()
    return workers

# List all orders
@router.get("/orders")
def list_orders(db: Session = Depends(get_db), current_user: User = Depends(admin_required)):
    orders = db.query(Order).order_by(Order.created_at.desc()).all()
    result = []
    for order in orders:
        user = db.query(User).filter(User.id == order.user_id).first()
        worker = db.query(Worker).filter(Worker.id == order.worker_id).first()
        service = db.query(Service).filter(Service.id == order.service_id).first()
        order_dict = order.__dict__.copy()
        # Remove SQLAlchemy state
        order_dict.pop('_sa_instance_state', None)
        order_dict['user'] = {
            'id': user.id,
            'full_name': user.full_name,
            'email': user.email
        } if user else None
        order_dict['worker'] = {
            'id': worker.id,
            'full_name': worker.full_name,
            'email': worker.email
        } if worker else None
        order_dict['service'] = {
            'id': service.id,
            'title': service.title,
            'description': service.description,
            'hourly_rate': service.hourly_rate
        } if service else None
        result.append(order_dict)
    return result

# List all categories
@router.get("/categories")
def list_categories(db: Session = Depends(get_db), current_user: User = Depends(admin_required)):
    categories = db.query(Category).all()
    return categories 