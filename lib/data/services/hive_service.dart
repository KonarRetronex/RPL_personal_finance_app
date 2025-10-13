import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import '../models/category_model.dart';
import '../models/transaction_model.dart';

class HiveService {
  static const String transactionsBoxName = 'transactions';
  static const String categoriesBoxName = 'categories';
  static const String settingsBoxName = 'settings';

  // Inisialisasi Hive
  static Future<void> init() async {
    if (!kIsWeb) {
      final appDocumentDir = await getApplicationDocumentsDirectory();
      Hive.init(appDocumentDir.path);
    } else {
      Hive.initFlutter();
    }
    
    // Register Adapters
    Hive.registerAdapter(TransactionTypeAdapter());
    Hive.registerAdapter(CategoryModelAdapter());
    Hive.registerAdapter(TransactionModelAdapter());

    // Open Boxes
    await Hive.openBox<TransactionModel>(transactionsBoxName);
    await Hive.openBox<CategoryModel>(categoriesBoxName);
    await Hive.openBox<dynamic>(settingsBoxName);
  }

  // Menambahkan data awal jika database kosong
  static Future<void> addInitialData() async {
    final categoryBox = Hive.box<CategoryModel>(categoriesBoxName);
    final transactionBox = Hive.box<TransactionModel>(transactionsBoxName);

    if (categoryBox.isEmpty) {
      debugPrint("Menambahkan data kategori awal...");
      final initialCategories = [
        CategoryModel(name: "Gaji"),
        CategoryModel(name: "Jajan"),
        CategoryModel(name: "Transport"),
        CategoryModel(name: "Makanan"),
        CategoryModel(name: "Tagihan"),
        CategoryModel(name: "Beli Baju"),
      ];
      for (var cat in initialCategories) {
        await categoryBox.put(cat.id, cat);
      }
    }
    
    if (transactionBox.isEmpty && categoryBox.isNotEmpty) {
        debugPrint("Menambahkan data transaksi awal...");
        final gajiCategory = categoryBox.values.firstWhere((cat) => cat.name == "Gaji");
        final jajanCategory = categoryBox.values.firstWhere((cat) => cat.name == "Jajan");
        final transportCategory = categoryBox.values.firstWhere((cat) => cat.name == "Transport");

        final initialTransactions = [
            TransactionModel(amount: 5000000, categoryId: gajiCategory.id, date: DateTime(2025, 10, 1), type: TransactionType.income, notes: "Gaji Oktober"),
            TransactionModel(amount: 50000, categoryId: jajanCategory.id, date: DateTime(2025, 10, 5), type: TransactionType.expense, notes: "Kopi susu"),
            TransactionModel(amount: 150000, categoryId: transportCategory.id, date: DateTime(2025, 10, 7), type: TransactionType.expense, notes: "Gojek seminggu"),
        ];

        for (var tx in initialTransactions) {
          await transactionBox.put(tx.id, tx);
        }
    }
  }

  // Getter untuk Boxes
  static Box<TransactionModel> get transactionsBox => Hive.box<TransactionModel>(transactionsBoxName);
  static Box<CategoryModel> get categoriesBox => Hive.box<CategoryModel>(categoriesBoxName);
  static Box get settingsBox => Hive.box(settingsBoxName);
}