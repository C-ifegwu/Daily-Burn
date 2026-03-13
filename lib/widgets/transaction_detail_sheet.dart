import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../providers/budget_provider.dart';

/// Shows as a bottom sheet when tapping any transaction row.
/// Allows editing note/amount/category and deleting.
void showTransactionDetail(BuildContext context, Transaction t) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppTheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (_) => _TransactionDetailSheet(transaction: t),
  );
}

class _TransactionDetailSheet extends StatefulWidget {
  final Transaction transaction;
  const _TransactionDetailSheet({required this.transaction});

  @override
  State<_TransactionDetailSheet> createState() => _TransactionDetailSheetState();
}

class _TransactionDetailSheetState extends State<_TransactionDetailSheet> {
  late String _category;
  late TextEditingController _noteCtrl;
  late TextEditingController _amountCtrl;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _category = widget.transaction.category;
    _noteCtrl = TextEditingController(text: widget.transaction.note);
    _amountCtrl = TextEditingController(text: widget.transaction.amount.toStringAsFixed(2));
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  void _save() {
    final amount = double.tryParse(_amountCtrl.text);
    if (amount == null || amount <= 0) return;
    context.read<BudgetProvider>().editTransaction(
      widget.transaction.id,
      amount: amount,
      note: _noteCtrl.text.trim().isEmpty ? widget.transaction.note : _noteCtrl.text.trim(),
      category: _category,
    );
    Navigator.pop(context);
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Delete Transaction?', style: AppTheme.headlineMedium.copyWith(fontSize: 18)),
        content: Text('This will permanently remove "${widget.transaction.note}" (\$${widget.transaction.amount.toStringAsFixed(2)}).', style: AppTheme.bodyMedium.copyWith(height: 1.5)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              context.read<BudgetProvider>().deleteTransaction(widget.transaction.id);
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: AppTheme.dangerRed, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.categoryColors[_category] ?? AppTheme.primary;
    final emoji = AppTheme.categoryEmojis[_category] ?? '💰';

    return Padding(
      padding: EdgeInsets.fromLTRB(24, 16, 24, MediaQuery.of(context).viewInsets.bottom + 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppTheme.border, borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 20),

          // Header row
          Row(
            children: [
              Container(
                width: 52, height: 52,
                decoration: BoxDecoration(color: color.withAlpha(25), borderRadius: BorderRadius.circular(14)),
                child: Center(child: Text(emoji, style: const TextStyle(fontSize: 26))),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Transaction Detail', style: AppTheme.labelSmall.copyWith(fontSize: 11, letterSpacing: 0.8)),
                    Text(widget.transaction.note, style: AppTheme.titleMedium.copyWith(fontSize: 17), overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(_isEditing ? Icons.close_rounded : Icons.edit_rounded, color: AppTheme.textSecondary),
                onPressed: () => setState(() => _isEditing = !_isEditing),
              ),
            ],
          ),
          const SizedBox(height: 20),

          if (!_isEditing) ...[
            // ── Read-only view ─────────────────────────────────────
            _DetailRow(label: 'Amount', value: '\$${widget.transaction.amount.toStringAsFixed(2)}', valueColor: AppTheme.dangerRed),
            _DetailRow(label: 'Category', value: '$emoji  $_category'),
            _DetailRow(label: 'Date', value: DateFormat('EEEE, MMM d').format(widget.transaction.dateTime)),
            _DetailRow(label: 'Time', value: DateFormat('h:mm a').format(widget.transaction.dateTime)),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: _confirmDelete,
                icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.dangerRed, size: 18),
                label: const Text('Delete Transaction', style: TextStyle(color: AppTheme.dangerRed, fontWeight: FontWeight.w600)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppTheme.dangerRed),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ] else ...[
            // ── Edit view ─────────────────────────────────────────
            // Category picker
            Text('Category', style: AppTheme.bodyMedium.copyWith(fontSize: 12)),
            const SizedBox(height: 8),
            Row(
              children: ['Food', 'Transport', 'Fun', 'Misc'].map((cat) {
                final catColor = AppTheme.categoryColors[cat] ?? AppTheme.primary;
                final catEmoji = AppTheme.categoryEmojis[cat] ?? '💰';
                final isSelected = _category == cat;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _category = cat),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? catColor.withAlpha(25) : AppTheme.background,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: isSelected ? catColor : AppTheme.border, width: isSelected ? 1.5 : 1),
                      ),
                      child: Column(
                        children: [
                          Text(catEmoji, style: const TextStyle(fontSize: 20)),
                          const SizedBox(height: 2),
                          Text(cat, style: AppTheme.labelSmall.copyWith(fontSize: 10, color: isSelected ? catColor : AppTheme.textSecondary)),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _noteCtrl,
              decoration: InputDecoration(
                labelText: 'Note',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.border)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.primary, width: 1.5)),
                filled: true, fillColor: AppTheme.background,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _amountCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Amount',
                prefixText: '\$  ',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.border)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.primary, width: 1.5)),
                filled: true, fillColor: AppTheme.background,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _save,
                child: const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  const _DetailRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      decoration: BoxDecoration(color: AppTheme.background, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.border)),
      child: Row(
        children: [
          Text(label, style: AppTheme.bodyMedium),
          const Spacer(),
          Text(value, style: AppTheme.titleMedium.copyWith(fontSize: 14, color: valueColor ?? AppTheme.textPrimary)),
        ],
      ),
    );
  }
}
