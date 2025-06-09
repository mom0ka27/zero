import os
import re
import base64

import httpx
from loguru import logger

from app.config import settings
from app.db import Episode, SqlDep, Anime, PermissionGroup

from fastapi import APIRouter, HTTPException
from fastapi.responses import RedirectResponse
from sqlmodel import select, insert

from ..auth import UserDep
import natsort

router = APIRouter(prefix="/storage")

base32_pattern = re.compile(r"magnet:\?xt=urn:btih:([a-zA-Z0-9]{32})")
hex_pattern = re.compile(r"magnet:\?xt=urn:btih:([a-fA-F0-9]{40})")


def getHash(magnet: str):
    if m := hex_pattern.match(magnet):
        return m.group(1).lower()
    if m := base32_pattern.match(magnet):
        try:
            decoded = base64.b32decode(m.group(1))
            return decoded.hex()
        except Exception as e:
            logger.warning("遇到无法解析的 Magnet URL: " + magnet)
            return None
    return None


def isVideo(filename: str):
    if "繁" in filename or "TC" in filename:
        return False
    subname = filename[-3:]
    keys = ["mov", "mp4", "mkv"]
    if subname in keys:
        return True
    return False


def isSubtitle(filename: str):
    subname = filename[-3:]
    keys = ["ass", "vtt"]
    if subname in keys:
        return True
    return False


@router.post("/download", description="下载指定的磁力链接")
def download(user: UserDep, magnet: str, id: int, title: str, image: str, sql: SqlDep):
    user.assert_permission(PermissionGroup.ADMIN)
    logger.info(f"用户 {user.username} 请求下载 {id}")

    bt_hash = getHash(magnet)
    if bt_hash == None:
        return {"code": -3, "message": "无效的 magnet"}

    path = f"{os.path.abspath(settings.DATA_FOLDER)}/{id}"

    os.makedirs(path, exist_ok=True)

    r = httpx.post(
        f"{settings.QBIT_SERVER}/api/v2/torrents/add",
        data={"urls": magnet, "category": "ZERO", "savepath": path},
    )

    if r.text == "Ok.":
        sql.add(Anime(id=id, title=title, image=image, bt_hash=bt_hash))
        sql.commit()
        logger.info(f"开始下载 {id}")
        return {"hash": bt_hash}

    logger.error(f"下载 {id} 时出错: [{r.status_code}]{r.text}")
    os.removedirs(path)
    return {"code": -1, "message": r.text}


@router.get("/video")
def video(user: UserDep, id: int, index: int):
    logger.info(f"用户 {user.username} 播放了 {id} 第 {index} 集")
    try:
        target = os.listdir(f"{settings.DATA_FOLDER}/{id}")[0]
        l = natsort.natsorted(
            filter(
                lambda f: isVideo(f),
                os.listdir(f"{settings.DATA_FOLDER}/{id}/{target}"),
            )
        )
        return RedirectResponse(f"{settings.VIDEO_URL}/{id}/{target}/{l[index]}")
    except:
        raise HTTPException(status_code=404)


@router.get("/subtitle")
def subtitle(_: UserDep, id: int, index: int):
    try:
        target = os.listdir(f"{settings.DATA_FOLDER}/{id}")[0]
        l = natsort.natsorted(
            filter(
                lambda f: isSubtitle(f),
                os.listdir(f"{settings.DATA_FOLDER}/{id}/{target}"),
            )
        )
        return RedirectResponse(f"{settings.VIDEO_URL}/{id}/{target}/{l[index]}")
    except:
        raise HTTPException(status_code=404)


@router.get("/task")
def task(user: UserDep, sql: SqlDep):
    user.assert_permission(PermissionGroup.ADMIN)
    try:
        resp = httpx.get(
            f"{settings.QBIT_SERVER}/api/v2/torrents/info?filter=downloading&category=ZERO"
        )
    except:
        return []
    if resp.text == "":
        return []
    result = []
    for t in resp.json():
        bt_hash = t["hash"]
        anime = sql.exec(select(Anime).where(Anime.bt_hash == bt_hash)).first()
        if anime == None:
            print(f"Unable to find {bt_hash}")
            continue
        result.append(
            {
                "id": anime.id,
                "image": anime.image,
                "title": anime.title,
                "completed": t["completed"],
                "size": t["size"],
                "speed": t["dlspeed"],
                "name": t["name"],
            }
        )
    return result


@router.get("/list")
def anime_list(_: UserDep, sql: SqlDep):
    animes = sql.exec(select(Anime)).all()
    return list(map(lambda a: {"id": a.id, "title": a.title, "image": a.image}, animes))


@router.get("/episode")
def get_episode_path(user: UserDep, sql: SqlDep, anime_id: int, index: int):
    ep = sql.exec(
        select(Episode).where((Episode.anime_id == anime_id) & (Episode.index == index))
    ).first()
    if ep == None:
        raise HTTPException(status_code=404)
    return ep.file


@router.post("/episode")
def set_episode_path(user: UserDep, sql: SqlDep, anime_id: int, index: int, file: str):
    logger.info(f"{user.username} 修改了 {anime_id} 第 {index} 集的路径: {file}")
