import feedparser
import hashlib
import re
from datetime import datetime, timezone
from typing import List, Optional
from urllib.parse import urlparse
from models.article import Article

RSS_SOURCES = [
    {
        "url": "https://f1-gate.com/feed/",
        "source": "f1gate",
        "display_name": "F1-Gate.com",
    },
    {
        "url": "https://www.as-web.jp/feed",
        "source": "asweb",
        "display_name": "Auto Sport Web",
    },
    {
        "url": "https://jp.motorsport.com/rss/f1/news/",
        "source": "motorsport",
        "display_name": "Motorsport.com",
    },
    {
        "url": "https://www.formula1.com/content/formula1/en/latest/all.rss",
        "source": "formula1",
        "display_name": "Formula 1 公式",
    },
]


def _parse_time(entry) -> datetime:
    if hasattr(entry, "published_parsed") and entry.published_parsed:
        return datetime(*entry.published_parsed[:6], tzinfo=timezone.utc)
    return datetime.now(tz=timezone.utc)


def _extract_image(entry) -> Optional[str]:
    if hasattr(entry, "media_thumbnail") and entry.media_thumbnail:
        return entry.media_thumbnail[0].get("url")
    if hasattr(entry, "media_content") and entry.media_content:
        url = entry.media_content[0].get("url", "")
        if url and not url.endswith((".mp4", ".webm")):
            return url
    if hasattr(entry, "links"):
        for link in entry.links:
            if link.get("type", "").startswith("image/"):
                return link.get("href")
    return None


def _url_to_source_id(url: str) -> str:
    """カスタムURLからソースIDを生成する"""
    return "custom_" + hashlib.md5(url.encode()).hexdigest()[:8]


def _url_to_display_name(url: str) -> str:
    """URLからサイト名を推測する"""
    try:
        host = urlparse(url).netloc.removeprefix("www.")
        return host.split(".")[0].capitalize()
    except Exception:
        return "カスタムソース"


def _fetch_source(source_url: str, source_id: str, display_name: str) -> List[Article]:
    articles: List[Article] = []
    try:
        feed = feedparser.parse(source_url)
        for entry in feed.entries[:25]:
            if not hasattr(entry, "link") or not hasattr(entry, "title"):
                continue
            article_id = hashlib.md5(entry.link.encode()).hexdigest()
            raw_summary = getattr(entry, "summary", "") or ""
            clean_summary = re.sub(r"<[^>]+>", "", raw_summary)[:300]
            articles.append(
                Article(
                    id=article_id,
                    title=entry.title.strip(),
                    url=entry.link,
                    source=source_id,
                    source_display_name=display_name,
                    published_at=_parse_time(entry),
                    summary=clean_summary or None,
                    image_url=_extract_image(entry),
                )
            )
    except Exception as e:
        print(f"[RSS] Error fetching {source_url}: {e}")
    return articles


async def fetch_all_articles(custom_sources: Optional[List[dict]] = None) -> List[Article]:
    """
    custom_sources: [{"url": str, "display_name": str}] のリスト
    """
    articles: List[Article] = []

    all_sources = list(RSS_SOURCES)
    for cs in (custom_sources or []):
        url = cs.get("url", "").strip()
        if not url:
            continue
        all_sources.append({
            "url": url,
            "source": _url_to_source_id(url),
            "display_name": cs.get("display_name") or _url_to_display_name(url),
        })

    for source in all_sources:
        articles.extend(_fetch_source(source["url"], source["source"], source["display_name"]))

    articles.sort(key=lambda x: x.published_at, reverse=True)
    return articles
