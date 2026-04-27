import React from 'react';

export default function FAQPage() {
  return (
    <div className="space-y-8">
      <div className="border-b border-gray-500/20 pb-6 mb-8">
        <h1 className="text-3xl font-bold mb-2">Frequently Asked Questions</h1>
        <p className="opacity-60">Everything you need to know about DeepFract compression.</p>
      </div>

      <div className="space-y-6">
        <section>
          <h2 className="text-xl font-bold mb-3 text-blue-500">What is Neural Fractal Compression?</h2>
          <p className="opacity-80 leading-relaxed">
            Unlike traditional algorithms like JPEG or PNG that use discrete cosine transforms, DeepFract uses a deep neural network to map your image into a "latent space". It then stores this data as a proprietary `.fic` file, allowing extreme compression ratios while hallucinating lost details upon decompression.
          </p>
        </section>

        <section>
          <h2 className="text-xl font-bold mb-3 text-blue-500">Is there a file size limit?</h2>
          <p className="opacity-80 leading-relaxed">
            No! The application has been updated to remove the 50MB file size limit. You can upload images of any size. Extremely large images (e.g. 650MB+) are dynamically processed by the backend.
          </p>
        </section>

        <section>
          <h2 className="text-xl font-bold mb-3 text-blue-500">Why does decompression take so long?</h2>
          <p className="opacity-80 leading-relaxed">
            Reconstructing the image is a computationally heavy process. The AI engine runs millions of neural network calculations to upsample and synthesize the original details. Depending on your image size, this can take anywhere from a few seconds to several minutes.
          </p>
        </section>

        <section>
          <h2 className="text-xl font-bold mb-3 text-blue-500">How do I view a .fic file?</h2>
          <p className="opacity-80 leading-relaxed">
            `.fic` files are proprietary binary archives specifically designed for this application. To view the image inside, you must use the "Decompress" mode in this web app, or use our dedicated Desktop/Mobile apps to reconstruct the image back into a PNG.
          </p>
        </section>
      </div>
    </div>
  );
}
