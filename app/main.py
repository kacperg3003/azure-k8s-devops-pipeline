from fastapi import FastAPI
import socket

app = FastAPI()

@app.get("/")
def read_root():
    return {
        "message": "Hello DevOps World!",
        "version": "1.0.0",
        "hostname": socket.gethostname(),
        "platform": "Azure Kubernetes Service"
    }

@app.get("/health")
def health_check():
    return {"status": "healthy"}
