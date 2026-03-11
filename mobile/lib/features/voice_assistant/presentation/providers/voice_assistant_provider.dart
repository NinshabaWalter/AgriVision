import 'package:flutter_riverpod/flutter_riverpod.dart';

class VoiceAssistantNotifier extends StateNotifier<VoiceAssistantState> {
  VoiceAssistantNotifier() : super(VoiceAssistantState.initial());

  String processCommand(String command, String language) {
    final lowerCommand = command.toLowerCase();
    
    // Weather-related queries
    if (_containsAny(lowerCommand, _getWeatherKeywords(language))) {
      return _getWeatherResponse(language);
    }
    
    // Price-related queries
    if (_containsAny(lowerCommand, _getPriceKeywords(language))) {
      return _getPriceResponse(command, language);
    }
    
    // Disease-related queries
    if (_containsAny(lowerCommand, _getDiseaseKeywords(language))) {
      return _getDiseaseResponse(language);
    }
    
    // Farming advice queries
    if (_containsAny(lowerCommand, _getFarmingKeywords(language))) {
      return _getFarmingResponse(language);
    }
    
    // Market information
    if (_containsAny(lowerCommand, _getMarketKeywords(language))) {
      return _getMarketResponse(language);
    }
    
    // Loan and finance queries
    if (_containsAny(lowerCommand, _getFinanceKeywords(language))) {
      return _getFinanceResponse(language);
    }
    
    // Default response
    return _getDefaultResponse(language);
  }

  List<String> _getWeatherKeywords(String language) {
    switch (language) {
      case 'sw-TZ':
        return ['hali ya hewa', 'mvua', 'jua', 'upepo', 'baridi', 'joto', 'hewa'];
      case 'am-ET':
        return ['የአየር ሁኔታ', 'ዝናብ', 'ፀሐይ', 'ንፋስ', 'ቀዝቃዛ', 'ሞቃት'];
      case 'fr-FR':
        return ['météo', 'temps', 'pluie', 'soleil', 'vent', 'froid', 'chaud', 'climat'];
      default:
        return ['weather', 'rain', 'sun', 'wind', 'temperature', 'forecast', 'climate'];
    }
  }

  List<String> _getPriceKeywords(String language) {
    switch (language) {
      case 'sw-TZ':
        return ['bei', 'gharama', 'mahindi', 'maharage', 'kahawa', 'chai', 'mazao'];
      case 'am-ET':
        return ['ዋጋ', 'ወጪ', 'በቆሎ', 'ባቄላ', 'ቡና', 'ሻይ', 'ሰብሎች'];
      case 'fr-FR':
        return ['prix', 'coût', 'maïs', 'haricots', 'café', 'thé', 'récoltes'];
      default:
        return ['price', 'cost', 'maize', 'corn', 'beans', 'coffee', 'tea', 'crops'];
    }
  }

  List<String> _getDiseaseKeywords(String language) {
    switch (language) {
      case 'sw-TZ':
        return ['ugonjwa', 'magonjwa', 'wadudu', 'kuoza', 'kunyauka', 'majani'];
      case 'am-ET':
        return ['በሽታ', 'በሽታዎች', 'ተባዮች', 'መበሳጨት', 'መሽመድ'];
      case 'fr-FR':
        return ['maladie', 'maladies', 'parasite', 'infection', 'flétrissement', 'pourriture'];
      default:
        return ['disease', 'pest', 'infection', 'sick', 'dying', 'leaves', 'spots'];
    }
  }

  List<String> _getFarmingKeywords(String language) {
    switch (language) {
      case 'sw-TZ':
        return ['kilimo', 'kupanda', 'mavuno', 'mbegu', 'mbolea', 'umwagiliaji'];
      case 'am-ET':
        return ['ግብርና', 'መዝራት', 'መሰብሰብ', 'ዘር', 'ማዳበሪያ', 'መስኖ'];
      case 'fr-FR':
        return ['agriculture', 'planter', 'récolte', 'graines', 'engrais', 'irrigation'];
      default:
        return ['farming', 'planting', 'harvest', 'seeds', 'fertilizer', 'irrigation'];
    }
  }

  List<String> _getMarketKeywords(String language) {
    switch (language) {
      case 'sw-TZ':
        return ['soko', 'mnunuzi', 'muuzaji', 'biashara', 'ununuzi'];
      case 'am-ET':
        return ['ገበያ', 'ግዢ', 'ሸጣ', 'ንግድ', 'መግዛት'];
      case 'fr-FR':
        return ['marché', 'achat', 'vente', 'commerce', 'acheter'];
      default:
        return ['market', 'buy', 'sell', 'trade', 'buyer', 'seller'];
    }
  }

  List<String> _getFinanceKeywords(String language) {
    switch (language) {
      case 'sw-TZ':
        return ['mkopo', 'mikopo', 'benki', 'bima', 'fedha', 'akiba'];
      case 'am-ET':
        return ['ብድር', 'ብድሮች', 'ባንክ', 'ኢንሹራንስ', 'ገንዘብ', 'ቁጠባ'];
      case 'fr-FR':
        return ['crédit', 'prêt', 'banque', 'assurance', 'argent', 'épargne'];
      default:
        return ['loan', 'credit', 'bank', 'insurance', 'money', 'finance'];
    }
  }

  String _getWeatherResponse(String language) {
    switch (language) {
      case 'sw-TZ':
        return 'Hali ya hewa ya leo ni nzuri kwa kilimo. Joto ni nyongeza 25, na mvua inatarajia kesho. Ni wakati mzuri wa kupanda mazao ya misimu mfupi.';
      case 'am-ET':
        return 'የዛሬው የአየር ሁኔታ ለግብርና ጥሩ ነው። የሙቀት መጠኑ 25 ዲግሪ ነው፣ ነገ ዝናብ ይጠበቃል። የአጭር ጊዜ ሰብሎችን ለመዝራት ጥሩ ጊዜ ነው።';
      case 'fr-FR':
        return 'Le temps d\'aujourd\'hui est bon pour l\'agriculture. Il fait 25 degrés et de la pluie est prévue demain. C\'est un bon moment pour planter des cultures à cycle court.';
      default:
        return 'Today\'s weather is good for farming. Temperature is 25°C with rain expected tomorrow. It\'s a good time to plant short-season crops.';
    }
  }

  String _getPriceResponse(String command, String language) {
    // Extract crop type from command and provide relevant price information
    switch (language) {
      case 'sw-TZ':
        return 'Bei za mazao za leo: Mahindi - KES 45 kwa kilo, Maharage - KES 150 kwa kilo, Kahawa - KES 280 kwa kilo. Bei za mahindi zimepanda kwa asilimia 5 wiki hii.';
      case 'am-ET':
        return 'የዛሬ የሰብል ዋጋዎች፡ በቆሎ - 45 ብር በኪሎ፣ ባቄላ - 150 ብር በኪሎ፣ ቡና - 280 ብር በኪሎ። የበቆሎ ዋጋ በዚህ ሳምንት 5 ፐርሰንት ጨምሯል።';
      case 'fr-FR':
        return 'Prix des cultures aujourd\'hui: Maïs - 45 KES par kilo, Haricots - 150 KES par kilo, Café - 280 KES par kilo. Les prix du maïs ont augmenté de 5% cette semaine.';
      default:
        return 'Today\'s crop prices: Maize - KES 45 per kg, Beans - KES 150 per kg, Coffee - KES 280 per kg. Maize prices are up 5% this week.';
    }
  }

  String _getDiseaseResponse(String language) {
    switch (language) {
      case 'sw-TZ':
        return 'Kwa kupima magonjwa ya mimea, piga picha ya jani la mmea na litumie kipengele cha uchunguzi wa magonjwa. Pia, hakikisha umwagiliaji ni sahihi na usitumie mbolea nyingi zaidi.';
      case 'am-ET':
        return 'የተክል በሽታዎችን ለመፈተሽ የተክሉን ቅጠል ፎቶ አንሡ እና የበሽታ ፍተሻ ባህሪን ይጠቀሙ። እንዲሁም ተገቢ መስኖ እና ከመጠን ያላሰፋ ማዳበሪያ እንዲኖር ያረጋግጡ።';
      case 'fr-FR':
        return 'Pour diagnostiquer les maladies des plantes, prenez une photo de la feuille et utilisez la fonction de détection des maladies. Assurez-vous aussi d\'un arrosage approprié et évitez l\'excès d\'engrais.';
      default:
        return 'To diagnose plant diseases, take a photo of the leaf and use the disease detection feature. Also ensure proper watering and avoid over-fertilizing.';
    }
  }

  String _getFarmingResponse(String language) {
    switch (language) {
      case 'sw-TZ':
        return 'Kwa mwezi huu, inashauriwa kupanda mahindi na maharage. Tumia mbegu zilizo tayari na mbolea ya asili. Hakikisha udongo una unyevunyevu wa kutosha kabla ya kupanda.';
      case 'am-ET':
        return 'በዚህ ወር በቆሎ እና ባቄላ መዝራት ይመከራል። የተሰናዳ ዘሮችና ተፈጥሯዊ ማዳበሪያ ይጠቀሙ። ከመዝራትዎ በፊት አፈሩ በቂ እርጥበት እንዳለው ያረጋግጡ።';
      case 'fr-FR':
        return 'Ce mois-ci, il est recommandé de planter du maïs et des haricots. Utilisez des semences préparées et de l\'engrais organique. Assurez-vous que le sol a suffisamment d\'humidité avant de planter.';
      default:
        return 'This month, it\'s recommended to plant maize and beans. Use prepared seeds and organic fertilizer. Ensure soil has adequate moisture before planting.';
    }
  }

  String _getMarketResponse(String language) {
    switch (language) {
      case 'sw-TZ':
        return 'Katika soko la leo, kuna mahitaji makubwa ya mahindi na kahawa. Wanunuzi wa nje wanaangalia mazao ya kikaboni. Inashauriwa kuuza mazao yako mapema asubuhi ili kupata bei nzuri zaidi.';
      case 'am-ET':
        return 'በዛሬው ገበያ ላይ ለበቆሎ እና ቡና ከፍተኛ ፍላጎት አለ። የውጭ ገዥዎች ኦርጋኒክ ምርቶችን እየፈለጉ ነው። ጥሩ ዋጋ ለማግኘት ምርትዎን ማለዳ መሸጥ ይመከራል።';
      case 'fr-FR':
        return 'Sur le marché aujourd\'hui, il y a une forte demande pour le maïs et le café. Les acheteurs étrangers recherchent des produits biologiques. Il est recommandé de vendre vos produits tôt le matin pour obtenir de meilleurs prix.';
      default:
        return 'In today\'s market, there\'s high demand for maize and coffee. International buyers are looking for organic produce. It\'s recommended to sell your crops early morning for better prices.';
    }
  }

  String _getFinanceResponse(String language) {
    switch (language) {
      case 'sw-TZ':
        return 'Kuna mikopo maalumu kwa wakulima inayopatikana kwa riba ya chini ya asilimia 8. Pia, bima ya mazao inapatikana kulinda dhidi ya madhara ya hali mbaya ya hewa. Wasiliana na ofisi za kilimo za kata kwa maelezo zaidi.';
      case 'am-ET':
        return 'ለገበሬዎች ዝቅተኛ የወለድ መጠን፣ ከ8 ፐርሰንት በታች ልዩ ብድሮች አሉ። እንዲሁም የመጥፎ የአየር ሁኔታ ጉዳት ለመከላከል የሰብል ኢንሹራንስ አለ። ለበለጠ መረጃ የወረዳ ግብርና ቢሮዎችን ያነጋግሩ።';
      case 'fr-FR':
        return 'Il existe des prêts spéciaux pour les agriculteurs avec des taux d\'intérêt faibles, inférieurs à 8%. Il y a aussi une assurance récolte disponible pour protéger contre les dommages météorologiques. Contactez les bureaux agricoles locaux pour plus d\'informations.';
      default:
        return 'Special farmer loans are available with low interest rates below 8%. Crop insurance is also available to protect against weather damage. Contact local agricultural offices for more information.';
    }
  }

  String _getDefaultResponse(String language) {
    switch (language) {
      case 'sw-TZ':
        return 'Samahani, sikuelewa vizuri. Je, unaweza kuuliza kuhusu hali ya hewa, bei za mazao, magonjwa ya mimea, ushauri wa kilimo, au huduma za kifedha?';
      case 'am-ET':
        return 'ይቅርታ፣ በደንብ አልገባኝም። ስለ የአየር ሁኔታ፣ የሰብል ዋጋዎች፣ የተክል በሽታዎች፣ የግብርና ምክር ወይም የፋይናንስ አገልግሎቶች መጠየቅ ይችላሉ?';
      case 'fr-FR':
        return 'Désolé, je n\'ai pas bien compris. Pouvez-vous poser des questions sur la météo, les prix des cultures, les maladies des plantes, les conseils agricoles ou les services financiers?';
      default:
        return 'Sorry, I didn\'t understand that well. You can ask about weather, crop prices, plant diseases, farming advice, or financial services.';
    }
  }

  bool _containsAny(String text, List<String> keywords) {
    return keywords.any((keyword) => text.contains(keyword));
  }
}

class VoiceAssistantState {
  final bool isListening;
  final String lastCommand;
  final String lastResponse;

  VoiceAssistantState({
    required this.isListening,
    required this.lastCommand,
    required this.lastResponse,
  });

  factory VoiceAssistantState.initial() {
    return VoiceAssistantState(
      isListening: false,
      lastCommand: '',
      lastResponse: '',
    );
  }

  VoiceAssistantState copyWith({
    bool? isListening,
    String? lastCommand,
    String? lastResponse,
  }) {
    return VoiceAssistantState(
      isListening: isListening ?? this.isListening,
      lastCommand: lastCommand ?? this.lastCommand,
      lastResponse: lastResponse ?? this.lastResponse,
    );
  }
}

final voiceAssistantProvider = StateNotifierProvider<VoiceAssistantNotifier, VoiceAssistantState>(
  (ref) => VoiceAssistantNotifier(),
);