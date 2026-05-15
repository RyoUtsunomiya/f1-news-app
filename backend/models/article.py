from pydantic import BaseModel
from datetime import datetime
from typing import Optional


class Article(BaseModel):
    id: str
    title: str
    url: str
    source: str
    source_display_name: str
    published_at: datetime
    summary: Optional[str] = None
    image_url: Optional[str] = None
