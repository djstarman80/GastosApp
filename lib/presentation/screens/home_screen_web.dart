// Funciones web-only para backup
// Solo disponible en web

import 'dart:html' as html;

void downloadJson(String json, String filename) {
  final blob = html.Blob([json], 'application/json');
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: url)
    ..setAttribute('download', filename)
    ..click();
  html.Url.revokeObjectUrl(url);
}

Future<String?> uploadJson() async {
  final input = html.FileUploadInputElement();
  input.accept = '.json';
  input.click();

  await input.onChange.first;
  final file = input.files?.first;
  if (file == null) return null;

  final reader = html.FileReader();
  reader.readAsText(file);
  await reader.onLoad.first;

  return reader.result as String;
}
