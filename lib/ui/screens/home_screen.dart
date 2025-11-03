import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/settings_provider.dart';
import '../../providers/transaction_provider.dart';
import '../widgets/transaction_list_item.dart';
import 'add_edit_transaction_screen.dart';
import 'category_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(filteredTransactionsProvider);
    final balance = ref.watch(totalBalanceProvider);
    final monthlyExpense = ref.watch(monthlyExpenseProvider);
    final selectedDate = ref.watch(selectedDateProvider);
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      // --- PERUBAHAN 1: AppBar Title diubah menjadi statis ---
      appBar: AppBar(
        title: const Text('Dollars App'), // Nama aplikasi sebagai judul
        backgroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.category),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const CategoryScreen()));
            },
          ),
          Consumer(builder: (context, ref, child) {
            final themeMode = ref.watch(settingsProvider);
            return IconButton(
              icon: Icon(themeMode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode),
              onPressed: () => ref.read(settingsProvider.notifier).toggleTheme(),
            );
          }),
        ],
      ),
      body: Column(
        children: [
          // Balance and Expense Cards
          // --- PERUBAHAN 2: Mengirim parameter tambahan ke _buildHeader ---
          _buildHeader(context, ref, currencyFormatter, balance, monthlyExpense, selectedDate),
          
          // Transaction List
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text("Transaksi Terbaru", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ),
          Expanded(
            child: transactions.isEmpty
                ? const Center(child: Text("Belum ada transaksi di bulan ini."))
                : ListView.builder(
                    itemCount: transactions.length,
                    itemBuilder: (ctx, index) => TransactionListItem(transaction: transactions[index]),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (ctx) => const AddEditTransactionScreen(),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  // --- PERUBAHAN 3: Memperbarui method _buildHeader secara keseluruhan ---
  Widget _buildHeader(BuildContext context, WidgetRef ref, NumberFormat currencyFormatter, double balance, double monthlyExpense, DateTime selectedDate) {
    
    // Fungsi untuk menampilkan date picker
    Future<void> selectDate(BuildContext context) async {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2000),
        lastDate: DateTime(2101),
        initialDatePickerMode: DatePickerMode.year, // Mulai dari pilihan tahun
        locale: const Locale('id', 'ID'), // Set lokal ke Indonesia
      );
      if (picked != null && picked != selectedDate) {
        ref.read(selectedDateProvider.notifier).state = picked;
      }
    }

    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Kartu Saldo (tidak berubah)
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text("Total Saldo", style: TextStyle(fontSize: 16, color: Colors.grey)),
                  const SizedBox(height: 8),
                  Text(
                    currencyFormatter.format(balance),
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Kartu Pengeluaran (sudah dimodifikasi)
          Card(
            elevation: 2,
            color: Colors.red[900]?.withOpacity(0.8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Column(
                children: [
                  // Baris baru untuk memilih bulan & tahun
                  GestureDetector(
                    onTap: () => selectDate(context),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.calendar_today_outlined, color: Colors.white70, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          DateFormat('MMMM yyyy', 'id_ID').format(selectedDate),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const Icon(Icons.arrow_drop_down, color: Colors.white70),
                      ],
                    ),
                  ),
                  const Divider(color: Colors.white24, height: 16),
                  // Baris lama untuk info pengeluaran
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Pengeluaran Bulan Ini", style: TextStyle(fontSize: 16, color: Colors.white70)),
                      Text(
                        currencyFormatter.format(monthlyExpense),
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}