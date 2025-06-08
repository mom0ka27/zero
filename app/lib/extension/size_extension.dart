extension SizeExtension on int {
  String get toMiB => (this / 1024 / 1024).toStringAsFixed(2);
  String get toGiB => (this / 1024 / 1024 / 1024).toStringAsFixed(2);
}
