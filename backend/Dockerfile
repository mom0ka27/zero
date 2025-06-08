FROM python:3.13-slim

COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

ADD . /app
WORKDIR /app

RUN uv sync --locked

EXPOSE 12091

# Default command
CMD ["uv", "run", "uvicorn", "app.main:app", "--port", "12091", "--host", "::"]