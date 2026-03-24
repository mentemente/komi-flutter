import 'package:flutter/material.dart';
import 'package:komi_fe/core/constants/app_colors.dart';
import 'package:komi_fe/core/theme/app_text_styles.dart';
import 'package:komi_fe/features/seller/daily_menu/daily_menu_item.dart';
import 'package:komi_fe/features/seller/daily_menu/widgets/daily_menu_section.dart';

class DailyMenuPage extends StatefulWidget {
  const DailyMenuPage({super.key});

  @override
  State<DailyMenuPage> createState() => _DailyMenuPageState();
}

class _DailyMenuPageState extends State<DailyMenuPage> {
  late List<DailyMenuItem> _menuItems;
  late List<DailyMenuItem> _platosItems;

  @override
  void initState() {
    super.initState();
    // TODO: change this to get the items from the API
    _menuItems = [
      DailyMenuItem(
        name: 'Tequeños',
        stock: 20,
        isActive: true,
        type: MenuItemType.entrada,
      ),
      DailyMenuItem(
        name: 'Papa a la huancaina',
        stock: 17,
        isActive: true,
        type: MenuItemType.entrada,
      ),
      DailyMenuItem(
        name: 'Arroz con pollo',
        price: 12,
        stock: 15,
        isActive: true,
        type: MenuItemType.platoSegundo,
      ),
      DailyMenuItem(
        name: 'Seco de frejoles',
        price: 13,
        stock: 12,
        isActive: true,
        type: MenuItemType.platoSegundo,
      ),
      DailyMenuItem(
        name: 'Arroz con pollo',
        price: 12,
        stock: 8,
        isActive: true,
        type: MenuItemType.platoSegundo,
      ),
      DailyMenuItem(
        name: 'Seco de frejoles',
        price: 13,
        stock: 10,
        isActive: true,
        type: MenuItemType.platoSegundo,
      ),
    ];
    _platosItems = [
      DailyMenuItem(
        name: 'Lomo saltado',
        price: 17,
        stock: 20,
        isActive: true,
        type: MenuItemType.platoALaCarta,
      ),
      DailyMenuItem(
        name: 'Tallarines verdes con corazon frito',
        price: 20,
        stock: 17,
        isActive: true,
        type: MenuItemType.platoALaCarta,
      ),
      DailyMenuItem(
        name: 'Anticuchos',
        price: 18,
        stock: 14,
        isActive: true,
        type: MenuItemType.platoALaCarta,
      ),
      DailyMenuItem(
        name: 'Carapulcra con Sopaseca',
        price: 25,
        stock: 9,
        isActive: true,
        type: MenuItemType.platoALaCarta,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Menú / Carta del día',
                style: AppTextStyles.h2,
                softWrap: true,
              ),
              const SizedBox(height: 24),
              DailyMenuSection(
                title: 'Menus',
                items: _menuItems,
                onActiveChanged: _onActiveChanged,
                onSave: _onSave,
              ),
              const SizedBox(height: 28),
              DailyMenuSection(
                title: 'Platos a la carta',
                items: _platosItems,
                onActiveChanged: _onActiveChanged,
                onSave: _onSave,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _onActiveChanged(DailyMenuItem item, bool value) {
    setState(() => item.isActive = value);
  }

  void _onSave(DailyMenuItem item, String name, double? price, int stock) {
    setState(() {
      item.name = name;
      item.price = price;
      item.stock = stock;
    });
  }
}
