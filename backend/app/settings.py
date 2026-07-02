from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    allowed_origins: str = "http://localhost:5173"
    app_env: str = "development"
    database_url: str = "postgresql+psycopg://factory_cloud:factory_cloud_dev@localhost:5432/factory_cloud"

    @property
    def origins_list(self) -> list[str]:
        return [o.strip() for o in self.allowed_origins.split(",")]

    model_config = {"env_file": ".env"}


settings = Settings()
