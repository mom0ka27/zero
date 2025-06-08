from loguru import logger

from app.db import SqlDep, User, PermissionGroup
from app.config import settings
from app.auth import ALGORITHM, UserDep

from jose import jwt
from bcrypt import checkpw, gensalt, hashpw
from fastapi import APIRouter

router = APIRouter(prefix="/user")


@router.get("/info")
def info(user: UserDep):
    return {"user": user.username}


@router.post("/login")
def login(sql: SqlDep, username: str, password: str):
    user = sql.get(User, username)
    if not user:
        return {"code": -1, "message": "用户不存在"}
    if not checkpw(password.encode(), user.password):
        return {"code": -2, "message": "密码错误"}
    access_token = jwt.encode(
        {"sub": user.username}, settings.SECRET_KEY, algorithm=ALGORITHM
    )
    logger.info(f"用户 {username} 登录")
    return {"access_token": access_token, "token_type": "bearer"}
