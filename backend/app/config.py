from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    LOG_LEVEL: str = "INFO"

    SECRET_KEY: str

    DATA_FOLDER: str

    QBIT_SERVER: str

    DANDANPLAY_ID: str
    DANDANPLAY_SECRET: str

    DB_URL: str
    VIDEO_URL: str

    class Config:
        env_file = ".env"


settings = Settings()  # type: ignore
