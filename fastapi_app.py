from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles
from fastapi.responses import FileResponse
import uvicorn

app = FastAPI(title="Real Estate Dashboard API")

# Mount static files
app.mount("/static", StaticFiles(directory="."), name="static")

# Serve the main page
@app.get("/")
async def read_index():
    return FileResponse('index.html')

# Serve HTML modules
@app.get("/{file_path:path}")
async def serve_files(file_path: str):
    if file_path.endswith('.html'):
        return FileResponse(file_path)
    return FileResponse(file_path)

# API endpoints
@app.get("/api/properties")
async def get_properties():
    return {
        "properties": [
            {
                "id": 1,
                "title": "Modern Apartment",
                "price": 450000,
                "area": 120,
                "bedrooms": 3,
                "bathrooms": 2,
                "status": "available"
            }
        ]
    }

@app.get("/api/clients")
async def get_clients():
    return {
        "clients": [
            {
                "id": 1,
                "name": "John Smith",
                "email": "john.smith@email.com",
                "budget": 500000,
                "status": "active"
            }
        ]
    }

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)