import '../../blocs/budget_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/form_validators.dart';

class AddExpensePage extends StatefulWidget {
  const AddExpensePage({super.key});

  @override
  State<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add New Expense")),
      // BlocConsumer listens for success/failure to show SnackBars
      body: BlocConsumer<BudgetBloc, BudgetState>(
        listener: (context, state) {
          if (state is BudgetSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Budget saved successfully!")),
            );
            Navigator.pop(context); // Go back after saving
          }
          if (state is BudgetFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: "Expense Title"),
                  validator: (val) =>
                      FormValidators.validateRequired(val, "Title"),
                ),
                TextFormField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Amount (RWF)"),
                  validator: FormValidators.validateAmount,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: state is BudgetLoading
                      ? null // Disable button while loading
                      : () {
                          if (_formKey.currentState!.validate()) {
                            // Trigger Merveille's BLoC logic here
                            context.read<BudgetBloc>().add(
                                  AddExpenseEvent(
                                    title: _titleController.text,
                                    amount:
                                        double.parse(_amountController.text),
                                  ),
                                );
                          }
                        },
                  child: state is BudgetLoading
                      ? const CircularProgressIndicator()
                      : const Text("Save Expense"),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
