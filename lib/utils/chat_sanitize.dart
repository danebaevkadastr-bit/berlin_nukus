/// AI chat javoblarini tozalash (emoji va ortiqcha bo'shliq).
class ChatSanitize {
  static final RegExp _emoji = RegExp(
    r'[\p{Extended_Pictographic}\u{FE0F}\u{200D}]',
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
