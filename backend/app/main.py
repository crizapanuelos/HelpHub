from fastapi import FastAPI

app = FastAPI(title="HelpHub API", version="0.1.0")


@app.get("/health", tags=["system"])
def health_check() -> dict[str, str]:
    """Return the basic availability status of the HelpHub API."""
    return {"status": "ok", "service": "helphub-api"}
