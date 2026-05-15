from pydantic import BaseModel
from datetime import datetime
from typing import List


class AiSummary(BaseModel):
    id: str
    title: str
    content: str
    related_articles: List[str]
    generated_at: datetime
    topic: str
