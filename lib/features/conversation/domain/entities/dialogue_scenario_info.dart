import 'package:equatable/equatable.dart';

/// Metadata for pre-configured situational Hebrew dialogue scenarios.
class DialogueScenarioInfo extends Equatable {
  final String id;
  final String titleRussian;
  final String titleHebrew;
  final String emoji;
  final String level; // A1, A2, B1
  final String category;
  final String description;

  const DialogueScenarioInfo({
    required this.id,
    required this.titleRussian,
    required this.titleHebrew,
    required this.emoji,
    required this.level,
    required this.category,
    required this.description,
  });

  static const List<DialogueScenarioInfo> allScenarios = [
    DialogueScenarioInfo(
      id: 'node_market_start',
      titleRussian: 'Рынок Шук Кармель',
      titleHebrew: 'בַּשּׁוּק',
      emoji: '☕',
      level: 'A1',
      category: 'Еда и покупки',
      description: 'Заказ кофе, свежего сока манго и торг на колоритном рынке',
    ),
    DialogueScenarioInfo(
      id: 'node_cafe_start',
      titleRussian: 'Завтрак в кафе',
      titleHebrew: 'בְּבֵית קָפֶה',
      emoji: '🍳',
      level: 'A1',
      category: 'Еда и покупки',
      description: 'Столик на террасе, шакшука, сэндвич с авокадо и счет',
    ),
    DialogueScenarioInfo(
      id: 'node_taxi_start',
      titleRussian: 'Поездка на такси',
      titleHebrew: 'בַּמּוֹנִית',
      emoji: '🚕',
      level: 'A2',
      category: 'Город и быт',
      description: 'Поездка по городу, счетчик против фиксированной цены и пробки',
    ),
    DialogueScenarioInfo(
      id: 'node_pharmacy_start',
      titleRussian: 'В аптеке',
      titleHebrew: 'בְּבֵית מִרְקַחַת',
      emoji: '💊',
      level: 'A2',
      category: 'Здоровье',
      description: 'Лекарство от головной боли, пластыри, спрей и дозировка приема',
    ),
    DialogueScenarioInfo(
      id: 'node_hotel_start',
      titleRussian: 'Заселение в отель',
      titleHebrew: 'בַּמָּלוֹן',
      emoji: '🏨',
      level: 'A2',
      category: 'Город и быт',
      description: 'Бронь номера, ключ-карта, пароль от Wi-Fi и часы бассейна',
    ),
    DialogueScenarioInfo(
      id: 'node_meet_start',
      titleRussian: 'Знакомство в ульпане',
      titleHebrew: 'הֶכֵּרוּת בָּאֻלְפָּן',
      emoji: '👋',
      level: 'A1',
      category: 'Общение',
      description: 'Знакомство с одногруппником, профессия и кофе на перемене',
    ),
    DialogueScenarioInfo(
      id: 'node_supermarket_start',
      titleRussian: 'Касса в супермаркете',
      titleHebrew: 'בַּסּוּפֶּרְמַרְקֶט',
      emoji: '🛒',
      level: 'A1',
      category: 'Еда и покупки',
      description: 'Клубная карта, покупка пакетов, скидки, оплата и чек',
    ),
    DialogueScenarioInfo(
      id: 'node_clinic_start',
      titleRussian: 'В поликлинике (Купат Холим)',
      titleHebrew: 'בְּקֻפַּת חוֹלִים',
      emoji: '🏥',
      level: 'B1',
      category: 'Здоровье',
      description: 'Магнитная карта, запись к семейному врачу, лаборатория и талон',
    ),
    DialogueScenarioInfo(
      id: 'node_telaviv_coffee_start',
      titleRussian: 'Кофе в Тель-Авиве',
      titleHebrew: 'קָפֶה תֵּל־אָבִיבִי',
      emoji: '☕',
      level: 'A1',
      category: 'Еда и покупки',
      description: 'Кафе афух, овсяное молоко, выбор на вынос или здесь, оплата картой',
    ),
    DialogueScenarioInfo(
      id: 'node_shuk_carmel_start',
      titleRussian: 'Шук Кармель: Торг и вкусности',
      titleHebrew: 'שׂוּק הַכַּרְמֶל',
      emoji: '🍓',
      level: 'A2',
      category: 'Еда и покупки',
      description: 'Свежая клубника, халва с фисташками, торг за цену и подарки от торговца',
    ),
  ];

  @override
  List<Object?> get props => [
        id,
        titleRussian,
        titleHebrew,
        emoji,
        level,
        category,
        description,
      ];
}
