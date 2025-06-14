# Zero Anime Backend

## 使用
1. `$ cp .env.example .env` 然后修改里面的值
2. 修改`docker-compose.yml`里的`./data`为你想挂载数据的目录
3. `$ uv run python cli.py {username} {password} true` 注册管理员账号
4. `$ uv run uvicorn app.main:app --host :: --port {port}` 启动服务