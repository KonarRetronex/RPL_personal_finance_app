import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../data/models/transaction_model.dart';
import '../../providers/category_provider.dart';
import '../screens/add_edit_transaction_screen.dart';

class TransactionListItem extends ConsumerWidget {
  final TransactionModel transaction;

  const TransactionListItem({super.key, required this.transaction});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final category = ref.read(categoryProvider.notifier).getCategoryById(transaction.categoryId);
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final isExpense = transaction.type == TransactionType.expense;

    return ListTile(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (ctx) => AddEditTransactionScreen(transaction: transaction),
        );
      },
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        child: Icon(
          isExpense ? Icons.arrow_downward : Icons.arrow_upward,
          color: isExpense ? Colors.redAccent : Colors.greenAccent,
        ),
      ),
      title: Text(
        transaction.notes ?? category?.name ?? 'Tanpa Kategori',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        '${category?.name ?? ""} · ${DateFormat('d MMM yyyy').format(transaction.date)}',
      ),
      trailing: Text(
        '${isExpense ? "-" : "+"} ${currencyFormatter.format(transaction.amount)}',
        style: TextStyle(
          color: isExpense ? Colors.redAccent : Colors.greenAccent,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}