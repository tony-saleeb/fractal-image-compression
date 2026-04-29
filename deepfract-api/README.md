---
title: DeepFract API
emoji: 🧬
colorFrom: blue
colorTo: purple
sdk: docker
app_port: 7860
pinned: false
---

# DeepFract Neural Compression API

FastAPI backend for neural fractal image compression.

- `POST /compress` — upload image → `.fic` file
- `POST /decompress` — upload `.fic` → decoded PNG
- `GET /health` — server status
