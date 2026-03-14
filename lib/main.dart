import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'providers/budget_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding/welcome_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/onboarding/input_budget_screen.dart';
import 'screens/onboarding/select_date_screen.dart';
import 'screens/onboarding/initial_limit_screen.dart';
import 'screens/main_shell.dart';
import 'screens/expenses/add_expense_screen.dart';
import 'screens/expenses/amount_input_screen.dart';
import 'screens/expenses/expense_success_screen.dart';
import 'screens/expenses/adjustment_screen.dart';
import 'screens/savings/savings_lock_screen.dart';
import 'screens/savings/goal_screen.dart';
import 'screens/insights/insights_screen.dart';
import 'screens/review/monthly_review_screen.dart';
import 'screens/notifications/notifications_screen.dart';
import 'screens/forecast/budget_forecast_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: AppTheme.surface,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const DailyBurnApp());
}

class DailyBurnApp extends StatelessWidget {
  const DailyBurnApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BudgetProvider(),
      child: MaterialApp(
        title: 'Daily Burn',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: '/splash',
        routes: {
          '/splash': (_) => const SplashScreen(),
          '/welcome': (_) => const WelcomeScreen(),
          '/login': (_) => const LoginScreen(),
          '/signup': (_) => const SignupScreen(),
          '/forgot-password': (_) => const ForgotPasswordScreen(),
          '/input-budget': (_) => const InputBudgetScreen(),
          '/select-date': (_) => const SelectDateScreen(),
          '/initial-limit': (_) => const InitialLimitScreen(),
          '/home': (_) => const MainShell(),
          '/add-expense': (_) => const AddExpenseScreen(),
          '/adjustment': (_) => const AdjustmentScreen(),
          '/savings-lock': (_) => const SavingsLockScreen(),
          '/goals': (_) => const GoalScreen(),
          '/insights': (_) => const InsightsScreen(),
          '/monthly-review': (_) => const MonthlyReviewScreen(),
          '/notifications': (_) => const NotificationsScreen(),
          '/forecast': (_) => const BudgetForecastScreen(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == '/amount-input') {
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (_) => AmountInputScreen(
                category: args['category'] as String,
              ),
            );
          }
          if (settings.name == '/expense-success') {
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (_) => ExpenseSuccessScreen(
                category: args['category'] as String,
                amount: args['amount'] as double,
              ),
            );
          }
          return null;
        },
      ),
    );
  }
}
