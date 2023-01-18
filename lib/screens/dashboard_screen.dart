import 'package:flutter/material.dart';
import 'package:grocery_admin_panel/consts/constants.dart';
import 'package:grocery_admin_panel/responsive.dart';
import 'package:grocery_admin_panel/screens/inner_screens/add_product.dart';
import 'package:grocery_admin_panel/screens/inner_screens/all_products.dart';
import 'package:grocery_admin_panel/services/global_method.dart';
import 'package:grocery_admin_panel/services/utils.dart';
import 'package:grocery_admin_panel/widgets/buttons.dart';
import 'package:grocery_admin_panel/widgets/grid_products.dart';
import 'package:grocery_admin_panel/widgets/header.dart';
import 'package:grocery_admin_panel/widgets/products_widget.dart';
import 'package:grocery_admin_panel/widgets/text_widget.dart';
import 'package:provider/provider.dart';

import '../controllers/MenuController.dart' as menucontroller;

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = Utils(context).getScreenSize;
    Color color = Utils(context).color;
    return SafeArea(
      child: SingleChildScrollView(
        controller: ScrollController(),
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          children: [
            Header(
              title: 'Dashboard',
              fct: () {
                context
                    .read<menucontroller.MenuController>()
                    .controlDashboarkMenu();
              },
            ),
            const SizedBox(
              height: 15,
            ),
            TextWidget(
              text: 'Latest Products',
              color: color,
            ),
            const SizedBox(
              height: 15,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  ButtonsWidget(
                    onPressed: () {},
                    text: 'View all',
                    icon: Icons.store,
                    backgroundColor: Colors.blue,
                  ),
                  const Spacer(),
                  ButtonsWidget(
                    onPressed: () {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const UploadProductForm()));
                    },
                    text: 'Add product',
                    icon: Icons.add,
                    backgroundColor: Colors.blue,
                  ),
                ],
              ),
            ),
            const SizedBox(height: defaultPadding),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 5,
                  child: Column(
                    children: [
                      Responsive(
                        mobile: ProductGrid(
                          childAspectRatio:
                              size.width < 650 && size.width > 350 ? 1.1 : 0.8,
                          crossAxisCount: size.width < 650 ? 2 : 4,
                        ),
                        desktop: ProductGrid(
                          childAspectRatio: size.width < 1400 ? 0.8 : 1.08,
                        ),
                      ),
                      // MyProductsHome(),
                      // SizedBox(height: defaultPadding),
                      // OrdersScreen(),
                    ],
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
