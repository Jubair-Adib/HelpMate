from pydantic import BaseModel, EmailStr
from typing import Optional
from datetime import datetime


class UserBase(BaseModel):
    email: EmailStr
    full_name: str
    phone_number: Optional[str] = None
    address: Optional[str] = None


class UserCreate(UserBase):
    password: str


class UserLogin(BaseModel):
    email: EmailStr
    password: str


class UserUpdate(BaseModel):
    full_name: Optional[str] = None
    phone_number: Optional[str] = None
    address: Optional[str] = None


class UserResponse(UserBase):
    id: int
    is_active: bool
    is_verified: bool
    created_at: datetime
    updated_at: Optional[datetime] = None
    
    class Config:
        from_attributes = True


class UserFavoriteCreate(BaseModel):
    worker_id: int


class UserFavoriteResponse(BaseModel):
    id: int
    user_id: int
    worker_id: int
    created_at: datetime
    worker: dict  # Will contain worker details
    
    class Config:
        from_attributes = True


class Token(BaseModel):
    access_token: str
    token_type: str
    user_type: str  # "user" or "worker"
    user_id: int


class TokenData(BaseModel):
    email: Optional[str] = None
    user_type: Optional[str] = None 