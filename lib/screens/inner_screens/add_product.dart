import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:grocery_admin_panel/responsive.dart';
import 'package:grocery_admin_panel/services/utils.dart';
import 'package:grocery_admin_panel/controllers/MenuController.dart'
    as menucontroller;
import 'package:grocery_admin_panel/widgets/buttons.dart';
import 'package:grocery_admin_panel/widgets/header.dart';
import 'package:grocery_admin_panel/widgets/side_menu.dart';
import 'package:grocery_admin_panel/widgets/text_widget.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class UploadProductForm extends StatefulWidget {
  static const routeName = '/UploadProductForm';

  const UploadProductForm({Key? key}) : super(key: key);

  @override
  State<UploadProductForm> createState() => _UploadProductFormState();
}

class _UploadProductFormState extends State<UploadProductForm> {
  final _formkey = GlobalKey<FormState>();
  String _catValue = 'Vegetables';
  int _groupValue = 1;
  bool isPiece = false;

  late final TextEditingController _titleController, _priceController;
  File? _pickedImage;
  Uint8List webImage = Uint8List(8);

  @override
  void initState() {
    _priceController = TextEditingController();
    _titleController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _uploadForm() async {
    final isValid = _formkey.currentState!.validate();
  }

  void _clearForm() {
    isPiece = false;
    _groupValue = 1;
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
      key: context
          .read<menucontroller.MenuController>()
          .getAddProductscaffoldKey,
      drawer: const SideMenu(),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (Responsive.isDesktop(context))
            const Expanded(
              child: SideMenu(),
            ),
          Expanded(
            flex: 5,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(
                    height: 25,
                  ),
                  Header(
                      title: 'Add product',
                      showTextField: false,
                      fct: () {
                        context
                            .read<menucontroller.MenuController>()
                            .controlAddProductsMenu();
                      }),
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
                                    mainAxisAlignment: MainAxisAlignment.start,
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
                                          key: const ValueKey('Price \u{20B9}'),
                                          keyboardType: TextInputType.number,
                                          validator: (value) {
                                            if (value!.isEmpty) {
                                              return 'Price is empty';
                                            }
                                            return null;
                                          },
                                          decoration: inputDecoration,
                                          inputFormatters: <TextInputFormatter>[
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
                                          TextWidget(text: 'kg', color: color),
                                          Radio(
                                            value: 1,
                                            groupValue: _groupValue,
                                            onChanged: (value) {
                                              setState(() {
                                                _groupValue = 1;
                                                isPiece = false;
                                              });
                                            },
                                            activeColor: Colors.green,
                                          ),
                                          TextWidget(
                                              text: 'piece', color: color),
                                          Radio(
                                            value: 2,
                                            groupValue: _groupValue,
                                            onChanged: (value) {
                                              setState(() {
                                                _groupValue = 2;
                                                isPiece = true;
                                              });
                                            },
                                            activeColor: Colors.green,
                                          ),
                                        ],
                                      )
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
                                          ? dottedBorder()
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
                                child: FittedBox(
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.delete_outlined,
                                            color: Colors.red,
                                            size: 24,
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              setState(() {
                                                _pickedImage = null;
                                                webImage = Uint8List(8);
                                              });
                                            },
                                            child: TextWidget(
                                              text: 'Clear',
                                              color: Colors.red,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 15,
                                      ),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.edit_outlined,
                                            color: Colors.red,
                                            size: 24,
                                          ),
                                          TextButton(
                                            onPressed: () {},
                                            child: TextWidget(
                                              text: 'Update image',
                                              color: Colors.red,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.all(18.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                ButtonsWidget(
                                  onPressed: _clearForm,
                                  text: 'Clear form',
                                  icon: Icons.warning_rounded,
                                  backgroundColor: Colors.red.shade300,
                                ),
                                ButtonsWidget(
                                  onPressed: () {
                                    _uploadForm();
                                  },
                                  text: 'Upload',
                                  icon: Icons.upload_rounded,
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
          print(_catValue);
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
}
