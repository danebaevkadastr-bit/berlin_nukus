/// AI chat javoblarini tozalash (emoji va ortiqcha bo'shliq).
class ChatSanitize {
  static final RegExp _emoji = RegExp(
    r'[\u{1F600}-\u{1F64F}\u{1F300}-\u{1F5FF}\u{1F680}-\u{1F6FF}\u{1F1E0}-\u{1F1FF}\u{2600}-\u{26FF}\u{2700}-\u{27BF}\u{FE0F}\u{200D}]',
    unicode: true,
  );

  static final RegExp _asciiEmoticon = RegExp(
    r'[:;8=][-~oO]?[)(/\\|DpP3<>]|[)(/\\|DpP3<>][-~oO]?[:;8=]',
  );

  static String clean(String text) {
    var s = text.replaceAll(_emoji, '');
    s = s.replaceAll(_asciiEmoticon, '');
    s = s.replaceAll(RegExp(r'\n{3,}'), '\n\n');
    s = s.replaceAll(RegExp(r'[ \t]{2,}'), ' ');
    return s.trim();
  }
}
