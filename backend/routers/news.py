from fastapi import APIRouter, Query, Body
from typing import List, Optional
from pydantic import BaseModel, HttpUrl
from services.rss_service import fetch_all_articles, RSS_SOURCES, _url_to_source_id, _url_to_display_name
from models.article import Article
from cachetools import TTLCache

router = APIRouter(tags=["news"])

_cache: TTLCache = TTLCache(maxsize=50, ttl=300)


class CustomSource(BaseModel):
    url: HttpUrl
    display_name: Optional[str] = None


@router.get("/articles", response_model=List[Article])
async def get_articles(
    source: Optional[str] = Query(None, description="ソース絞り込み"),
    custom_urls: Optional[List[str]] = Query(None, description="カスタムRSS URL"),
    limit: int = Query(60, ge=1, le=100),
):
    custom_sources = []
    if custom_urls:
        for u in custom_urls:
            custom_sources.append({"url": u, "display_name": None})

    cache_key = f"articles_{'|'.join(custom_urls or [])}"
    if cache_key not in _cache:
        _cache[cache_key] = await fetch_all_articles(custom_sources or None)

    articles = _cache[cache_key]
    if source:
        articles = [a for a in articles if a.source == source]
    return articles[:limit]


@router.post("/validate-rss")
async def validate_rss(url: str = Query(..., description="検証するRSS URL")):
    """RSS URLが有効かチェックし、サイト名を返す"""
    import feedparser
    try:
        feed = feedparser.parse(url)
        if not feed.entries:
            return {"valid": False, "message": "記事が見つかりませんでした"}
        display_name = feed.feed.get("title", _url_to_display_name(url))
        return {
            "valid": True,
            "display_name": display_name,
            "source_id": _url_to_source_id(url),
            "entry_count": len(feed.entries),
        }
    except Exception:
        return {"valid": False, "message": "RSSの読み込みに失敗しました"}


@router.get("/sources")
async def get_sources():
    return [{"id": s["source"], "name": s["display_name"], "is_default": True} for s in RSS_SOURCES]
