import 'package:pocketbase/pocketbase.dart';

class PocketBaseService {
  static final PocketBaseService _instance = PocketBaseService._internal();
  late PocketBase pb;

  factory PocketBaseService() {
    return _instance;
  }

  PocketBaseService._internal() {
    pb = PocketBase('http://127.0.0.1:8090');
  }
}