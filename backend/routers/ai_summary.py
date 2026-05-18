from fastapi import APIRouter
from typing import List
from datetime import datetime, timezone
from services.rss_service import fetch_all_articles
from services.ai_service import generate_daily_summary
from models.summary import AiSummary
from cachetools import TTLCache

router = APIRouter(tags=["ai-summary"])

_cache: TTLCache = TTLCache(maxsize=5, ttl=3600)


@router.get("/ai-summaries", response_model=List[AiSummary])
async def get_ai_summaries():
    cache_key = f"summaries_{datetime.now(tz=timezone.utc).date()}"
    if cache_key not in _cache or not _cache[cache_key]:
        articles = await fetch_all_articles()
        summaries = await generate_daily_summary(articles)
        if summaries:
            _cache[cache_key] = summaries
        else:
            return []
    return _cache[cache_key]


@router.post("/ai-summaries/refresh", response_model=List[AiSummary])
async def refresh_ai_summaries():
    _cache.clear()
    articles = await fetch_all_articles()
    summaries = await generate_daily_summary(articles)
    cache_key = f"summaries_{datetime.now(tz=timezone.utc).date()}"
    _cache[cache_key] = summaries
    return summaries
