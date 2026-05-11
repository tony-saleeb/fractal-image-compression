# ── DeepFract Backend — Hugging Face Spaces Deployment ──────────
# Optimized for CPU inference with minimal image size
FROM python:3.11-slim

WORKDIR /app

# System dependencies for OpenCV and building compressai
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential libgl1 libglib2.0-0 && \
    rm -rf /var/lib/apt/lists/*

# Install PyTorch CPU-only (saves ~1.5GB vs full torch)
RUN pip install --no-cache-dir \
    torch torchvision --index-url https://download.pytorch.org/whl/cpu

# Install remaining dependencies
COPY requirements-deploy.txt .
RUN pip install --no-cache-dir -r requirements-deploy.txt

# Copy backend source code
COPY server.py .
COPY compressai_fallback.py .
COPY custom_decoder.py .
COPY fractalcompression_codec.py .
COPY patch_compressai.py .
COPY main.py .
COPY compressai_fallback.py .
COPY export_onnx.py .
COPY src/ ./src/

# Copy model weights (uploaded via git LFS)
COPY models/finetuned_fractalcompression_q2.pth ./models/

# HF Spaces requires port 7860
ENV FC_PORT=7860
ENV FC_HOST=0.0.0.0
ENV FC_MAX_DIM=1024

EXPOSE 7860

CMD ["python", "server.py"]
