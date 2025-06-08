from contextlib import asynccontextmanager
import json
from loguru import logger

from app.api import anime, source, storage, user

from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse, Response

from starlette.middleware.base import BaseHTTPMiddleware
import traceback

VERSION = "1.0.0"

logger.add("logs/latest.log", rotation="500 MB")


@asynccontextmanager
async def lifespan(app: FastAPI):
    logger.info(f"Startup (version {VERSION})")
    yield
    logger.warning("Bye~")


app = FastAPI(lifespan=lifespan)

app.include_router(anime.router)
app.include_router(source.router)
app.include_router(storage.router)
app.include_router(user.router)


@app.get("/")
def hi():
    return {"version": VERSION}


class AddCodeMiddleware(BaseHTTPMiddleware):
    async def dispatch(self, request: Request, call_next):
        response = await call_next(request)

        if (
            response.headers.get("content-type") != "application/json"
            or response.status_code != 200
        ):
            return response

        body = b""
        async for chunk in response.body_iterator:  # type: ignore
            body += chunk

        try:
            data = json.loads(body)
            # 如果已经有 code，就不添加
            if isinstance(data, dict) and "code" in data:
                return JSONResponse(content=data)
            data = {"code": 200, "message": "success", "data": data}

            new_response = JSONResponse(content=data)
            return new_response
        except Exception as e:
            # 如果无法解析为 JSON，就原样返回
            traceback.print_exception(e)
            return Response(content=body)


app.add_middleware(AddCodeMiddleware)
