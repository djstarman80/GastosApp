// Stub para dart:io en web
// Este archivo se usa cuando dart:html está disponible (web)

class File {
  final String path;
  File(this.path);
  
  Future<bool> exists() async => false;
  Future<String> readAsString() async => '';
  Future<void> writeAsString(String content) async {}
}
