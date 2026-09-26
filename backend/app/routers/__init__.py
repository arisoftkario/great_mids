from app.routers.auth import router as auth_router
from app.routers.users import router as users_router
from app.routers.contents import router as contents_router
from app.routers.stats import router as stats_router
from app.routers.public import router as public_router

__all__ = [
    "auth_router",
    "users_router",
    "contents_router",
    "stats_router",
    "public_router",
]
