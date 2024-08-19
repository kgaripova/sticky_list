import 'package:get_it/get_it.dart';
import 'package:sticky_list/services/item_service.dart';

class InjectionService {
  static Future<void> setupInjection() async {
    GetIt.I.registerSingleton<ItemService>(ItemService());
  }
}
