from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session, joinedload
from typing import List
from app.core.database import get_db
from app.models.user import User, UserFavorite
from app.models.worker import Worker
from app.schemas.user import UserFavoriteCreate, UserFavoriteResponse
from app.routers.auth import get_current_user

router = APIRouter(prefix="/favorites", tags=["favorites"])


@router.post("/", response_model=UserFavoriteResponse)
async def add_favorite(
    favorite: UserFavoriteCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Add a worker to user's favorites"""
    if not isinstance(current_user, User):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only users can add favorites"
        )
    
    # Check if worker exists
    worker = db.query(Worker).filter(Worker.id == favorite.worker_id).first()
    if not worker:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Worker not found"
        )
    
    # Check if already in favorites
    existing_favorite = db.query(UserFavorite).filter(
        UserFavorite.user_id == current_user.id,
        UserFavorite.worker_id == favorite.worker_id
    ).first()
    
    if existing_favorite:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Worker is already in your favorites"
        )
    
    # Create favorite
    db_favorite = UserFavorite(
        user_id=current_user.id,
        worker_id=favorite.worker_id
    )
    db.add(db_favorite)
    db.commit()
    db.refresh(db_favorite)
    
    # Return with worker details
    return {
        "id": db_favorite.id,
        "user_id": db_favorite.user_id,
        "worker_id": db_favorite.worker_id,
        "created_at": db_favorite.created_at,
        "worker": {
            "id": worker.id,
            "full_name": worker.full_name,
            "email": worker.email,
            "bio": worker.bio,
            "skills": worker.skills,
            "hourly_rate": worker.hourly_rate,
            "rating": worker.rating,
            "total_reviews": worker.total_reviews,
            "is_available": worker.is_available,
            "is_verified": worker.is_verified,
            "created_at": worker.created_at
        }
    }


@router.delete("/{worker_id}")
async def remove_favorite(
    worker_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Remove a worker from user's favorites"""
    if not isinstance(current_user, User):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only users can remove favorites"
        )
    
    favorite = db.query(UserFavorite).filter(
        UserFavorite.user_id == current_user.id,
        UserFavorite.worker_id == worker_id
    ).first()
    
    if not favorite:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Worker not found in favorites"
        )
    
    db.delete(favorite)
    db.commit()
    
    return {"message": "Worker removed from favorites"}


@router.get("/", response_model=List[UserFavoriteResponse])
async def get_favorites(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Get all user's favorite workers"""
    if not isinstance(current_user, User):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only users can view favorites"
        )
    
    favorites = db.query(UserFavorite).options(
        joinedload(UserFavorite.worker)
    ).filter(UserFavorite.user_id == current_user.id).all()
    
    return [
        {
            "id": fav.id,
            "user_id": fav.user_id,
            "worker_id": fav.worker_id,
            "created_at": fav.created_at,
            "worker": {
                "id": fav.worker.id,
                "full_name": fav.worker.full_name,
                "email": fav.worker.email,
                "bio": fav.worker.bio,
                "skills": fav.worker.skills,
                "hourly_rate": fav.worker.hourly_rate,
                "rating": fav.worker.rating,
                "total_reviews": fav.worker.total_reviews,
                "is_available": fav.worker.is_available,
                "is_verified": fav.worker.is_verified,
                "created_at": fav.worker.created_at
            }
        }
        for fav in favorites
    ]


@router.get("/check/{worker_id}")
async def check_favorite(
    worker_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Check if a worker is in user's favorites"""
    if not isinstance(current_user, User):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only users can check favorites"
        )
    
    favorite = db.query(UserFavorite).filter(
        UserFavorite.user_id == current_user.id,
        UserFavorite.worker_id == worker_id
    ).first()
    
    return {"is_favorite": favorite is not None} 