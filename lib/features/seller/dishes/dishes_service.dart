import 'package:komi_fe/features/seller/dishes/dishes_item.dart';

class DishesService {
  Future<List<DetectedDish>> detectDishesFromImage(List<int> imageBytes) async {
    await Future<void>.delayed(const Duration(milliseconds: 900));
    return const [
      DetectedDish(name: 'Sopa de morón'),
      DetectedDish(name: 'Macarrones con Pollo'),
      DetectedDish(name: 'Ensalada de palta'),
      DetectedDish(name: 'Anticucho'),
    ];
  }
}
