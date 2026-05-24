import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';

class ChatMessage {
  final String role; // 'user' | 'assistant'
  final String content;
  final DateTime timestamp;

  ChatMessage({
    required this.role,
    required this.content,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

class ChatProvider extends ChangeNotifier {
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isTyping => _isTyping;

  Future<void> sendMessage({
    required String userMessage,
    required UserModel user,
    required int caloriesEaten,
    required int caloriesBurned,
    required double carbsToday,
    required double proteinToday,
    required double fatToday,
  }) async {
    _messages.add(ChatMessage(role: 'user', content: userMessage));
    _isTyping = true;
    notifyListeners();

    final systemPrompt = '''Kamu adalah NutriBot, asisten nutrisi personal yang ramah dan suportif untuk aplikasi NutriSee.

Data pengguna saat ini:
- Nama: ${user.name}
- Umur: ${user.age} tahun
- Berat: ${user.weight} kg | Tinggi: ${user.height} cm
- Target berat: ${user.targetWeight} kg
- BMI: ${user.bmi.toStringAsFixed(1)} (${user.bmiCategory})
- Target kalori harian: ${user.targetCalories} kkal
- Target karbo: ${user.targetCarbs}g | Protein: ${user.targetProtein}g | Lemak: ${user.targetFat}g

Progress hari ini:
- Kalori dikonsumsi: $caloriesEaten kkal dari ${user.targetCalories} kkal
- Kalori terbakar dari aktivitas: $caloriesBurned kkal
- Karbo: ${carbsToday.toStringAsFixed(1)}g | Protein: ${proteinToday.toStringAsFixed(1)}g | Lemak: ${fatToday.toStringAsFixed(1)}g

Tugasmu:
1. Jawab pertanyaan seputar nutrisi, diet, dan kesehatan dengan ramah dalam Bahasa Indonesia
2. Berikan rekomendasi makanan yang cocok dengan kondisi pengguna
3. Analisis progress harian dan berikan feedback yang memotivasi
4. Ingatkan target jika ada yang kurang atau berlebihan
5. Berikan tips praktis yang bisa langsung diterapkan
6. Jika ada tren negatif (kalori berlebih, nutrisi kurang), berikan saran perbaikan
Jawab dengan singkat, jelas, dan tidak lebih dari 3 paragraf kecuali diminta detail.''';

    try {
      final history = _messages
          .where((m) => m.role != 'assistant' || _messages.indexOf(m) > _messages.length - 10)
          .take(10)
          .map((m) => {'role': m.role, 'content': m.content})
          .toList();

      final response = await http.post(
        Uri.parse('https://api.anthropic.com/v1/messages'),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': 'YOUR_CLAUDE_API_KEY',
          'anthropic-version': '2023-06-01',
        },
        body: jsonEncode({
          'model': 'claude-sonnet-4-20250514',
          'max_tokens': 1000,
          'system': systemPrompt,
          'messages': history,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final reply = data['content'][0]['text'] as String;
        _messages.add(ChatMessage(role: 'assistant', content: reply));
      } else {
        _messages.add(ChatMessage(
          role: 'assistant',
          content: 'Maaf, aku sedang tidak bisa menjawab. Coba lagi ya! 😊',
        ));
      }
    } catch (_) {
      _messages.add(ChatMessage(
        role: 'assistant',
        content: 'Koneksi bermasalah. Pastikan internet kamu aktif ya!',
      ));
    } finally {
      _isTyping = false;
      notifyListeners();
    }
  }

  void clearChat() {
    _messages.clear();
    notifyListeners();
  }
}