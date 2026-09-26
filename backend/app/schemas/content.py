from pydantic import BaseModel
from typing import Optional, Any, Dict
from datetime import datetime

class ContentBase(BaseModel):
    category: str # 'offers', 'news', 'services', 'partners'
    title: str
    slug: Optional[str] = None
    summary: Optional[str] = None
    details: Optional[Dict[str, Any]] = None
    cover_image: Optional[str] = None
    is_published: bool = True

class ContentCreate(ContentBase):
    pass

class ContentUpdate(BaseModel):
    category: Optional[str] = None
    title: Optional[str] = None
    slug: Optional[str] = None
    summary: Optional[str] = None
    details: Optional[Dict[str, Any]] = None
    cover_image: Optional[str] = None
    is_published: Optional[bool] = None

class ContentResponse(ContentBase):
    id: str
    author_id: Optional[str] = None
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True
