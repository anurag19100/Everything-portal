"""
Configuration management for Python service.
"""

from pydantic_settings import BaseSettings
from functools import lru_cache
from typing import List


class Settings(BaseSettings):
    """Application settings."""

    # Application
    APP_NAME: str = "Python Data Processing Service"
    ENVIRONMENT: str = "development"
    DEBUG: bool = True

    # Database - MongoDB
    MONGODB_URL: str = "mongodb://mongodb:27017"
    MONGODB_DB_NAME: str = "python_service"

    # Database - PostgreSQL
    POSTGRES_URL: str = "postgresql://postgres:postgres@postgresql:5432/python_db"
    POSTGRES_USER: str = "postgres"
    POSTGRES_PASSWORD: str = "postgres"
    POSTGRES_DB: str = "python_db"
    POSTGRES_HOST: str = "postgresql"
    POSTGRES_PORT: int = 5432

    # CORS
    CORS_ORIGINS: List[str] = [
        "http://localhost:3000",
        "http://localhost:3001",
        "http://claude-chat:3000",
        "http://secondary-ui:3001"
    ]

    # Service Communication
    JAVA_SERVICE_URL: str = "http://java-service:8080"
    GO_SERVICE_URL: str = "http://go-service:8081"

    # ML Configuration
    ML_MODEL_PATH: str = "/models"
    ML_CACHE_SIZE: int = 100

    class Config:
        env_file = ".env"
        case_sensitive = True


@lru_cache()
def get_settings() -> Settings:
    """Get cached settings instance."""
    return Settings()
