from typing import Annotated
from fastapi import Depends, HTTPException, Request
from fastapi.security import OAuth2PasswordBearer
from sqlmodel import select
from jose import jwt

from app.db import SqlDep, User
from app.config import settings

ALGORITHM = "HS256"

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/no")


def get_user(sql: SqlDep, token: str = Depends(oauth2_scheme)):
    payload = jwt.decode(token, settings.SECRET_KEY, algorithms=[ALGORITHM])
    user = sql.exec(select(User).where(User.username == payload["sub"])).first()
    if not user:
        raise HTTPException(status_code=401)
    return user


UserDep = Annotated[User, Depends(get_user)]
