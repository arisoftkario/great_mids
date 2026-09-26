import uuid
from datetime import datetime
from sqlalchemy import Column, String, Text, Boolean, DateTime, JSON
from app.database import Base

class ContentItem(Base):
    __tablename__ = "contents"

    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    category = Column(String(50), index=True, nullable=False) # 'offers', 'news', 'services', 'partners'
    title = Column(String(255), nullable=False)
    slug = Column(String(255), unique=True, index=True, nullable=True)
    summary = Column(Text, nullable=True)
    details = Column(JSON, nullable=True) # Pour stocker des métadonnées comme tags, prix, contrat, ville, etc.
    cover_image = Column(String(500), nullable=True)
    is_published = Column(Boolean, default=True, index=True)
    
    author_id = Column(String(36), nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
