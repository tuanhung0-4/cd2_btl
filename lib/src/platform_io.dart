// ...existing code...
// Platform implementation for IO-capable platforms
import 'dart:io' show Platform;

bool get isWindows => Platform.isWindows;
bool get isLinux => Platform.isLinux;
