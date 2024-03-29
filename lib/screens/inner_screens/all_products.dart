import 'package:flutter/material.dart';
import 'package:grocery_admin_panel/responsive.dart';
import 'package:grocery_admin_panel/screens/dashboard_screen.dart';
import 'package:grocery_admin_panel/services/utils.dart';
import 'package:grocery_admin_panel/widgets/grid_products.dart';
import 'package:grocery_admin_panel/widgets/header.dart';
import 'package:grocery_admin_panel/widgets/side_menu.dart';
import 'package:provider/provider.dart';
import 'package:grocery_admin_panel/controllers/MenuController.dart'
    as menucontroller;

class AllProductsScreen extends StatefulWidget {
  const AllProductsScreen({Key? key}) : super(key: key);

  @override
  State<AllProductsScreen> createState() => _AllProductsScreenState();
}

class _AllProductsScreenState extends State<AllProductsScreen> {
  @override
  Widget build(BuildContext context) {
    Size size = Utils(context).getScreenSize;
    return Scaffold(
      key: context.read<menucontroller.MenuController>().getgridscaffoldKey,
      drawer: const SideMenu(),
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // We want this side menu only for large screen
            if (Responsive.isDesktop(context))
              const Expanded(
                // default flex = 1
                // and it takes 1/6 part of the screen
                child: SideMenu(),
              ),
            Expanded(
              // It takes 5/6 part of the screen
              flex: 5,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Header(
                      title: 'All products',
                      fct: () {
                        context
                            .read<menucontroller.MenuController>()
                            .controlProductsMenu();
                      },
                    ),
                    const SizedBox(height: 25,),
                    Responsive(
                      mobile: ProductGrid(
                        childAspectRatio:
                        size.width < 650 && size.width > 350 ? 1.1 : 0.8,
                        crossAxisCount: size.width < 650 ? 2 : 4,
                        isInMain: false,
                      ),
                      desktop: ProductGrid(
                        childAspectRatio: size.width < 1400 ? 0.8 : 1.08,
                        isInMain: false,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
