import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:product_app/main.dart';

class AddProductScreen extends StatefulWidget {
  final List<Product> originalProducts;
  AddProductScreen({required this.originalProducts});

  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedProductType;
  String _productName = '';
  double _sellingPrice = 0.0;
  double _taxRate = 0.0;

  List<String> _productTypes = [
    'Product',
    'Service',
    // Add more product types if needed
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Product'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                value: _selectedProductType,
                onChanged: (value) {
                  setState(() {
                    _selectedProductType = value;
                  });
                },
                items: _productTypes.map((type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                decoration: InputDecoration(
                  labelText: 'Product Type',
                ),
                validator: (value) {
                  if (value == null) {
                    return 'Please select a product type';
                  }
                  return null;
                },
              ),
              TextFormField(
                onChanged: (value) {
                  setState(() {
                    _productName = value;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Product Name',
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a product name';
                  }
                  return null;
                },
              ),
              TextFormField(
                onChanged: (value) {
                  setState(() {
                    _sellingPrice = double.tryParse(value) ?? 0.0;
                  });
                },
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Selling Price',
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a selling price';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              TextFormField(
                onChanged: (value) {
                  setState(() {
                    _taxRate = double.tryParse(value) ?? 0.0;
                  });
                },
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Tax Rate',
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a tax rate';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    addProduct();
                  }
                },
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> addProduct() async {
    try {
      var uri = Uri.parse('https://app.getswipe.in/api/public/add');

      var request = http.MultipartRequest('POST', uri);
      request.fields['product_name'] = _productName;
      request.fields['product_type'] = _selectedProductType!;
      request.fields['price'] = _sellingPrice.toString();
      request.fields['tax'] = _taxRate.toString();

      // If you have image files to upload, add them as follows:
      // request.files.add(await http.MultipartFile.fromPath('files[]', imagePath));

      var response = await request.send();

      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        var decodedResponse = json.decode(responseData);

        // Assuming the API response matches the expected response structure
        if (decodedResponse['success'] == true) {
          var productDetails = decodedResponse['product_details'];
          var productId = decodedResponse['product_id'];

          // Create a new product object from the response details
          var newProduct = Product(
            productName: productDetails['product_name'],
            productType: productDetails['product_type'],
            price: productDetails['price'].toDouble(),
            tax: productDetails['tax'].toDouble(),
            image: '',
            // Add other fields as per your requirement
          );

          setState(() {
            // Add the new product to the original list
            widget.originalProducts.add(newProduct);
          });

          // Show a success message to the user
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('Success'),
                content: Text('Product added successfully!'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context); // Close the dialog
                      Navigator.pop(context); // Go back to the previous screen
                    },
                    child: Text('OK'),
                  ),
                ],
              );
            },
          );
        } else {
          print('Product addition failed: ${decodedResponse['message']}');
          // Handle the failure case as per your requirement
        }
      } else {
        print('Request failed with status: ${response.statusCode}.');
        // Handle the error case as per your requirement
      }
    } catch (error) {
      print('Error: $error');
      // Handle the error case as per your requirement
    }
  }

}


// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:product_app/main.dart';
//
// class AddProductScreen extends StatefulWidget {
//   final List<Product> originalProducts;
//
//   AddProductScreen({required this.originalProducts});
//
//   @override
//   _AddProductScreenState createState() => _AddProductScreenState();
// }
//
// class _AddProductScreenState extends State<AddProductScreen> {
//   final _formKey = GlobalKey<FormState>();
//   String? _selectedProductType;
//   String _productName = '';
//   double _sellingPrice = 0.0;
//   double _taxRate = 0.0;
//
//   List<String> _productTypes = [
//     'Product',
//     'Service',
//     // Add more product types if needed
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Add Product'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             children: [
//               DropdownButtonFormField<String>(
//                 value: _selectedProductType,
//                 onChanged: (value) {
//                   setState(() {
//                     _selectedProductType = value;
//                   });
//                 },
//                 items: _productTypes.map((type) {
//                   return DropdownMenuItem<String>(
//                     value: type,
//                     child: Text(type),
//                   );
//                 }).toList(),
//                 decoration: InputDecoration(
//                   labelText: 'Product Type',
//                 ),
//                 validator: (value) {
//                   if (value == null) {
//                     return 'Please select a product type';
//                   }
//                   return null;
//                 },
//               ),
//               TextFormField(
//                 onChanged: (value) {
//                   setState(() {
//                     _productName = value;
//                   });
//                 },
//                 decoration: InputDecoration(
//                   labelText: 'Product Name',
//                 ),
//                 validator: (value) {
//                   if (value!.isEmpty) {
//                     return 'Please enter a product name';
//                   }
//                   return null;
//                 },
//               ),
//               TextFormField(
//                 onChanged: (value) {
//                   setState(() {
//                     _sellingPrice = double.tryParse(value) ?? 0.0;
//                   });
//                 },
//                 keyboardType: TextInputType.numberWithOptions(decimal: true),
//                 decoration: InputDecoration(
//                   labelText: 'Selling Price',
//                 ),
//                 validator: (value) {
//                   if (value!.isEmpty) {
//                     return 'Please enter a selling price';
//                   }
//                   if (double.tryParse(value) == null) {
//                     return 'Please enter a valid number';
//                   }
//                   return null;
//                 },
//               ),
//               TextFormField(
//                 onChanged: (value) {
//                   setState(() {
//                     _taxRate = double.tryParse(value) ?? 0.0;
//                   });
//                 },
//                 keyboardType: TextInputType.numberWithOptions(decimal: true),
//                 decoration: InputDecoration(
//                   labelText: 'Tax Rate',
//                 ),
//                 validator: (value) {
//                   if (value!.isEmpty) {
//                     return 'Please enter a tax rate';
//                   }
//                   if (double.tryParse(value) == null) {
//                     return 'Please enter a valid number';
//                   }
//                   return null;
//                 },
//               ),
//               ElevatedButton(
//                 onPressed: () {
//                   if (_formKey.currentState!.validate()) {
//                     addProduct();
//                   }
//                 },
//                 child: Text('Submit'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Future<void> addProduct() async {
//     try {
//       var body = json.encode({
//         'product_type': _selectedProductType,
//         'product_name': _productName,
//         'price': _sellingPrice,
//         'tax': _taxRate,
//       });
//
//       var response = await http.post(
//         Uri.parse('https://app.getswipe.in/api/public/add'),
//         headers: {'Content-Type': 'application/json'},
//         body: body,
//       );
//
//       if (response.statusCode == 200) {
//         // Product added successfully
//         // You can handle the success case as per your requirement
//
//         // Create a new product object with the submitted values
//         Product newProduct = Product(
//           productType: _selectedProductType!,
//           productName: _productName,
//           price: _sellingPrice,
//           tax: _taxRate,
//           image: '',
//         );
//
//         // Add the new product to the original list
//         widget.originalProducts.add(newProduct);
//
//         // Navigate back to the previous screen
//         Navigator.pop(context);
//       } else {
//         print('Request failed with status: ${response.statusCode}.');
//         // Handle the error case as per your requirement
//       }
//     } catch (error) {
//       print('Error: $error');
//       // Handle the error case as per your requirement
//     }
//   }
//
// }
