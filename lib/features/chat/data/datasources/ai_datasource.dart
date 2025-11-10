import 'package:google_generative_ai/google_generative_ai.dart';

abstract class AIDataSource {
  Future<String> getResponse(String userQuery, String pdfContext);
}

class GeminiAIDataSource implements AIDataSource {
  GeminiAIDataSource({String? apiKey}) : _apiKey = apiKey ?? 'AIzaSyA9d2d1dAPkRBkhgkmzNzjQtwx5duZ86zs';

  final String _apiKey;

  @override
  Future<String> getResponse(String userQuery, String pdfContext) async {
    final model = GenerativeModel(
      model: 'gemini-pro',
      apiKey: _apiKey,
    );

    final prompt = '''
Based on the following document text, please answer the user's question. If the answer is not found in the document, say so.

--- DOCUMENT TEXT ---
$pdfContext
--- END DOCUMENT TEXT ---

User's Question: $userQuery
''';

    final response = await model.generateContent([Content.text(prompt)]);
    return response.text?.trim().isNotEmpty == true
        ? response.text!.trim()
        : 'I could not generate a response.';
  }
}


