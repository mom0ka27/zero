import typer
from app.main import app  # 导入 FastAPI 实例

cli = typer.Typer()


@cli.command()
def run_server(port: int = 8000):
    """启动 FastAPI 服务器"""
    import uvicorn

    uvicorn.run(app, host="0.0.0.0", port=port)


@cli.command()
def register(username: str, password: str, admin: bool):
    from app.db import engine, User, PermissionGroup
    from bcrypt import gensalt, hashpw
    from sqlmodel import Session

    with Session(engine) as session:
        session.add(
            User(
                username=username,
                password=hashpw(password.encode(), gensalt()),
                group=PermissionGroup.ADMIN if admin else PermissionGroup.USER,
            )
        )
        session.commit()


if __name__ == "__main__":
    cli()
