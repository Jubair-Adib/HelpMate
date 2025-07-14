from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.core.security import verify_password, get_password_hash, create_access_token, verify_token
from app.models.user import User
from app.models.worker import Worker
from app.schemas.user import UserCreate, UserLogin, UserResponse, Token, UserUpdate
from app.schemas.worker import WorkerCreate, WorkerLogin, WorkerResponse
from app.services.worker_service import WorkerService

router = APIRouter(prefix="/auth", tags=["authentication"])
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="auth/login")


@router.post("/register/user", response_model=UserResponse)
def register_user(user: UserCreate, db: Session = Depends(get_db)):
    """Register a new user"""
    # Check if email already exists
    db_user = db.query(User).filter(User.email == user.email).first()
    if db_user:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Email already registered"
        )
    
    # Create new user
    hashed_password = get_password_hash(user.password)
    db_user = User(
        email=user.email,
        full_name=user.full_name,
        hashed_password=hashed_password,
        phone_number=user.phone_number,
        address=user.address
    )
    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    return db_user


@router.post("/register/worker", response_model=WorkerResponse)
def register_worker(worker: WorkerCreate, db: Session = Depends(get_db)):
    """Register a new worker with automatic service creation"""
    # Check if email already exists
    db_worker = db.query(Worker).filter(Worker.email == worker.email).first()
    if db_worker:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Email already registered"
        )
    
    # Create worker with services using the service
    worker_data = worker.dict()
    worker_data['hashed_password'] = get_password_hash(worker.password)
    
    try:
        db_worker = WorkerService.create_worker_with_services(db, worker_data)
        return db_worker
    except Exception as e:
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error creating worker: {str(e)}"
        )


@router.post("/login/user", response_model=Token)
def login_user(user_credentials: UserLogin, db: Session = Depends(get_db)):
    """Login for users"""
    user = db.query(User).filter(User.email == user_credentials.email).first()
    if not user or not verify_password(user_credentials.password, user.hashed_password):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect email or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    if not user.is_active:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Inactive user"
        )
    
    access_token = create_access_token(
        data={"sub": user.email, "user_type": "user", "user_id": user.id}
    )
    return {
        "access_token": access_token,
        "token_type": "bearer",
        "user_type": "user",
        "user_id": user.id
    }


@router.post("/login/worker", response_model=Token)
def login_worker(worker_credentials: WorkerLogin, db: Session = Depends(get_db)):
    """Login for workers"""
    worker = db.query(Worker).filter(Worker.email == worker_credentials.email).first()
    if not worker or not verify_password(worker_credentials.password, worker.hashed_password):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect email or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    if not worker.is_active:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Inactive worker"
        )
    
    access_token = create_access_token(
        data={"sub": worker.email, "user_type": "worker", "user_id": worker.id}
    )
    return {
        "access_token": access_token,
        "token_type": "bearer",
        "user_type": "worker",
        "user_id": worker.id
    }


async def get_current_user(token: str = Depends(oauth2_scheme), db: Session = Depends(get_db)):
    """Get current authenticated user"""
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    
    payload = verify_token(token)
    if payload is None:
        raise credentials_exception
    
    email: str = payload.get("sub")
    user_type: str = payload.get("user_type")
    
    if email is None or user_type is None:
        raise credentials_exception
    
    if user_type == "user":
        user = db.query(User).filter(User.email == email).first()
        if user is None:
            raise credentials_exception
        return user
    elif user_type == "worker":
        worker = db.query(Worker).filter(Worker.email == email).first()
        if worker is None:
            raise credentials_exception
        return worker
    else:
        raise credentials_exception


@router.get("/user/profile", response_model=UserResponse)
async def get_user_profile(current_user: User = Depends(get_current_user)):
    """Get current user's profile"""
    if not isinstance(current_user, User):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only users can access this endpoint"
        )
    return current_user


@router.put("/user/profile", response_model=UserResponse)
async def update_user_profile(
    user_update: UserUpdate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Update user's profile"""
    if not isinstance(current_user, User):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only users can access this endpoint"
        )
    
    # Update user fields
    for field, value in user_update.dict(exclude_unset=True).items():
        setattr(current_user, field, value)
    
    db.commit()
    db.refresh(current_user)
    return current_user 