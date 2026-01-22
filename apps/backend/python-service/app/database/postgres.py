"""
PostgreSQL database connection and management.
"""

from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession, async_sessionmaker
from sqlalchemy.orm import declarative_base
from typing import Optional, AsyncGenerator
import logging

from app.config import get_settings

logger = logging.getLogger(__name__)
settings = get_settings()

# Create async engine
engine = None
async_session_maker = None

# Base class for models
Base = declarative_base()


async def connect_to_postgres():
    """Connect to PostgreSQL."""
    global engine, async_session_maker
    try:
        # Convert URL to async version
        db_url = settings.POSTGRES_URL.replace('postgresql://', 'postgresql+asyncpg://')
        logger.info(f"Connecting to PostgreSQL")

        engine = create_async_engine(
            db_url,
            echo=settings.DEBUG,
            pool_size=10,
            max_overflow=20
        )

        async_session_maker = async_sessionmaker(
            engine,
            class_=AsyncSession,
            expire_on_commit=False
        )

        # Test connection
        async with engine.begin() as conn:
            await conn.run_sync(lambda _: None)

        logger.info("PostgreSQL connected successfully")
    except Exception as e:
        logger.error(f"Failed to connect to PostgreSQL: {e}")
        raise


async def close_postgres_connection():
    """Close PostgreSQL connection."""
    global engine
    if engine:
        await engine.dispose()
        logger.info("PostgreSQL connection closed")


async def get_session() -> AsyncGenerator[AsyncSession, None]:
    """Get database session."""
    async with async_session_maker() as session:
        try:
            yield session
            await session.commit()
        except Exception:
            await session.rollback()
            raise
        finally:
            await session.close()
