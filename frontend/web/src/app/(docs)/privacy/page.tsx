import React from 'react';

export default function PrivacyPage() {
  return (
    <div className="space-y-8">
      <div className="border-b border-gray-500/20 pb-6 mb-8">
        <h1 className="text-3xl font-bold mb-2">Privacy Policy</h1>
        <p className="opacity-60">Last updated: April 2026</p>
      </div>

      <div className="space-y-6">
        <section>
          <h2 className="text-xl font-bold mb-3 text-blue-500">1. Data Processing</h2>
          <p className="opacity-80 leading-relaxed">
            When you use DeepFract, the images you upload are sent to our AI backend servers to be processed by the neural network. Once the compression or decompression task is completed and the file is returned to you, the image data is <strong>immediately discarded</strong> from our server memory. We do not store, log, or train on your personal images.
          </p>
        </section>

        <section>
          <h2 className="text-xl font-bold mb-3 text-blue-500">2. Local Storage</h2>
          <p className="opacity-80 leading-relaxed">
            We use your browser's local storage solely to remember your UI preferences, such as your Light/Dark mode choice, and whether you have already seen the introductory tutorial. We do not use cookies for tracking or advertising purposes.
          </p>
        </section>

        <section>
          <h2 className="text-xl font-bold mb-3 text-blue-500">3. Third-Party Services</h2>
          <p className="opacity-80 leading-relaxed">
            Our backend API is hosted on Hugging Face Spaces. As such, basic network traffic and server routing is handled by Hugging Face's infrastructure. Please refer to their privacy policy regarding network-level logging.
          </p>
        </section>
      </div>
    </div>
  );
}
