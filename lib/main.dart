import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:product_app/add_product_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Product List',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ProductListScreen(),
    );
  }
}

class Product {
  final String image;
  final double price;
  final String productName;
  final String productType;
  final double tax;

  // static const String defaultImage =
  //     'https://example.com/default-image.png';

  Product({
    required this.image,
    required this.price,
    required this.productName,
    required this.productType,
    required this.tax,
  });

  // String getImageUrl() {
  //   return image.isNotEmpty ? image : defaultImage;
  // }
}

class ProductListScreen extends StatefulWidget {
  @override
  _ProductListScreenState createState() => _ProductListScreenState();
}
class _ProductListScreenState extends State<ProductListScreen> {
  List<Product> products = [];
  List<Product> originalProducts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    // Fetch products from the API and assign them to both products and originalProducts lists
    try {
      var response = await http.get(Uri.parse('https://app.getswipe.in/api/public/get'));
      if (response.statusCode == 200) {
        var data = json.decode(response.body) as List<dynamic>;
        List<Product> fetchedProducts = [];
        for (var item in data) {
          var product = Product(
            image: item['image'],
            price: item['price'].toDouble(),
            productName: item['product_name'],
            productType: item['product_type'],
            tax: item['tax'].toDouble(),
          );
          fetchedProducts.add(product);
        }
        setState(() {
          products = fetchedProducts;
          originalProducts = fetchedProducts; // Store the original product list
          isLoading = false;
        });
      } else {
        print('Request failed with status: ${response.statusCode}.');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  List<Product> _filterProducts(String query) {
    query = query.toLowerCase();
    return products.where((product) {
      final productName = product.productName.toLowerCase();
      return productName.contains(query);
    }).toList();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Product List'),
      ),
      body: isLoading ? _buildLoadingIndicator() : _buildProductList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddProductScreen(originalProducts: originalProducts),
          ),
          ).then((result) {
            if (result != null && result is Product) {
              // Handle the result, if needed
              // For example, you can update the UI or perform any necessary actions
            }
          });
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildProductList() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            onChanged: (value) {
              setState(() {
                if (value.isEmpty) {
                  products = originalProducts; // Reset to the original product list
                } else {
                  products = _filterProducts(value); // Filter products based on the search query
                }
              });
            },
            decoration: InputDecoration(
              labelText: 'Search products',
            ),
          )


        ),
        Expanded(
          child: ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              Product product = products[index];
              return ListTile(
                leading: product.image.isNotEmpty
                    ? Image.network(
                  product.image,
                  width: 48.0,
                  height: 48.0,
                )
                    : Image.asset(
                  'assets/images/image.jpg',
                  width: 48.0,
                  height: 48.0,
                ),
                title: Text(product.productName),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Type: ${product.productType}'),
                    Text('Tax: ${product.tax}%'),
                  ],
                ),
                trailing: Column(
                  children: [
                    Text('Price: \$${product.price.toStringAsFixed(2)}'),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }


}
