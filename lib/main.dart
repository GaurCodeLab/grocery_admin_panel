import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:grocery_admin_panel/firebase_options.dart';
import 'package:grocery_admin_panel/screens/inner_screens/add_product.dart';
import 'package:grocery_admin_panel/screens/inner_screens/edit_products.dart';
import 'package:grocery_admin_panel/screens/main_screen.dart';
import 'package:provider/provider.dart';

import 'consts/theme_data.dart';
import 'controllers/MenuController.dart' as menucontroller;
import 'providers/dark_theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  DarkThemeProvider themeChangeProvider = DarkThemeProvider();

  void getCurrentAppTheme() async {
    themeChangeProvider.setDarkTheme =
        await themeChangeProvider.darkThemePreference.getTheme();
  }

  @override
  void initState() {
    getCurrentAppTheme();
    super.initState();
  }

  final Future<FirebaseApp> _firebaseInitialisation = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _firebaseInitialisation,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const MaterialApp(
              home: Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            );
          } else if (snapshot.hasError) {
            return const MaterialApp(
              home: Scaffold(
                body: Center(
                  child: Text('An error occurred'),
                ),
              ),
            );
          }
          return MultiProvider(
            providers: [
              ChangeNotifierProvider(
                create: (_) => menucontroller.MenuController(),
              ),
              ChangeNotifierProvider(
                create: (_) {
                  return themeChangeProvider;
                },
              ),
            ],
            child: Consumer<DarkThemeProvider>(
              builder: (context, themeProvider, child) {
                return MaterialApp(
                  debugShowCheckedModeBanner: false,
                  title: 'Grocery',
                  theme: Styles.themeData(themeProvider.getDarkTheme, context),
                  home: const MainScreen(),
                  routes: {
                    UploadProductForm.routeName: (context) =>
                        const UploadProductForm(),

                  },
                );
              },
            ),
          );
        });
  }
}
