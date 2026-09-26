from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.orm import Session
from app.database import get_db
from app.models.user import User, UserRole, UserStatus
from app.models.audit import AuditLog
from app.schemas.user import UserCreate, UserUpdate, UserResponse
from app.core.security import get_password_hash
from app.core.dependencies import get_current_user, require_roles

router = APIRouter(prefix="/admin/users", tags=["Administration - Utilisateurs"])

@router.get("", response_model=List[UserResponse])
def list_users(
    role: Optional[UserRole] = None,
    status: Optional[UserStatus] = None,
    skip: int = Query(0, ge=0),
    limit: int = Query(50, le=100),
    current_user: User = Depends(require_roles([UserRole.SUPER_ADMIN, UserRole.ADMIN])),
    db: Session = Depends(get_db),
):
    """Liste tous les comptes utilisateurs avec filtres et pagination."""
    query = db.query(User)
    if role:
        query = query.filter(User.role == role)
    if status:
        query = query.filter(User.status == status)
    return query.offset(skip).limit(limit).all()

@router.post("", response_model=UserResponse, status_code=status.HTTP_201_CREATED)
def create_user(
    user_in: UserCreate,
    current_user: User = Depends(require_roles([UserRole.SUPER_ADMIN, UserRole.ADMIN])),
    db: Session = Depends(get_db),
):
    """Crée un nouvel utilisateur / administrateur."""
    # Seul le SUPER_ADMIN peut créer d'autres ADMIN ou SUPER_ADMIN
    if user_in.role in [UserRole.SUPER_ADMIN, UserRole.ADMIN] and current_user.role != UserRole.SUPER_ADMIN:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Seul le Super Administrateur peut attribuer les rôles Admin et Super Admin.",
        )
        
    existing_user = db.query(User).filter(User.email == user_in.email).first()
    if existing_user:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Un utilisateur avec cette adresse email existe déjà.",
        )
        
    new_user = User(
        email=user_in.email,
        hashed_password=get_password_hash(user_in.password),
        full_name=user_in.full_name,
        role=user_in.role,
        status=user_in.status,
    )
    db.add(new_user)
    
    audit = AuditLog(
        user_id=current_user.id,
        user_email=current_user.email,
        action="USER_CREATED",
        resource="users",
        details=f"Création de l'utilisateur {new_user.email} (rôle: {new_user.role.value})",
    )
    db.add(audit)
    db.commit()
    db.refresh(new_user)
    return new_user

@router.get("/{user_id}", response_model=UserResponse)
def get_user(
    user_id: str,
    current_user: User = Depends(require_roles([UserRole.SUPER_ADMIN, UserRole.ADMIN])),
    db: Session = Depends(get_db),
):
    """Récupère un utilisateur par son ID."""
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="Utilisateur introuvable.")
    return user

@router.patch("/{user_id}", response_model=UserResponse)
def update_user(
    user_id: str,
    user_in: UserUpdate,
    current_user: User = Depends(require_roles([UserRole.SUPER_ADMIN, UserRole.ADMIN])),
    db: Session = Depends(get_db),
):
    """Modifie les informations ou le rôle d'un utilisateur."""
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="Utilisateur introuvable.")
        
    if user_in.role and user_in.role != user.role:
        if current_user.role != UserRole.SUPER_ADMIN:
            raise HTTPException(status_code=403, detail="Seul le Super Admin peut modifier les rôles.")
        user.role = user_in.role
        
    if user_in.email:
        user.email = user_in.email
    if user_in.full_name:
        user.full_name = user_in.full_name
    if user_in.status:
        user.status = user_in.status
    if user_in.password:
        user.hashed_password = get_password_hash(user_in.password)
        
    audit = AuditLog(
        user_id=current_user.id,
        user_email=current_user.email,
        action="USER_UPDATED",
        resource="users",
        resource_id=user.id,
        details=f"Mise à jour du profil de {user.email}",
    )
    db.add(audit)
    db.commit()
    db.refresh(user)
    return user

@router.delete("/{user_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_user(
    user_id: str,
    current_user: User = Depends(require_roles([UserRole.SUPER_ADMIN])),
    db: Session = Depends(get_db),
):
    """Supprime un utilisateur (Super Admin uniquement)."""
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="Utilisateur introuvable.")
    if user.id == current_user.id:
        raise HTTPException(status_code=400, detail="Vous ne pouvez pas supprimer votre propre compte.")
        
    db.delete(user)
    
    audit = AuditLog(
        user_id=current_user.id,
        user_email=current_user.email,
        action="USER_DELETED",
        resource="users",
        resource_id=user_id,
        details=f"Suppression de l'utilisateur {user.email}",
    )
    db.add(audit)
    db.commit()
    return None
