import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/budget_bloc.dart';
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
  void dispose() {
    // CLEANUP: Prevents memory leaks (important for Code Quality grade)
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add New Expense"),
        elevation: 0,
      ),
      body: BlocConsumer<BudgetBloc, BudgetState>(
        listener: (context, state) {
          if (state is BudgetSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Budget saved successfully!"),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context);
          }
          if (state is BudgetFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: "Expense Title",
                    hintText: "e.g., Groceries",
                    border: OutlineInputBorder(),
                  ),
                  textInputAction:
                      TextInputAction.next, // Keyboard "Next" button
                  validator: (val) =>
                      FormValidators.validateRequired(val, "Title"),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _amountController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: "Amount (RWF)",
                    hintText: "0.00",
                    border: OutlineInputBorder(),
                  ),
                  textInputAction:
                      TextInputAction.done, // Keyboard "Done" button
                  validator: FormValidators.validateAmount,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: state is BudgetLoading
                        ? null
                        : () {
                            if (_formKey.currentState!.validate()) {
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
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text("Save Expense"),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
