import 'package:flutter/material.dart';

import '../models/station.dart';

/// One enum value per amenity column in the `stations` table. Centralising
/// the icon + label + accessor here means a new amenity is a one-place
/// change instead of a search-and-add across five widgets.
enum Amenity {
  disabled,
  wc,
  coffeeShop,
  groceryStore,
  fastFood,
  atm,
  elevator,
  bicycleParking,
  waterCooler,
  cleanFood,
  blindPath,
  fireSuppressionSystem,
  fireExtinguisher,
  metroPolice,
  creditTicketSales,
  waitingChair,
  camera,
  trashCan,
  smoking,
  petsAllowed,
  freeWifi,
  prayerRoom;

  String get label => switch (this) {
        Amenity.disabled => 'دسترسی ویژه معلولین',
        Amenity.wc => 'سرویس بهداشتی',
        Amenity.coffeeShop => 'کافی‌شاپ',
        Amenity.groceryStore => 'فروشگاه',
        Amenity.fastFood => 'فست‌فود',
        Amenity.atm => 'خودپرداز',
        Amenity.elevator => 'آسانسور',
        Amenity.bicycleParking => 'پارکینگ دوچرخه',
        Amenity.waterCooler => 'آبسردکن',
        Amenity.cleanFood => 'غذای سالم',
        Amenity.blindPath => 'مسیر ویژه نابینایان',
        Amenity.fireSuppressionSystem => 'سیستم اطفاء حریق',
        Amenity.fireExtinguisher => 'کپسول آتش‌نشانی',
        Amenity.metroPolice => 'پلیس مترو',
        Amenity.creditTicketSales => 'فروش بلیط اعتباری',
        Amenity.waitingChair => 'صندلی انتظار',
        Amenity.camera => 'دوربین مداربسته',
        Amenity.trashCan => 'سطل زباله',
        Amenity.smoking => 'محل استعمال دخانیات',
        Amenity.petsAllowed => 'مجاز برای حیوانات خانگی',
        Amenity.freeWifi => 'اینترنت رایگان',
        Amenity.prayerRoom => 'نمازخانه',
      };

  IconData get icon => switch (this) {
        Amenity.disabled => Icons.accessible_rounded,
        Amenity.wc => Icons.wc_rounded,
        Amenity.coffeeShop => Icons.coffee_rounded,
        Amenity.groceryStore => Icons.local_grocery_store_rounded,
        Amenity.fastFood => Icons.fastfood_rounded,
        Amenity.atm => Icons.local_atm_rounded,
        Amenity.elevator => Icons.elevator_rounded,
        Amenity.bicycleParking => Icons.pedal_bike_rounded,
        Amenity.waterCooler => Icons.water_drop_rounded,
        Amenity.cleanFood => Icons.restaurant_menu_rounded,
        Amenity.blindPath => Icons.visibility_off_rounded,
        Amenity.fireSuppressionSystem => Icons.local_fire_department_rounded,
        Amenity.fireExtinguisher => Icons.fire_extinguisher_rounded,
        Amenity.metroPolice => Icons.local_police_rounded,
        Amenity.creditTicketSales => Icons.credit_card_rounded,
        Amenity.waitingChair => Icons.chair_alt_rounded,
        Amenity.camera => Icons.videocam_rounded,
        Amenity.trashCan => Icons.delete_outline_rounded,
        Amenity.smoking => Icons.smoking_rooms_rounded,
        Amenity.petsAllowed => Icons.pets_rounded,
        Amenity.freeWifi => Icons.wifi_rounded,
        Amenity.prayerRoom => Icons.mosque_rounded,
      };

  /// Whether [station] has this amenity.
  bool isPresentOn(Station station) => switch (this) {
        Amenity.disabled => station.disabled,
        Amenity.wc => station.wc,
        Amenity.coffeeShop => station.coffeeShop,
        Amenity.groceryStore => station.groceryStore,
        Amenity.fastFood => station.fastFood,
        Amenity.atm => station.atm,
        Amenity.elevator => station.elevator,
        Amenity.bicycleParking => station.bicycleParking,
        Amenity.waterCooler => station.waterCooler,
        Amenity.cleanFood => station.cleanFood,
        Amenity.blindPath => station.blindPath,
        Amenity.fireSuppressionSystem => station.fireSuppressionSystem,
        Amenity.fireExtinguisher => station.fireExtinguisher,
        Amenity.metroPolice => station.metroPolice,
        Amenity.creditTicketSales => station.creditTicketSales,
        Amenity.waitingChair => station.waitingChair,
        Amenity.camera => station.camera,
        Amenity.trashCan => station.trashCan,
        Amenity.smoking => station.smoking,
        Amenity.petsAllowed => station.petsAllowed,
        Amenity.freeWifi => station.freeWifi,
        Amenity.prayerRoom => station.prayerRoom,
      };

  /// All amenities present on [station], in declaration order.
  static List<Amenity> presentOn(Station station) =>
      Amenity.values.where((a) => a.isPresentOn(station)).toList();
}
