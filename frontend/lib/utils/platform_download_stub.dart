/// Stub for non-web platforms — mobile uses path_provider instead.
Future<void> downloadBytesAsFile(List<int> bytes, String filename) async {
  throw UnsupportedError(
      'Web download not available on this platform. Use path_provider instead.');
}
