import React from 'react';

export default function HelpPage() {
  return (
    <div className="space-y-8">
      <div className="border-b border-gray-500/20 pb-6 mb-8">
        <h1 className="text-3xl font-bold mb-2">Help & Support</h1>
        <p className="opacity-60">Need assistance using DeepFract?</p>
      </div>

      <div className="space-y-6">
        <section>
          <h2 className="text-xl font-bold mb-3 text-blue-500">Getting Started</h2>
          <p className="opacity-80 leading-relaxed mb-4">
            If this is your first time using DeepFract, we highly recommend checking out our interactive tutorial. It will guide you through the compression and decompression process step-by-step.
          </p>
          <div className="p-4 bg-blue-500/10 border border-blue-500/20 rounded-xl">
            <strong>Pro Tip:</strong> You can always relaunch the tutorial by clicking the "Tutorial" button in the top navigation bar of the main page!
          </div>
        </section>

        <section>
          <h2 className="text-xl font-bold mb-3 text-blue-500">Troubleshooting: Upload Failing</h2>
          <p className="opacity-80 leading-relaxed">
            If your upload is failing or taking too long:
            <ul className="list-disc ml-6 mt-2 space-y-2">
              <li>Ensure you have a stable internet connection. The AI backend may take several minutes to process very large files.</li>
              <li>Wait patiently! The connection timeout has been extended to 60 minutes, so even if it looks like it's frozen, the server is still working hard in the background.</li>
              <li>Make sure you are uploading a valid image format (JPG, PNG, WebP) for Compression, or a valid `.fic` file for Decompression.</li>
            </ul>
          </p>
        </section>

        <section>
          <h2 className="text-xl font-bold mb-3 text-blue-500">Contact Us</h2>
          <p className="opacity-80 leading-relaxed">
            If you are still experiencing issues, please reach out to the development team on our GitHub repository.
          </p>
        </section>
      </div>
    </div>
  );
}
