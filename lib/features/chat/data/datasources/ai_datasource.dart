import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:http/http.dart' as http;

abstract class AIDataSource {
  Future<String> getResponse(String userQuery, String pdfContext);
}

class GeminiAIDataSource implements AIDataSource {
  GeminiAIDataSource({String? apiKey}) : _apiKey = apiKey ?? 'AIzaSyBcdh5OqRom3XKSS3lsZ1a8dQ1yU44MK34';

  final String _apiKey;

  Future<List<String>> _listModels(String version) async {
    final uri = Uri.parse('https://generativelanguage.googleapis.com/$version/models?key=$_apiKey');
    final res = await http.get(uri);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final json = jsonDecode(res.body) as Map<String, dynamic>;
      final models = (json['models'] as List<dynamic>? ?? [])
          .map((e) => (e as Map<String, dynamic>)['name'] as String)
          .toList();
      return models.map((m) => m.startsWith('models/') ? m.substring(7) : m).toList();
    } else {
      throw Exception('ListModels $version failed: ${res.statusCode} ${res.body}');
    }
  }

  Future<List<String>> _listAllAvailableModels() async {
    final results = <String>{};
    try {
      results.addAll(await _listModels('v1beta'));
    } catch (_) {}
    try {
      results.addAll(await _listModels('v1'));
    } catch (_) {}
    return results.toList();
  }

  @override
  Future<String> getResponse(String userQuery, String pdfContext) async {
    // Базовый приоритет (короткие имена)
    final preferred = <String>[
      'gemini-2.5-flash',
      'gemini-1.5-flash-latest',
      'gemini-1.5-flash',
      'gemini-1.5-pro-latest',
      'gemini-1.5-pro',
      'gemini-1.0-pro',
      'gemini-pro',
    ];

    final prompt = '''
Based on the following document text, please answer the user's question. If the answer is not found in the document, say so.

--- DOCUMENT TEXT ---
$pdfContext
--- END DOCUMENT TEXT ---

User's Question: $userQuery
''';

    String? lastErrorMessage;
    // Сначала попытаемся получить список доступных моделей для ключа и пересечь с приоритетом
    List<String> candidates;
    try {
      final available = await _listAllAvailableModels();
      final prioritized = preferred.where((m) => available.contains(m)).toList();
      candidates = prioritized.isEmpty ? preferred : prioritized;
    } catch (e) {
      candidates = preferred;
      lastErrorMessage = 'ListModels failed: $e';
    }

    for (final modelName in candidates) {
      try {
        final model = GenerativeModel(
          model: modelName,
          apiKey: _apiKey,
        );
        final response = await model.generateContent([Content.text(prompt)]);
        final text = response.text?.trim();
        if (text != null && text.isNotEmpty) {
          return text;
        }
      } catch (e) {
        lastErrorMessage = '($modelName) $e';
        continue;
      }
    }
    return lastErrorMessage ??
        'I could not generate a response. All model attempts failed.';
  }
}


