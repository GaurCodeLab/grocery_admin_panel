import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:grocery_admin_panel/responsive.dart';
import 'package:grocery_admin_panel/screens/loading_manager.dart';
import 'package:grocery_admin_panel/screens/main_screen.dart';
import 'package:grocery_admin_panel/services/utils.dart';
import 'package:grocery_admin_panel/controllers/MenuController.dart'
    as menucontroller;
import 'package:grocery_admin_panel/widgets/buttons.dart';
import 'package:grocery_admin_panel/widgets/header.dart';
import 'package:grocery_admin_panel/widgets/side_menu.dart';
import 'package:grocery_admin_panel/widgets/text_widget.dart';
import 'package:iconly/iconly.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../services/global_method.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = '/EditProductScreen';

  const EditProductScreen(
      {Key? key,
      required this.id,
      required this.title,
      required this.price,
      required this.productCat,
      required this.imageUrl,
      required this.isPiece,
      required this.isOnSale,
      required this.salePrice})
      : super(key: key);

  final String id, title, price, productCat, imageUrl;
  final bool isPiece, isOnSale;
  final double salePrice;

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formkey = GlobalKey<FormState>();
  late final TextEditingController _titleController,
      _priceController; // title and price controllers

  late String _catValue;

  String? _salePercent;
  late String percToShow;
  late double _salePrice;
  late bool _isOnSale;
  File? _pickedImage;
  Uint8List webImage = Uint8List(10);
  late String _imageUrl;
  late int val; // kg or piece

  bool _isLoading = false;
  late bool _isPiece;

  @override
  void initState() {
    _priceController = TextEditingController(text: widget.price);
    _titleController = TextEditingController(text: widget.title);
    _salePrice = widget.salePrice;
    _catValue = widget.productCat;
    _isOnSale = widget.isOnSale;
    _isPiece = widget.isPiece;
    val = _isPiece ? 2 : 1;
    _imageUrl = widget.imageUrl;
    percToShow = (100 - (_salePrice * 100) / double.parse(widget.price))
            .round()
            .toStringAsFixed(1) +
        '%';
    super.initState();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  // void _uploadForm() async {
  //   final isValid = _formkey.currentState!.validate();
  // }

  void _updateForm() async {
    final isValid = _formkey.currentState!.validate();

    FocusScope.of(context).unfocus();
    String imageUrl;

    if (isValid) {
      _formkey.currentState!.save();

      try {
        String? imageUrl;
        setState(() {
          _isLoading = true;
        });
        if (_pickedImage != null) {
          final ref = FirebaseStorage.instance
              .ref()
              .child('productsImages')
              .child('${widget.id}.jpg');
          if (kIsWeb) {
            await ref.putData(webImage);
          } else {
            await ref.putFile(_pickedImage!);
          }
          imageUrl = await ref.getDownloadURL();
        }

        await FirebaseFirestore.instance
            .collection('products')
            .doc(widget.id)
            .update({
          'title': _titleController.text,
          'price': _priceController.text,
          'salePrice': _salePrice,
          'imageUrl':
              _pickedImage == null ? widget.imageUrl : imageUrl.toString(),
          'productCategoryName': _catValue,
          'isOnSale': _isOnSale,
          'isPiece': _isPiece,
        });

        await Fluttertoast.showToast(
          msg: "Product updated successfully",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
        );
      } on FirebaseException catch (error) {
        GlobalMethods.errorDialog(
            subtitle: "${error.message}", context: context);
        setState(() {
          _isLoading = false;
        });
      } catch (error) {
        GlobalMethods.errorDialog(subtitle: "$error", context: context);
        setState(() {
          _isLoading = false;
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _clearForm() {
    _isPiece = false;
    val = 1;
    _priceController.clear();
    _titleController.clear();
    setState(() {
      _pickedImage = null;
      webImage = Uint8List(8);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Utils(context).getTheme;
    final color = Utils(context).color;
    final _scaffoldColor = Theme.of(context).scaffoldBackgroundColor;
    Size size = Utils(context).getScreenSize;

    var inputDecoration = InputDecoration(
      fillColor: _scaffoldColor,
      filled: true,
      border: InputBorder.none,
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: color,
          width: 1.0,
        ),
      ),
    );
    return Scaffold(
      // key: context
      //     .read<menucontroller.MenuController>()
      //     .getAddProductscaffoldKey,
      drawer: const SideMenu(),
      body: LoadingManager(
        isloading: _isLoading,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // if (Responsive.isDesktop(context))
            //   const Expanded(
            //     child: SideMenu(),
            //   ),
            Expanded(
              flex: 5,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(
                      height: 25,
                    ),
                    // Header(
                    //     title: 'Add product',
                    //     showTextField: false,
                    //     fct: () {
                    //       context
                    //           .read<menucontroller.MenuController>()
                    //           .controlAddProductsMenu();
                    //     }),
                    const SizedBox(
                      height: 25,
                    ),
                    Container(
                      width: size.width > 650 ? 650 : size.width,
                      color: Theme.of(context).cardColor,
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.all(16),
                      child: Form(
                        key: _formkey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            InkWell(
                              onTap: () {
                                GlobalMethods.warningDialog(
                                    title: 'Delete?',
                                    subtitle: 'Confirm delete',
                                    fct: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const MainScreen()),
                                      );
                                    },
                                    context: context);
                              },
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.close_outlined,
                                    color: Colors.red,
                                    size: 24,
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  TextWidget(
                                      text: 'Cancel update',
                                      color: Colors.red.shade700),
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            TextWidget(
                              text: 'Product title*',
                              color: color,
                              isTitle: true,
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            TextFormField(
                              controller: _titleController,
                              key: const ValueKey('Title'),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Please enter a Title';
                                }
                                return null;
                              },
                              decoration: inputDecoration,
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: FittedBox(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        TextWidget(
                                          text: 'Price in \u{20B9}',
                                          color: color,
                                          isTitle: true,
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        SizedBox(
                                          width: 100,
                                          child: TextFormField(
                                            controller: _priceController,
                                            key: const ValueKey(
                                                'Price \u{20B9}'),
                                            keyboardType: TextInputType.number,
                                            validator: (value) {
                                              if (value!.isEmpty) {
                                                return 'Price is empty';
                                              }
                                              return null;
                                            },
                                            decoration: inputDecoration,
                                            inputFormatters: <
                                                TextInputFormatter>[
                                              FilteringTextInputFormatter.allow(
                                                  RegExp(r'[0-9.]')),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 20,
                                        ),
                                        TextWidget(
                                          text: 'Product category*',
                                          color: color,
                                          isTitle: true,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: _categoryDropDown(),
                                        ),
                                        const SizedBox(
                                          height: 20,
                                        ),
                                        TextWidget(
                                          text: 'Measure unit',
                                          color: color,
                                          isTitle: true,
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Row(
                                          children: [
                                            TextWidget(
                                                text: 'kg', color: color),
                                            Radio(
                                              value: 1,
                                              groupValue: val,
                                              onChanged: (value) {
                                                setState(() {
                                                  val = 1;
                                                  _isPiece = false;
                                                });
                                              },
                                              activeColor: Colors.green,
                                            ),
                                            TextWidget(
                                                text: 'piece', color: color),
                                            Radio(
                                              value: 2,
                                              groupValue: val,
                                              onChanged: (value) {
                                                setState(() {
                                                  val = 2;
                                                  _isPiece = true;
                                                });
                                              },
                                              activeColor: Colors.green,
                                            ),
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 15,
                                        ),
                                        Row(
                                          children: [
                                            Checkbox(
                                              value: _isOnSale,
                                              onChanged: (newValue) {
                                                setState(() {
                                                  _isOnSale = newValue!;
                                                });
                                              },
                                              activeColor: _isOnSale
                                                  ? Colors.blue
                                                  : Colors.white,
                                              checkColor: Colors.white,
                                            ),
                                            const SizedBox(
                                              width: 5,
                                            ),
                                            TextWidget(
                                              text: 'Sale',
                                              color: color,
                                              isTitle: true,
                                            ),
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        AnimatedSwitcher(
                                          duration: const Duration(seconds: 1),
                                          child: !_isOnSale
                                              ? Container()
                                              : Row(
                                                  children: [
                                                    TextWidget(
                                                        text: '\u{20B9}' +
                                                            _salePrice
                                                                .toStringAsFixed(
                                                                    2),
                                                        color: color),
                                                    const SizedBox(
                                                      width: 10,
                                                    ),
                                                    salePercentageDropDownWidget(
                                                        color),
                                                  ],
                                                ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 4,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                        height: size.width > 650
                                            ? 350
                                            : size.width * 0.45,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(12.0),
                                          color: Theme.of(context)
                                              .scaffoldBackgroundColor,
                                        ),
                                        child: _pickedImage == null
                                            ? Image.network(_imageUrl)
                                            : ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                child: kIsWeb
                                                    ? Image.memory(
                                                        webImage,
                                                        fit: BoxFit.fill,
                                                      )
                                                    : Image.file(
                                                        _pickedImage!,
                                                        fit: BoxFit.fill,
                                                      ),
                                              )),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Column(
                                    children: [
                                      FittedBox(
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.edit_outlined,
                                              color: Colors.blue,
                                              size: 28,
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                _pickImage();
                                              },
                                              child: TextWidget(
                                                text: 'Update image',
                                                color: Colors.blue,
                                                isTitle: true,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.all(18.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  ButtonsWidget(
                                    onPressed: () async {
                                      GlobalMethods.warningDialog(
                                          title: 'Delete?',
                                          subtitle: 'Confirm delete',
                                          fct: () async {
                                            await FirebaseFirestore.instance
                                                .collection('products')
                                                .doc(widget.id)
                                                .delete();
                                            await Fluttertoast.showToast(
                                              msg: "Product has been deleted",
                                              toastLength: Toast.LENGTH_LONG,
                                              gravity: ToastGravity.CENTER,
                                              timeInSecForIosWeb: 1,
                                            );
                                            while (Navigator.canPop(context)) {
                                              Navigator.pop(context);
                                            }
                                          },
                                          context: context);
                                    },
                                    text: 'Delete',
                                    icon: IconlyBold.danger,
                                    backgroundColor: Colors.red.shade700,
                                  ),
                                  ButtonsWidget(
                                    onPressed: () {
                                      // _uploadForm();
                                      _updateForm();
                                    },
                                    text: 'Update',
                                    icon: IconlyBold.setting,
                                    backgroundColor: Colors.blue,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
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

  Future<void> _pickImage() async {
    if (!kIsWeb) {
      final ImagePicker _picker = ImagePicker();
      XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        var selected = File(image.path);
        setState(() {
          _pickedImage = selected;
        });
      } else {
        print('No image picked');
      }
    } else if (kIsWeb) {
      final ImagePicker _picker = ImagePicker();
      XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        var f = await image.readAsBytes();
        setState(() {
          webImage = f;
          _pickedImage = File('a');
        });
      } else {
        print('Something went wrong');
      }
    }
  }

  Widget dottedBorder() {
    final color = Utils(context).color;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: DottedBorder(
        dashPattern: const [6.7],
        borderType: BorderType.RRect,
        color: color,
        radius: const Radius.circular(12),
        child: Padding(
          padding: const EdgeInsets.only(left: 80.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.image_outlined,
                color: color,
                size: 50,
              ),
              const SizedBox(
                height: 20,
              ),
              TextButton(
                onPressed: () {
                  _pickImage();
                },
                child: TextWidget(
                  text: 'Choose an image',
                  color: Colors.blue,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _categoryDropDown() {
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: _catValue,
        onChanged: (value) {
          setState(() {
            _catValue = value!;
          });
          // print(_catValue);
        },
        hint: const Text('Select a category'),
        items: const [
          DropdownMenuItem(
            child: Text(
              'Vegetables',
            ),
            value: 'Vegetables',
          ),
          DropdownMenuItem(
            child: Text(
              'Grains',
            ),
            value: 'Grains',
          ),
          DropdownMenuItem(
            child: Text(
              'Fruits',
            ),
            value: 'Fruits',
          ),
          DropdownMenuItem(
            child: Text('Herbs'),
            value: 'Herbs',
          ),
          DropdownMenuItem(
            child: Text('Spices'),
            value: 'Spices',
          ),
        ],
      ),
    );
  }

  DropdownButtonHideUnderline salePercentageDropDownWidget(Color color) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        style: TextStyle(color: color),
        items: const [
          DropdownMenuItem<String>(
            child: Text('10%'),
            value: '10',
          ),
          DropdownMenuItem<String>(
            child: Text('15%'),
            value: '15',
          ),
          DropdownMenuItem<String>(
            child: Text('25%'),
            value: '25',
          ),
          DropdownMenuItem<String>(
            child: Text('50%'),
            value: '50',
          ),
          DropdownMenuItem<String>(
            child: Text('75%'),
            value: '75',
          ),
          DropdownMenuItem<String>(
            child: Text('0%'),
            value: '0',
          ),
        ],
        onChanged: (value) {
          if (value == '0') {
            return;
          } else {
            setState(() {
              _salePercent = value;
              _salePrice = double.parse(widget.price) -
                  (double.parse(value!) * double.parse(widget.price) / 100);
            });
          }
        },
        hint: Text(_salePercent ?? percToShow),
        value: _salePercent,
      ),
    );
  }
}
