import React from 'react';

export default function TermsPage() {
  return (
    <div className="space-y-8">
      <div className="border-b border-gray-500/20 pb-6 mb-8">
        <h1 className="text-3xl font-bold mb-2">Terms of Service</h1>
        <p className="opacity-60">Last updated: April 2026</p>
      </div>

      <div className="space-y-6">
        <section>
          <h2 className="text-xl font-bold mb-3 text-blue-500">1. Acceptance of Terms</h2>
          <p className="opacity-80 leading-relaxed">
            By accessing and using the DeepFract web application, you accept and agree to be bound by the terms and provisions of this agreement. If you do not agree to abide by these terms, please do not use this service.
          </p>
        </section>

        <section>
          <h2 className="text-xl font-bold mb-3 text-blue-500">2. Description of Service</h2>
          <p className="opacity-80 leading-relaxed">
            DeepFract provides an experimental, AI-powered image compression and reconstruction tool. The service is provided "as is" and "as available". We do not guarantee perfect reconstruction of images, as the neural network relies on generative synthesis to restore latent data.
          </p>
        </section>

        <section>
          <h2 className="text-xl font-bold mb-3 text-blue-500">3. User Conduct</h2>
          <p className="opacity-80 leading-relaxed">
            You agree not to use the service to upload or transmit any material that is illegal, harmful, or infringes upon the rights of others. You are solely responsible for the images you upload to the DeepFract servers.
          </p>
        </section>

        <section>
          <h2 className="text-xl font-bold mb-3 text-blue-500">4. Modifications</h2>
          <p className="opacity-80 leading-relaxed">
            We reserve the right to modify or discontinue the service, temporarily or permanently, with or without notice to you. We shall not be liable to you or any third party for any modification, suspension, or discontinuance of the service.
          </p>
        </section>
      </div>
    </div>
  );
}
