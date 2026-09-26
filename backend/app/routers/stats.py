from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.database import get_db
from app.models.user import User
from app.models.content import ContentItem
from app.models.audit import AuditLog
from app.core.dependencies import get_current_user

router = APIRouter(prefix="/admin/dashboard", tags=["Administration - Dashboard"])

@router.get("/stats")
def get_dashboard_stats(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Retourne les compteurs clés pour le tableau de bord synthétique."""
    total_users = db.query(User).count()
    total_contents = db.query(ContentItem).count()
    total_offers = db.query(ContentItem).filter(ContentItem.category == "offers").count()
    published_offers = db.query(ContentItem).filter(
        ContentItem.category == "offers", ContentItem.is_published == True
    ).count()
    total_news = db.query(ContentItem).filter(ContentItem.category == "news").count()
    
    recent_logs = (
        db.query(AuditLog)
        .order_by(AuditLog.created_at.desc())
        .limit(10)
        .all()
    )

    return {
        "kpis": {
            "total_users": total_users,
            "total_contents": total_contents,
            "total_offers": total_offers,
            "published_offers": published_offers,
            "total_news": total_news,
        },
        "recent_activities": [
            {
                "id": log.id,
                "user_email": log.user_email or "Système",
                "action": log.action,
                "details": log.details,
                "created_at": log.created_at.isoformat(),
            }
            for log in recent_logs
        ],
    }
