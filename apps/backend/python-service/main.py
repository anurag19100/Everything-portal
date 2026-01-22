"""
FastAPI microservice for data processing and ML capabilities.
Integrates with MongoDB and PostgreSQL.
"""

from fastapi import FastAPI, HTTPException, Depends
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager
import logging
import os
from typing import Optional

from app.routers import health, data, ml
from app.database import mongodb, postgres
from app.config import get_settings

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

settings = get_settings()


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Lifespan events for startup and shutdown."""
    # Startup
    logger.info("Starting Python microservice...")
    await mongodb.connect_to_mongo()
    await postgres.connect_to_postgres()
    logger.info("Databases connected successfully")
    yield
    # Shutdown
    logger.info("Shutting down Python microservice...")
    await mongodb.close_mongo_connection()
    await postgres.close_postgres_connection()
    logger.info("Databases disconnected")


app = FastAPI(
    title="Python Data Processing Service",
    description="Microservice for data processing and ML operations",
    version="1.0.0",
    lifespan=lifespan
)

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.CORS_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers
app.include_router(health.router, prefix="/api/python/health", tags=["health"])
app.include_router(data.router, prefix="/api/python/data", tags=["data"])
app.include_router(ml.router, prefix="/api/python/ml", tags=["machine-learning"])


@app.get("/")
async def root():
    """Root endpoint."""
    return {
        "service": "Python Data Processing Service",
        "version": "1.0.0",
        "status": "running"
    }


@app.get("/info")
async def info():
    """Service information endpoint."""
    return {
        "service": "python-service",
        "version": "1.0.0",
        "environment": settings.ENVIRONMENT,
        "databases": {
            "mongodb": settings.MONGODB_URL,
            "postgresql": settings.POSTGRES_URL
        }
    }


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(
        "main:app",
        host="0.0.0.0",
        port=8082,
        reload=settings.ENVIRONMENT == "development"
    )
