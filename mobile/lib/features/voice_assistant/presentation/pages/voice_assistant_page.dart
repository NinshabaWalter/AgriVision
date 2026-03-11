import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../providers/voice_assistant_provider.dart';
import '../widgets/voice_command_button.dart';
import '../widgets/conversation_bubble.dart';

class VoiceAssistantPage extends ConsumerStatefulWidget {
  const VoiceAssistantPage({super.key});

  @override
  ConsumerState<VoiceAssistantPage> createState() => _VoiceAssistantPageState();
}

class _VoiceAssistantPageState extends ConsumerState<VoiceAssistantPage>
    with TickerProviderStateMixin {
  late SpeechToText _speechToText;
  late FlutterTts _flutterTts;
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;
  
  bool _isListening = false;
  bool _isInitialized = false;
  String _selectedLanguage = 'en-US'; // Default to English
  
  final List<VoiceCommand> _conversation = [];
  final ScrollController _scrollController = ScrollController();

  final Map<String, String> _supportedLanguages = {
    'en-US': 'English',
    'sw-TZ': 'Swahili',
    'am-ET': 'Amharic',
    'fr-FR': 'French',
  };

  @override
  void initState() {
    super.initState();
    _initializeVoiceServices();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _initializeVoiceServices() async {
    _speechToText = SpeechToText();
    _flutterTts = FlutterTts();

    // Initialize speech-to-text
    bool available = await _speechToText.initialize(
      onStatus: (status) => _onSpeechStatus(status),
      onError: (error) => _onSpeechError(error),
    );

    // Initialize text-to-speech
    await _flutterTts.setLanguage(_selectedLanguage.split('-')[0]);
    await _flutterTts.setSpeechRate(0.8);
    await _flutterTts.setVolume(1.0);

    setState(() {
      _isInitialized = available;
    });

    if (_isInitialized) {
      _speak(_getWelcomeMessage());
    }
  }

  String _getWelcomeMessage() {
    switch (_selectedLanguage) {
      case 'sw-TZ':
        return 'Karibu! Mimi ni msaidizi wako wa kilimo. Unaweza kuniuliza kuhusu kilimo, bei za mazao, hali ya hewa, au magonjwa ya mimea.';
      case 'am-ET':
        return 'እንኳን ደህና መጡ! እኔ የእርስዎ የግብርና አስተዳደር ሰው ነኝ። ስለ ግብርና፣ የሰብል ዋጋዎች፣ የአየር ሁኔታ ወይም የተክል በሽታዎች መጠየቅ ይችላሉ።';
      case 'fr-FR':
        return 'Bienvenue! Je suis votre assistant agricole. Vous pouvez me poser des questions sur l\'agriculture, les prix des cultures, la météo ou les maladies des plantes.';
      default:
        return 'Welcome! I\'m your agricultural assistant. You can ask me about farming, crop prices, weather, or plant diseases.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voice Assistant'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.language),
            onSelected: _changeLanguage,
            itemBuilder: (context) => _supportedLanguages.entries
                .map((entry) => PopupMenuItem<String>(
                      value: entry.key,
                      child: Text(entry.value),
                    ))
                .toList(),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildLanguageSelector(),
          Expanded(
            child: _buildConversation(),
          ),
          _buildVoiceControls(),
          _buildQuickActions(),
        ],
      ),
    );
  }

  Widget _buildLanguageSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.language, color: Colors.green),
          const SizedBox(width: 12),
          const Text('Language: ', style: TextStyle(fontWeight: FontWeight.bold)),
          DropdownButton<String>(
            value: _selectedLanguage,
            underline: const SizedBox(),
            items: _supportedLanguages.entries
                .map((entry) => DropdownMenuItem<String>(
                      value: entry.key,
                      child: Text(entry.value),
                    ))
                .toList(),
            onChanged: (value) => _changeLanguage(value!),
          ),
        ],
      ),
    );
  }

  Widget _buildConversation() {
    if (_conversation.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.mic,
              size: 64,
              color: Theme.of(context).primaryColor.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              _getStartConversationText(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.7),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _conversation.length,
      itemBuilder: (context, index) {
        final command = _conversation[index];
        return ConversationBubble(command: command);
      },
    );
  }

  Widget _buildVoiceControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _isListening ? _pulseAnimation.value : 1.0,
                child: VoiceCommandButton(
                  icon: _isListening ? Icons.mic : Icons.mic_none,
                  label: _isListening ? 'Listening...' : 'Tap to Speak',
                  color: _isListening ? Colors.red : Theme.of(context).primaryColor,
                  onPressed: _isInitialized ? _toggleListening : null,
                ),
              );
            },
          ),
          VoiceCommandButton(
            icon: Icons.stop,
            label: 'Stop',
            color: Colors.grey,
            onPressed: _stopListening,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    final quickActions = _getQuickActions();
    
    return Container(
      height: 120,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Commands',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: quickActions.length,
              itemBuilder: (context, index) {
                final action = quickActions[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ActionChip(
                    avatar: Icon(action['icon'] as IconData, size: 16),
                    label: Text(
                      action['text'] as String,
                      style: const TextStyle(fontSize: 12),
                    ),
                    onPressed: () => _handleQuickAction(action['command'] as String),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getQuickActions() {
    switch (_selectedLanguage) {
      case 'sw-TZ':
        return [
          {'icon': Icons.wb_sunny, 'text': 'Hali ya Hewa', 'command': 'Niambie hali ya hewa leo'},
          {'icon': Icons.trending_up, 'text': 'Bei za Mazao', 'command': 'Bei za mahindi ni ngapi?'},
          {'icon': Icons.healing, 'text': 'Magonjwa', 'command': 'Mmea wangu una ugonjwa'},
        ];
      case 'am-ET':
        return [
          {'icon': Icons.wb_sunny, 'text': 'የአየር ሁኔታ', 'command': 'የዛሬ የአየር ሁኔታ ንገረኝ'},
          {'icon': Icons.trending_up, 'text': 'የሰብል ዋጋ', 'command': 'የሰሊጥ ዋጋ ስንት ነው?'},
          {'icon': Icons.healing, 'text': 'በሽታዎች', 'command': 'ተክሉ በሽታ አለበት'},
        ];
      case 'fr-FR':
        return [
          {'icon': Icons.wb_sunny, 'text': 'Météo', 'command': 'Dis-moi la météo d\'aujourd\'hui'},
          {'icon': Icons.trending_up, 'text': 'Prix', 'command': 'Quel est le prix du maïs?'},
          {'icon': Icons.healing, 'text': 'Maladies', 'command': 'Ma plante a une maladie'},
        ];
      default:
        return [
          {'icon': Icons.wb_sunny, 'text': 'Weather', 'command': 'What\'s the weather today?'},
          {'icon': Icons.trending_up, 'text': 'Prices', 'command': 'What\'s the price of maize?'},
          {'icon': Icons.healing, 'text': 'Diseases', 'command': 'My plant has a disease'},
        ];
    }
  }

  String _getStartConversationText() {
    switch (_selectedLanguage) {
      case 'sw-TZ':
        return 'Bofya kitufe cha mazungumzo ili kuanza kuongea nami. Unaweza kuuliza kuhusu kilimo, bei za mazao, hali ya hewa, au magonjwa ya mimea.';
      case 'am-ET':
        return 'ከእኔ ጋር ለማነጋገር የንግግር ቁልፉን ተጫን። ስለ ግብርና፣ የሰብል ዋጋዎች፣ የአየር ሁኔታ ወይም የተክል በሽታዎች መጠየቅ ይችላሉ።';
      case 'fr-FR':
        return 'Appuyez sur le bouton vocal pour commencer à me parler. Vous pouvez poser des questions sur l\'agriculture, les prix des cultures, la météo ou les maladies des plantes.';
      default:
        return 'Tap the voice button to start talking to me. You can ask about farming, crop prices, weather, or plant diseases.';
    }
  }

  void _toggleListening() async {
    if (_isListening) {
      await _stopListening();
    } else {
      await _startListening();
    }
  }

  Future<void> _startListening() async {
    if (!_isInitialized) return;

    setState(() => _isListening = true);
    
    await _speechToText.listen(
      onResult: (result) => _onSpeechResult(result.recognizedWords),
      listenFor: const Duration(seconds: 10),
      pauseFor: const Duration(seconds: 3),
      localeId: _selectedLanguage,
    );
  }

  Future<void> _stopListening() async {
    setState(() => _isListening = false);
    await _speechToText.stop();
  }

  void _onSpeechResult(String recognizedWords) {
    if (recognizedWords.isNotEmpty) {
      _addUserMessage(recognizedWords);
      _processVoiceCommand(recognizedWords);
    }
  }

  void _onSpeechStatus(String status) {
    if (status == 'done' || status == 'notListening') {
      setState(() => _isListening = false);
    }
  }

  void _onSpeechError(dynamic error) {
    setState(() => _isListening = false);
    _addAssistantMessage('Sorry, I didn\'t catch that. Please try again.');
  }

  void _changeLanguage(String languageCode) async {
    setState(() => _selectedLanguage = languageCode);
    await _flutterTts.setLanguage(languageCode.split('-')[0]);
    _speak(_getWelcomeMessage());
  }

  void _handleQuickAction(String command) {
    _addUserMessage(command);
    _processVoiceCommand(command);
  }

  void _processVoiceCommand(String command) {
    final response = ref.read(voiceAssistantProvider).processCommand(command, _selectedLanguage);
    _addAssistantMessage(response);
    _speak(response);
  }

  void _addUserMessage(String message) {
    setState(() {
      _conversation.add(VoiceCommand(
        text: message,
        isUser: true,
        timestamp: DateTime.now(),
        language: _selectedLanguage,
      ));
    });
    _scrollToBottom();
  }

  void _addAssistantMessage(String message) {
    setState(() {
      _conversation.add(VoiceCommand(
        text: message,
        isUser: false,
        timestamp: DateTime.now(),
        language: _selectedLanguage,
      ));
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _speak(String text) async {
    await _flutterTts.speak(text);
  }
}

class VoiceCommand {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final String language;

  VoiceCommand({
    required this.text,
    required this.isUser,
    required this.timestamp,
    required this.language,
  });
}