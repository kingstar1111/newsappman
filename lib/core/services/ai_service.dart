import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:newsappman/core/constants/app_secrets.dart';

class AiService {
  static GenerativeModel? _model;

  static GenerativeModel get model {
    _model ??= GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: AppSecrets.geminiApiKey,
    );
    return _model!;
  }

  /// Summarize article content in the specified language
  static Future<String> summarizeArticle({
    required String content,
    required String language,
  }) async {
    if (AppSecrets.geminiApiKey == 'YOUR_GEMINI_API_KEY') {
      throw Exception('Please add your Gemini API key in app_secrets.dart');
    }

    final languageInstruction = switch (language) {
      'ar' => 'باللغة العربية',
      'tr' => 'Türkçe olarak',
      _ => 'in English',
    };

    final prompt = '''
Summarize the following article $languageInstruction in 3-5 bullet points. 
Keep it concise and highlight the key information.

Article content:
$content
''';

    try {
      final response = await model.generateContent([Content.text(prompt)]);
      return response.text ?? 'Unable to generate summary';
    } catch (e) {
      throw Exception('AI Error: $e');
    }
  }
}
