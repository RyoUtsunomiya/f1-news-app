import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'services/api_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MobileAds.instance.initialize();
  final apiService = ApiService();
  await apiService.init(); // カスタムソースをローカルストレージから復元
  runApp(
    ChangeNotifierProvider.value(
      value: apiService,
      child: const F1NewsApp(),
    ),
  );
}

class F1NewsApp extends StatelessWidget {
  const F1NewsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'F1 ニュース',
      theme: AppTheme.darkTheme,
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
