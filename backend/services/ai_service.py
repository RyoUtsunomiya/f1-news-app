import anthropic
import os
import json
import re
import hashlib
from datetime import datetime, timezone
from typing import List, Optional
from models.article import Article
from models.summary import AiSummary

_client: Optional[anthropic.Anthropic] = None


def _get_client() -> anthropic.Anthropic:
    global _client
    if _client is None:
        _client = anthropic.Anthropic(api_key=os.environ["ANTHROPIC_API_KEY"])
    return _client


async def generate_daily_summary(articles: List[Article]) -> List[AiSummary]:
    if not articles:
        return []

    articles_text = "\n".join(
        f"- [{a.source_display_name}] {a.title}"
        + (f"　{a.summary[:100]}" if a.summary else "")
        for a in articles[:40]
    )

    prompt = f"""あなたはF1レーシングの専門ライターです。
以下は本日の日本語F1ニュース記事一覧です。複数のメディアが同じ話題を取り上げています。

記事一覧:
{articles_text}

これらを分析して、主要トピック3〜5個を選び、各トピックを日本語でまとめてください。

以下のJSON配列形式のみで返答してください（説明文不要）:
[
  {{
    "topic": "トピック分類（例: レース結果、チーム動向、技術情報、ドライバー情報、レギュレーション）",
    "title": "まとめ記事タイトル（20〜30文字）",
    "content": "各メディアの情報を統合した分かりやすい日本語まとめ（300〜400文字）"
  }}
]"""

    client = _get_client()
    message = client.messages.create(
        model="claude-sonnet-4-6",
        max_tokens=2048,
        messages=[{"role": "user", "content": prompt}],
    )

    response_text = message.content[0].text
    json_match = re.search(r"\[.*\]", response_text, re.DOTALL)
    if not json_match:
        return []

    try:
        topics = json.loads(json_match.group())
    except json.JSONDecodeError:
        return []

    now = datetime.now(tz=timezone.utc)
    summaries: List[AiSummary] = []
    for topic in topics:
        summary_id = hashlib.md5(
            f"{topic['title']}{now.date()}".encode()
        ).hexdigest()
        summaries.append(
            AiSummary(
                id=summary_id,
                title=topic["title"],
                content=topic["content"],
                related_articles=[a.url for a in articles[:5]],
                generated_at=now,
                topic=topic["topic"],
            )
        )

    return summaries
