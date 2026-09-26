from typing import List, Optional
from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session
from app.database import get_db
from app.models.content import ContentItem
from app.schemas.content import ContentResponse

router = APIRouter(prefix="/public", tags=["Public API"])

@router.get("/offers", response_model=List[ContentResponse])
def get_public_offers(
    skip: int = Query(0, ge=0),
    limit: int = Query(20, le=50),
    db: Session = Depends(get_db),
):
    """Récupère les offres d'emploi actuellement publiées sur le site."""
    return (
        db.query(ContentItem)
        .filter(ContentItem.category == "offers", ContentItem.is_published == True)
        .order_by(ContentItem.created_at.desc())
        .offset(skip)
        .limit(limit)
        .all()
    )

@router.get("/news", response_model=List[ContentResponse])
def get_public_news(
    skip: int = Query(0, ge=0),
    limit: int = Query(20, le=50),
    db: Session = Depends(get_db),
):
    """Récupère les actualités publiées sur le site."""
    return (
        db.query(ContentItem)
        .filter(ContentItem.category == "news", ContentItem.is_published == True)
        .order_by(ContentItem.created_at.desc())
        .offset(skip)
        .limit(limit)
        .all()
    )
