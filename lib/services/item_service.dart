import 'package:get_it/get_it.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

import 'package:sticky_list/models/item.dart';

class ItemService {
  static ItemService get shared => GetIt.instance.get<ItemService>();

  Future<List<Item>> fetchItems({bool includeUselessData = true}) async {
    final String response = await rootBundle.loadString('assets/items.json');
    List jsonResponse = jsonDecode(response);
    return jsonResponse
        .map((item) =>
            Item.fromJson(item, includeUselessData: includeUselessData))
        .toList();
  }
}
