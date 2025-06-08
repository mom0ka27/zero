# Zero Animation

> 自托管的私人番剧中心

## 使用

> [!CAUTION]
> 本项目在开发阶段不保证向前兼容, 数据库结构随时可能改变, 故请不要用于生产环境.

### 后端
1. `$ cp .env.example .env` 然后修改里面的值
2. `$ uv run python cli.py {username} {password} true` 注册管理员账号
3. `$ uv run uvicorn app.main:app --host :: --port {port}` 启动服务

## 鸣谢

* [Animeko](https://github.com/open-ani/animeko) 提供灵感, 借鉴了部分UI设计
* [动漫花园](https://share.dmhy.org) 提供 BT 下载源
* [Anime Garden](https://animes.garden/) 非常方便的 API