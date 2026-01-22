"""
Health check endpoints.
"""

from fastapi import APIRouter, HTTPException
from datetime import datetime
import asyncio

from app.database.mongodb import get_database
from app.database.postgres import engine

router = APIRouter()


@router.get("/")
async def health_check():
    """Basic health check."""
    return {
        "status": "healthy",
        "timestamp": datetime.utcnow().isoformat(),
        "service": "python-service"
    }


@router.get("/ready")
async def readiness_check():
    """Readiness check with database connectivity."""
    checks = {
        "status": "ready",
        "timestamp": datetime.utcnow().isoformat(),
        "checks": {}
    }

    # Check MongoDB
    try:
        db = get_database()
        if db is not None:
            await db.command('ping')
            checks["checks"]["mongodb"] = "connected"
        else:
            checks["checks"]["mongodb"] = "not initialized"
            checks["status"] = "not ready"
    except Exception as e:
        checks["checks"]["mongodb"] = f"error: {str(e)}"
        checks["status"] = "not ready"

    # Check PostgreSQL
    try:
        if engine:
            async with engine.connect() as conn:
                await conn.execute("SELECT 1")
            checks["checks"]["postgresql"] = "connected"
        else:
            checks["checks"]["postgresql"] = "not initialized"
            checks["status"] = "not ready"
    except Exception as e:
        checks["checks"]["postgresql"] = f"error: {str(e)}"
        checks["status"] = "not ready"

    if checks["status"] != "ready":
        raise HTTPException(status_code=503, detail=checks)

    return checks


@router.get("/live")
async def liveness_check():
    """Liveness check."""
    return {
        "status": "alive",
        "timestamp": datetime.utcnow().isoformat()
    }
