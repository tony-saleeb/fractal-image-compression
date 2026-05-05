<div align="center">
  <img src="frontend/assets/images/logo.png" width="200" alt="DeepFract Logo" />
  
  # DeepFract
  **AI-Enhanced Fractal Image Compression**

  [![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
  [![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?logo=Flutter&logoColor=white)](https://flutter.dev/)
  [![Next.js](https://img.shields.io/badge/Next.js-black?logo=next.js&logoColor=white)](https://nextjs.org/)
  [![Python](https://img.shields.io/badge/Python-3.10+-blue.svg?logo=python&logoColor=white)](https://www.python.org/)
  [![iOS Build](https://github.com/tony-saleeb/fractal-image-compression/actions/workflows/build-ipa.yml/badge.svg)](https://github.com/tony-saleeb/fractal-image-compression/actions)
</div>

<br />

DeepFract is an advanced image compression architecture bridging classic mathematical self-similarity principles with deep-learning synthesis logic gracefully. It offers state-of-the-art compression ratios by combining traditional Iterated Function Systems with cutting-edge AI post-processing.

## ✨ Features

- **Cross-Platform Client**: A beautiful, responsive Flutter mobile app for iOS and Android.
- **Web Application**: A fast, modern Next.js web interface for desktop users.
- **AI-Powered Compression**: Python-based backend that uses convolutional neural networks to intelligently compress and decompress images.
- **Quadtree Decomposition**: Dynamically handles image complexity to optimize compression ratios.
- **Firebase Integration**: Secure cloud storage, authentication, and database tracking.

## 🧠 The Complete AI Pipeline Guide

Imagine you are trying to recreate a large printed photograph using cut-up paper pieces.

### 1. Manual Fractal Matching (IFS - Iterated Function Systems)
* **What it does:** Finding repeated patterns by testing every option.
* **The Analogy:** Looking at every small square piece of paper and trying to find the perfect matching color on a giant poster manually.
* **The Downside:** Takes far too much time.

### 2. Fractal Pattern Predictor (CNN)
* **What it does:** Using baseline AI filters to find patterns quickly.
* **The Analogy:** An automatic sorter grabs the square pieces and puts them into rough piles by color.
* **The Downside:** It gets clumsy and blends the colors together, making the final picture blurry.

### 3. Structural Fractal Focus (ResNet)
* **What it does:** Advanced structural alignment calculations.
* **The Analogy:** The machine successfully aligns the photo pieces correctly onto the paper.
* **The Downside:** Once glued down, you can still clearly see the thin square cut lines between the pieces.

### 4. Adaptive Fractal Sizing (Quadtree Decomposition)
* **What it does:** Splitting simple areas from complex areas to save memory.
* **The Analogy:** Leaving simple areas (like sky) as huge paper squares, but cutting busy areas (like eyes) into tiny ones.
* **The Downside:** The jump between massive squares and tiny squares makes the cut lines look even harsher.

### 5. Final Fractal Error Eraser (CBAM AG-UNet)
* **What it does:** A generative AI network that removes digital noise using Convolutional Block Attention Modules and Attention Gate U-Net Post-Processing.
* **The Analogy:** Taking a special blending marker and painting over the borders to remove the seams completely.
* **The Downside:** Demands strong computer RAM to execute.

## 🎵 The "Orchestra" Framework

Instead of letting individual downsides block compression, the system uses the **"Orchestra" approach** to combine all benefits synchronously:

1. **Adaptive Quadtree** shrinks heavy details without wasting space.
2. **ResNet mappings** resolve coordinate variables instantly.
3. **CBAM AG-UNet filters** hide the borders successfully, resulting in a single high-fidelity image.

## 🚀 Getting Started

### Prerequisites
- [Flutter](https://docs.flutter.dev/get-started/install) SDK (`^3.7.0`)
- [Python](https://www.python.org/downloads/) 3.10+
- CocoaPods (for iOS compilation)

### Backend Configuration (Python)
The backend service handles the heavy lifting of the AI compression algorithms.
```bash
cd backend
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt
python manage.py runserver
```

### Mobile App Setup (Flutter)
The frontend connects to the backend and provides the user interface.
```bash
cd frontend
flutter pub get

# To run on an emulator or connected device:
flutter run

# To build for iOS (Requires macOS or GitHub Actions):
flutter build ios --release
```

### Web Application Setup (Next.js)
The browser-based interface for Fractal Compression.
```bash
cd frontend/web
npm install

# To run the development server:
npm run dev

# To build for production:
npm run build
```

## 🛠 Project Structure

```
├── backend/          # Python backend containing the AI pipeline models
├── frontend/         # Flutter mobile application
│   └── web/          # Next.js web application
├── build/            # Executable output directory
└── .github/          # CI/CD workflows for automated iOS builds
```

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
