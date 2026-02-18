// Stub para funciones web-only en plataformas no-web
// Este archivo se usa cuando dart:html no está disponible (Windows, Android, etc.)

void downloadJson(String json, String filename) {
  // Stub - no-op en no-web
}

Future<String?> uploadJson() async {
  // Stub - retorna null en no-web
  return null;
}
