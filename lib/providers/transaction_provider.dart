import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../data/models/transaction_model.dart';
import '../data/services/hive_service.dart';

// Provider utama yang mengelola semua transaksi
final transactionListProvider = StateNotifierProvider<TransactionNotifier, List<TransactionModel>>((ref) {
  return TransactionNotifier();
});

class TransactionNotifier extends StateNotifier<List<TransactionModel>> {
  final Box<TransactionModel> _transactionBox = HiveService.transactionsBox;

  TransactionNotifier() : super([]) {
    _loadTransactions();
    _transactionBox.listenable().addListener(_loadTransactions);
  }

  void _loadTransactions() {
    state = _transactionBox.values.toList()..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    await _transactionBox.put(transaction.id, transaction);
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    await _transactionBox.put(transaction.id, transaction);
  }

  Future<void> deleteTransaction(String id) async {
    await _transactionBox.delete(id);
  }

  @override
  void dispose() {
    _transactionBox.listenable().removeListener(_loadTransactions);
    super.dispose();
  }
}


// Provider untuk periode (bulan & tahun) yang dipilih
final selectedDateProvider = StateProvider<DateTime>((ref) => DateTime.now());

// Provider turunan (derived state) untuk memfilter transaksi berdasarkan periode
final filteredTransactionsProvider = Provider<List<TransactionModel>>((ref) {
  final transactions = ref.watch(transactionListProvider);
  final selectedDate = ref.watch(selectedDateProvider);
  return transactions
      .where((tx) =>
          tx.date.month == selectedDate.month && tx.date.year == selectedDate.year)
      .toList();
});

// Provider turunan untuk menghitung total saldo
final totalBalanceProvider = Provider<double>((ref) {
  final transactions = ref.watch(transactionListProvider);
  double balance = 0.0;
  for (var tx in transactions) {
    if (tx.type == TransactionType.income) {
      balance += tx.amount;
    } else {
      balance -= tx.amount;
    }
  }
  return balance;
});

// Provider turunan untuk menghitung pengeluaran bulan ini
final monthlyExpenseProvider = Provider<double>((ref) {
  final transactions = ref.watch(filteredTransactionsProvider);
  return transactions
      .where((tx) => tx.type == TransactionType.expense)
      .fold(0.0, (sum, item) => sum + item.amount);
});