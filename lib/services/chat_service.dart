import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/chat_message.dart';

/// Fully offline chatbot engine.
/// Always returns a reply — no network, no model required.
class ChatService extends ChangeNotifier {
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;
  final Random _rng = Random();

  ChatService() {
    _messages.add(ChatMessage(
      text: "Hi! I'm your offline AI assistant.\n\n"
          "I work completely offline and will always reply. "
          "Ask me anything, say hello, or just chat!",
      sender: MessageSender.bot,
    ));
  }

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isTyping => _isTyping;

  Future<void> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    // Add user message
    _messages.add(ChatMessage(text: trimmed, sender: MessageSender.user));
    notifyListeners();

    // Show typing
    _isTyping = true;
    notifyListeners();

    // Small delay so it feels natural
    await Future.delayed(Duration(milliseconds: 500 + _rng.nextInt(700)));

    // Always generate a reply
    final reply = _generateReply(trimmed);

    _isTyping = false;
    _messages.add(ChatMessage(text: reply, sender: MessageSender.bot));
    notifyListeners();
  }

  void clearChat() {
    _messages.clear();
    _messages.add(ChatMessage(
      text: "Chat cleared. I'm still here — what would you like to talk about?",
      sender: MessageSender.bot,
    ));
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Offline reply engine — always answers
  // ---------------------------------------------------------------------------
  String _generateReply(String input) {
    final lower = input.toLowerCase().trim();

    // Greetings
    if (_has(lower, ['hi', 'hello', 'hey', 'hola', 'yo', 'good morning',
        'good afternoon', 'good evening', 'sup', 'hiya'])) {
      return _pick([
        "Hello! Nice to meet you. How are you doing today?",
        "Hey there! What's on your mind?",
        "Hi! I'm ready to chat. What would you like to talk about?",
        "Hello! Great to hear from you. How can I help?",
      ]);
    }

    // How are you
    if (_has(lower, ['how are you', 'how r u', 'how do you feel',
        "how's it going", 'how are things'])) {
      return _pick([
        "I'm doing well, thanks for asking! Running happily offline on your device. How about you?",
        "Feeling good! Always happy to chat. What's new with you?",
        "I'm fine — and even better now that we're talking. How are you?",
      ]);
    }

    // Identity
    if (_has(lower, ['your name', 'who are you', 'what are you', 'who is this'])) {
      return "I'm an offline AI chatbot. I run entirely on your phone — "
          "no internet needed. I was built to always reply and keep the conversation going.";
    }

    // Help / capabilities
    if (_has(lower, ['help', 'what can you do', 'capabilities', 'commands'])) {
      return "I can chat about almost anything, answer simple questions, "
          "tell jokes, give encouragement, or just keep you company.\n\n"
          "Everything works offline. Just type and I'll reply!";
    }

    // Thanks
    if (_has(lower, ['thank', 'thanks', 'thx', 'appreciate', 'grateful'])) {
      return _pick([
        "You're welcome!",
        "Happy to help!",
        "Anytime — that's what I'm here for.",
        "Glad I could help!",
      ]);
    }

    // Bye
    if (_has(lower, ['bye', 'goodbye', 'see you', 'later', 'exit', 'quit'])) {
      return _pick([
        "Goodbye! Come back anytime.",
        "See you later — take care!",
        "Bye for now. I'll be here when you return.",
      ]);
    }

    // Feelings – negative
    if (_has(lower, ['sad', 'unhappy', 'depressed', 'lonely', 'stressed',
        'anxious', 'worried', 'tired', 'exhausted', 'angry', 'frustrated'])) {
      return _pick([
        "I'm sorry you're feeling that way. It's okay to have tough days. "
            "Want to talk more about it?",
        "That sounds hard. I'm here if you want to share more.",
        "I hear you. Taking a moment for yourself is important. "
            "Is there something specific weighing on you?",
      ]);
    }

    // Feelings – positive
    if (_has(lower, ['happy', 'excited', 'great', 'awesome', 'wonderful',
        'amazing', 'good', 'fantastic', 'love it'])) {
      return _pick([
        "That's wonderful to hear! What's making you feel so good?",
        "Awesome! Positive energy is contagious. Tell me more!",
        "I'm glad things are going well. Keep that momentum going!",
      ]);
    }

    // Jokes
    if (_has(lower, ['joke', 'funny', 'laugh', 'humor', 'make me laugh'])) {
      return _pick([
        "Why don't scientists trust atoms?\nBecause they make up everything!",
        "What do you call a fake noodle?\nAn impasta!",
        "Why did the scarecrow win an award?\nBecause he was outstanding in his field!",
        "I told my computer I needed a break…\nand now it won't stop sending me KitKat ads.",
        "Why do programmers prefer dark mode?\nBecause light attracts bugs!",
      ]);
    }

    // Weather (playful, offline)
    if (_has(lower, ['weather', 'rain', 'sunny', 'forecast', 'temperature'])) {
      return "I don't have live weather data (I'm fully offline), "
          "but I can help you plan for any kind of day. "
          "What's it like outside where you are?";
    }

    // Time / date
    if (_has(lower, ['time', 'date', 'what day', 'today'])) {
      final now = DateTime.now();
      return "Right now it's ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} "
          "on ${now.day}/${now.month}/${now.year}. "
          "Time flies when you're chatting!";
    }

    // Questions about the app / offline nature
    if (_has(lower, ['offline', 'internet', 'online', 'network', 'wifi'])) {
      return "Yes — I work 100% offline. No internet, no cloud, no data sent anywhere. "
          "Your chats stay on your device.";
    }

    // Short yes/no style
    if (lower == 'yes' || lower == 'yeah' || lower == 'yep' || lower == 'yup') {
      return _pick([
        "Great! What next?",
        "Awesome. Tell me more.",
        "Cool. I'm listening.",
      ]);
    }
    if (lower == 'no' || lower == 'nope' || lower == 'nah') {
      return _pick([
        "Okay, no problem. What else is on your mind?",
        "Fair enough. Want to talk about something different?",
        "Got it. I'm still here if you need me.",
      ]);
    }

    // Default – always reply with something useful / reflective
    return _pick([
      "Interesting — tell me more about that.",
      "I see. What else is on your mind?",
      "Thanks for sharing. How does that make you feel?",
      "Got it. Is there something specific you'd like help with?",
      "Hmm, that's worth thinking about. Want to go deeper on it?",
      "I'm listening. Feel free to say more.",
      "That makes sense. What's the next part of the story?",
      "Okay. How can I support you with this?",
    ]);
  }

  bool _has(String text, List<String> keywords) {
    return keywords.any((k) => text.contains(k));
  }

  String _pick(List<String> options) {
    return options[_rng.nextInt(options.length)];
  }
}
