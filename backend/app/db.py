from enum import IntEnum
from typing import Annotated
import uuid

from app.config import settings

from fastapi import Depends, HTTPException
from sqlmodel import Field
from sqlmodel import Session as SqlSession
from sqlmodel import SQLModel, create_engine


class Anime(SQLModel, table=True):
    id: int = Field(primary_key=True)
    title: str = Field()
    image: str = Field()

    bt_hash: str = Field(nullable=True)


class PermissionGroup(IntEnum):
    ADMIN = 0
    USER = 1
    GUEST = 2


class User(SQLModel, table=True):
    username: str = Field(primary_key=True)
    password: bytes = Field()
    group: PermissionGroup = Field()

    def assert_permission(self, perm: PermissionGroup):
        if self.group.value > perm.value:
            raise HTTPException(status_code=403)


def gen_uuid():
    return uuid.uuid4().hex


engine = create_engine(settings.DB_URL)
SQLModel.metadata.create_all(engine)


def get_session():
    with SqlSession(engine) as session:
        yield session


SqlDep = Annotated[SqlSession, Depends(get_session)]
