"""
Data processing endpoints.
"""

from fastapi import APIRouter, HTTPException, Depends
from typing import List, Optional
from pydantic import BaseModel
from datetime import datetime

from app.database.mongodb import get_database

router = APIRouter()


class DataItem(BaseModel):
    """Data item model."""
    id: Optional[str] = None
    name: str
    value: float
    metadata: Optional[dict] = {}
    created_at: Optional[datetime] = None


class DataItemResponse(BaseModel):
    """Data item response model."""
    id: str
    name: str
    value: float
    metadata: dict
    created_at: datetime


@router.get("/")
async def get_data_items(skip: int = 0, limit: int = 10) -> List[DataItemResponse]:
    """Get all data items."""
    db = get_database()
    if not db:
        raise HTTPException(status_code=503, detail="Database not available")

    collection = db["data_items"]
    cursor = collection.find().skip(skip).limit(limit)
    items = []

    async for doc in cursor:
        items.append(DataItemResponse(
            id=str(doc["_id"]),
            name=doc["name"],
            value=doc["value"],
            metadata=doc.get("metadata", {}),
            created_at=doc.get("created_at", datetime.utcnow())
        ))

    return items


@router.get("/{item_id}")
async def get_data_item(item_id: str) -> DataItemResponse:
    """Get a specific data item."""
    db = get_database()
    if not db:
        raise HTTPException(status_code=503, detail="Database not available")

    from bson import ObjectId
    collection = db["data_items"]

    try:
        doc = await collection.find_one({"_id": ObjectId(item_id)})
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Invalid item ID: {str(e)}")

    if not doc:
        raise HTTPException(status_code=404, detail="Item not found")

    return DataItemResponse(
        id=str(doc["_id"]),
        name=doc["name"],
        value=doc["value"],
        metadata=doc.get("metadata", {}),
        created_at=doc.get("created_at", datetime.utcnow())
    )


@router.post("/")
async def create_data_item(item: DataItem) -> DataItemResponse:
    """Create a new data item."""
    db = get_database()
    if not db:
        raise HTTPException(status_code=503, detail="Database not available")

    collection = db["data_items"]
    doc = {
        "name": item.name,
        "value": item.value,
        "metadata": item.metadata or {},
        "created_at": datetime.utcnow()
    }

    result = await collection.insert_one(doc)

    return DataItemResponse(
        id=str(result.inserted_id),
        name=doc["name"],
        value=doc["value"],
        metadata=doc["metadata"],
        created_at=doc["created_at"]
    )


@router.put("/{item_id}")
async def update_data_item(item_id: str, item: DataItem) -> DataItemResponse:
    """Update a data item."""
    db = get_database()
    if not db:
        raise HTTPException(status_code=503, detail="Database not available")

    from bson import ObjectId
    collection = db["data_items"]

    try:
        result = await collection.update_one(
            {"_id": ObjectId(item_id)},
            {"$set": {
                "name": item.name,
                "value": item.value,
                "metadata": item.metadata or {}
            }}
        )
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Invalid item ID: {str(e)}")

    if result.matched_count == 0:
        raise HTTPException(status_code=404, detail="Item not found")

    return await get_data_item(item_id)


@router.delete("/{item_id}")
async def delete_data_item(item_id: str):
    """Delete a data item."""
    db = get_database()
    if not db:
        raise HTTPException(status_code=503, detail="Database not available")

    from bson import ObjectId
    collection = db["data_items"]

    try:
        result = await collection.delete_one({"_id": ObjectId(item_id)})
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Invalid item ID: {str(e)}")

    if result.deleted_count == 0:
        raise HTTPException(status_code=404, detail="Item not found")

    return {"message": "Item deleted successfully"}
