import 'dart:io';

abstract class FileProcessor {
  const FileProcessor();
  static String typeOfFile(File file) {
    final fileName = file.path.split('/').last;
    final fileExtension = fileName.split('.').last;
    return fileExtension;
  }

  Set<String> get supportedFileTypes;
  Future<dynamic> process(File file);

  static final List<FileProcessor> _processors = [];

  static Future<dynamic> processFile(File file) async {
    for (FileProcessor processor in _processors) {
      if (processor.supportedFileTypes.contains(typeOfFile(file))) {
        return await processor.process(file);
      }
    }
    return null;
  }
}
