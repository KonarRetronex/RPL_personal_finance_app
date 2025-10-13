import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance_app/data/models/transaction_model.dart';

// Fungsi helper sederhana untuk meniru logika filter dan kalkulasi
double calculateMonthlyExpense(List<TransactionModel> transactions, DateTime month) {
  return transactions
      .where((tx) =>
          tx.type == TransactionType.expense &&
          tx.date.year == month.year &&
          tx.date.month == month.month)
      .fold(0.0, (sum, item) => sum + item.amount);
}

void main() {
  group('Transaction Logic Tests', () {
    final sampleTransactions = [
      // Oktober 2025
      TransactionModel(amount: 50000, categoryId: '1', date: DateTime(2025, 10, 5), type: TransactionType.expense),
      TransactionModel(amount: 150000, categoryId: '2', date: DateTime(2025, 10, 10), type: TransactionType.expense),
      TransactionModel(amount: 5000000, categoryId: '3', date: DateTime(2025, 10, 1), type: TransactionType.income),
      
      // November 2025
      TransactionModel(amount: 75000, categoryId: '1', date: DateTime(2025, 11, 2), type: TransactionType.expense),
    ];

    test('calculates monthly expense correctly for a specific month', () {
      // Atur bulan yang ingin diuji
      final targetMonth = DateTime(2025, 10, 1);

      // Hitung pengeluaran
      final expense = calculateMonthlyExpense(sampleTransactions, targetMonth);

      // Verifikasi hasilnya (50000 + 150000)
      expect(expense, 200000.0);
    });

    test('returns zero expense for a month with no transactions', () {
      // Atur bulan tanpa transaksi
      final targetMonth = DateTime(2025, 9, 1);

      // Hitung pengeluaran
      final expense = calculateMonthlyExpense(sampleTransactions, targetMonth);

      // Verifikasi hasilnya
      expect(expense, 0.0);
    });
  });
}