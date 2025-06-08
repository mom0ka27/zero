import httpx
from loguru import logger

from app.db import PermissionGroup

from lxml import etree
from fastapi import APIRouter

from ..auth import UserDep

router = APIRouter(prefix="/source")

client = httpx.AsyncClient(timeout=60)


class Source:
    async def search(self, keyword: str) -> list:
        return []


class MikanSource(Source):
    async def search(self, keyword: str):
        resp = await client.get(
            f"https://mikanani.kas.pub/RSS/Search?searchstr={keyword}"
        )

        root = etree.fromstring(resp.text.encode("utf-8"), None)
        channel = root.find("channel")
        items = channel.findall("item")

        result = []

        for item in items:
            item_description: str = item.find("title").text
            if ("1-" not in item_description) and (
                "Fin" not in item_description
            ):  # 全集
                continue

            enclosure = item.find("enclosure")
            enclosure_url = enclosure.get("url")

            length = enclosure.get("length")

            result.append(
                {
                    "title": item_description.replace("【", "[").replace("】", "]"),
                    "url": enclosure_url,
                    "size": int(length),
                }
            )

        return result


class DmhySource(Source):
    async def search(self, keyword: str):
        resp = await client.get(
            f"https://dmhy.org/topics/rss/rss.xml?keyword={keyword}&sort_id=31&team_id=0&order=date-desc"
        )

        root = etree.fromstring(resp.text.encode("utf-8"), None)
        channel = root.find("channel")
        items = channel.findall("item")

        result = []

        for item in items:
            item_title: str = item.find("title").text
            if "1-" not in item_title:
                continue
            if "简" not in item_title:
                continue

            enclosure = item.find("enclosure")
            enclosure_url = enclosure.get("url")

            result.append(
                {
                    "title": item_title.replace("【", "[").replace("】", "]"),
                    "url": enclosure_url,
                }
            )

        return result


class AnimeGardenSource(Source):
    async def search(self, keyword: str):
        resp = await client.post(
            f"https://api.animes.garden/resources?type=合集&tracker=true",
            json={
                "search": [
                    keyword,
                ]
            },
        )
        j = resp.json()
        result = []
        for item in j["resources"]:
            result.append(
                {
                    "title": item["title"],
                    "url": item["magnet"] + item["tracker"],
                    "size": item["size"],
                }
            )
        return result


sources = {"dmhy": AnimeGardenSource(), "mikan": MikanSource()}


@router.get("/search", description="在指定的下载源搜索")
async def search(user: UserDep, keyword: str, source: str = "dmhy"):
    user.assert_permission(PermissionGroup.ADMIN)
    logger.info(f"用户 {user.username} 在 {source} 上搜索 {keyword}")
    if source not in sources:
        return {"code": -1, "msg": "未知下载源"}
    return await sources[source].search(keyword)
