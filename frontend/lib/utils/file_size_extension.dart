extension FileSizeFormatter on int {
  /// Formats file size in bytes to human-readable format
  String toHumanReadableSize() {
    if (this < 1024) {
      return '$this B';
    } else if (this < 1024 * 1024) {
      return '${(this / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(this / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }
}
