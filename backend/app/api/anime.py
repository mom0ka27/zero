from fastapi import APIRouter
from sqlmodel import select

from app.db import SqlDep, Anime
from app.auth import UserDep

router = APIRouter(prefix="/anime")


@router.get("/list")
def anime_list(user: UserDep, sql: SqlDep):
    animes = sql.exec(select(Anime)).all()
    return list(map(lambda a: {"id": a.id, "title": a.title, "image": a.image}, animes))
