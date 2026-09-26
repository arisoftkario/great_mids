from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.orm import Session
from app.database import get_db
from app.models.user import User, UserRole
from app.models.content import ContentItem
from app.models.audit import AuditLog
from app.schemas.content import ContentCreate, ContentUpdate, ContentResponse
from app.core.dependencies import get_current_user

router = APIRouter(prefix="/admin/contents", tags=["Administration - Contenus"])

@router.get("", response_model=List[ContentResponse])
def list_contents(
    category: Optional[str] = None,
    is_published: Optional[bool] = None,
    skip: int = Query(0, ge=0),
    limit: int = Query(50, le=100),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Liste tous les contenus (offres, actualités, services) pour le back-office."""
    query = db.query(ContentItem)
    if category:
        query = query.filter(ContentItem.category == category)
    if is_published is not None:
        query = query.filter(ContentItem.is_published == is_published)
    return query.order_by(ContentItem.created_at.desc()).offset(skip).limit(limit).all()

@router.post("", response_model=ContentResponse, status_code=status.HTTP_201_CREATED)
def create_content(
    content_in: ContentCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Crée un nouveau contenu ou une nouvelle offre d'emploi."""
    new_item = ContentItem(
        category=content_in.category,
        title=content_in.title,
        slug=content_in.slug or content_in.title.lower().replace(" ", "-"),
        summary=content_in.summary,
        details=content_in.details,
        cover_image=content_in.cover_image,
        is_published=content_in.is_published,
        author_id=current_user.id,
    )
    db.add(new_item)
    
    audit = AuditLog(
        user_id=current_user.id,
        user_email=current_user.email,
        action="CONTENT_CREATED",
        resource="contents",
        details=f"Création d'un contenu dans '{new_item.category}': {new_item.title}",
    )
    db.add(audit)
    db.commit()
    db.refresh(new_item)
    return new_item

@router.get("/{content_id}", response_model=ContentResponse)
def get_content_item(
    content_id: str,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Détail d'un contenu pour formulaire d'édition."""
    item = db.query(ContentItem).filter(ContentItem.id == content_id).first()
    if not item:
        raise HTTPException(status_code=404, detail="Contenu introuvable.")
    return item

@router.put("/{content_id}", response_model=ContentResponse)
def update_content_item(
    content_id: str,
    content_in: ContentUpdate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Met à jour un contenu."""
    item = db.query(ContentItem).filter(ContentItem.id == content_id).first()
    if not item:
        raise HTTPException(status_code=404, detail="Contenu introuvable.")
        
    for field, value in content_in.model_dump(exclude_unset=True).items():
        setattr(item, field, value)
        
    audit = AuditLog(
        user_id=current_user.id,
        user_email=current_user.email,
        action="CONTENT_UPDATED",
        resource="contents",
        resource_id=item.id,
        details=f"Modification de {item.title}",
    )
    db.add(audit)
    db.commit()
    db.refresh(item)
    return item

@router.delete("/{content_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_content_item(
    content_id: str,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Supprime un contenu."""
    item = db.query(ContentItem).filter(ContentItem.id == content_id).first()
    if not item:
        raise HTTPException(status_code=404, detail="Contenu introuvable.")
        
    db.delete(item)
    audit = AuditLog(
        user_id=current_user.id,
        user_email=current_user.email,
        action="CONTENT_DELETED",
        resource="contents",
        resource_id=content_id,
        details=f"Suppression de {item.title}",
    )
    db.add(audit)
    db.commit()
    return None
