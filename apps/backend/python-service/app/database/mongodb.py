"""
MongoDB database connection and management.
"""

from motor.motor_asyncio import AsyncIOMotorClient
from typing import Optional
import logging

from app.config import get_settings

logger = logging.getLogger(__name__)
settings = get_settings()


class MongoDB:
    """MongoDB connection manager."""

    def __init__(self):
        self.client: Optional[AsyncIOMotorClient] = None
        self.db = None

    async def connect_to_mongo(self):
        """Connect to MongoDB."""
        try:
            logger.info(f"Connecting to MongoDB at {settings.MONGODB_URL}")
            self.client = AsyncIOMotorClient(settings.MONGODB_URL)
            self.db = self.client[settings.MONGODB_DB_NAME]
            # Test connection
            await self.client.admin.command('ping')
            logger.info("MongoDB connected successfully")
        except Exception as e:
            logger.error(f"Failed to connect to MongoDB: {e}")
            raise

    async def close_mongo_connection(self):
        """Close MongoDB connection."""
        if self.client:
            self.client.close()
            logger.info("MongoDB connection closed")

    def get_database(self):
        """Get database instance."""
        return self.db


# Global instance
mongodb_manager = MongoDB()


async def connect_to_mongo():
    """Connect to MongoDB."""
    await mongodb_manager.connect_to_mongo()


async def close_mongo_connection():
    """Close MongoDB connection."""
    await mongodb_manager.close_mongo_connection()


def get_database():
    """Get MongoDB database."""
    return mongodb_manager.get_database()
