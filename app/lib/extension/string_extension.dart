extension Empty on String? {
  bool get empty => this == null || this!.trim().isEmpty;
}
