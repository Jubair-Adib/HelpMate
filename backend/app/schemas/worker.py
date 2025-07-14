from pydantic import BaseModel, EmailStr
from typing import Optional, List
from datetime import datetime


class WorkerBase(BaseModel):
    email: EmailStr
    full_name: str
    phone_number: Optional[str] = None
    address: Optional[str] = None


class WorkerCreate(WorkerBase):
    password: str
    bio: Optional[str] = None
    skills: Optional[List[str]] = None
    hourly_rate: Optional[float] = None
    experience_years: Optional[int] = None
    is_available: bool = True


class WorkerUpdate(BaseModel):
    full_name: Optional[str] = None
    phone_number: Optional[str] = None
    address: Optional[str] = None


class WorkProfileUpdate(BaseModel):
    bio: Optional[str] = None
    skills: Optional[List[str]] = None
    hourly_rate: Optional[float] = None
    experience_years: Optional[int] = None
    is_available: Optional[bool] = None


class WorkerResponse(WorkerBase):
    id: int
    bio: Optional[str] = None
    skills: Optional[List[str]] = None
    hourly_rate: Optional[float] = None
    experience_years: Optional[int] = None
    is_available: bool
    rating: float
    total_reviews: int
    is_verified: bool
    is_active: bool
    created_at: datetime
    updated_at: Optional[datetime] = None
    
    class Config:
        from_attributes = True


class WorkerLogin(BaseModel):
    email: EmailStr
    password: str


class WorkerOrderCreate(BaseModel):
    service_id: int
    description: Optional[str] = None
    scheduled_date: Optional[datetime] = None


class WorkerOrderResponse(BaseModel):
    id: int
    worker_id: int
    service_id: int
    status: str
    description: Optional[str] = None
    scheduled_date: Optional[datetime] = None
    created_at: datetime
    updated_at: Optional[datetime] = None
    
    class Config:
        from_attributes = True 