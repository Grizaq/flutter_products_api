import 'package:flutter/material.dart';
import 'package:flutter_products_api/models/products.dart';
import 'package:flutter_products_api/services/remote/remote_service.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import 'details_screen.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  _MainPageState createState() {
    return _MainPageState();
  }
}

class _MainPageState extends State<MainPage> {
  final ScrollController _scrollController = ScrollController();
  bool _showBackToTopButton = false;

  // Store the expansion state for each card
  List<bool> _expandedStates = [];

  late Products? products = Products(products: [], total: 0, skip: 0, limit: 0);
  List<Product> filteredProducts = [];
  List<String> categories = [];
  String selectedCategory = 'All';
  var isLoaded = false;

  @override
  void initState() {
    super.initState();
    getData();
    _scrollController.addListener(() {
      setState(() {
        _showBackToTopButton = _scrollController.offset > 300;
      });
    });
  }

  getData() async {
    try {
      products = await RemoteService().getProducts();
      if (products != null) {
        setState(() {
          categories = ['All', ...{...products!.products.map((e) => e.category.toString().split('.').last)}];
          filteredProducts = products!.products;

          _expandedStates = List.generate(products!.products.length, (_) => false);
          isLoaded = true;
        });
      } else {
        setState(() {
          isLoaded = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoaded = false;
      });
    }
  }

  void filterProducts(String category) {
    setState(() {
      selectedCategory = category;
      if (category == 'All') {
        filteredProducts = products!.products;
      } else {
        filteredProducts = products!.products
            .where((product) => product.category.toString().split('.').last == category)
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = (screenWidth ~/ 400).clamp(1, 3);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Flutter Example"),
      ),
      body: isLoaded
          ? (products!.products.isEmpty
          ? const Center(child: Text("No products available"))
          : Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: [
                // Category filter
                Container(
                  height: 60,
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      return GestureDetector(
                        onTap: () => filterProducts(category),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8.0),
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          decoration: BoxDecoration(
                            color: selectedCategory == category ? Colors.blue : Colors.grey[300],
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          child: Center(
                            child: Text(
                              category,
                              style: TextStyle(
                                color: selectedCategory == category ? Colors.white : Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // Product grid
                MasonryGridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(8.0),
                  gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                  ),
                  itemCount: filteredProducts.length,
                  itemBuilder: (context, index) {
                    final product = filteredProducts[index];
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _expandedStates[index] = !_expandedStates[index];
                        });
                      },
                      child: Padding(  // Add padding around each card to create space
                        padding: const EdgeInsets.all(8.0), // You can adjust this value for desired spacing
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          elevation: 4,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Thumbnail
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: Image.network(
                                    product.thumbnail,
                                    height: 200,
                                    width: double.infinity,
                                    fit: BoxFit.fitHeight,
                                  ),
                                ),
                                const SizedBox(height: 8.0),
                                // Title
                                Text(
                                  product.title,
                                  style: const TextStyle(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                                const SizedBox(height: 4.0),
                                // Price and Rating
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '\$${product.price.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      '${product.rating} ⭐',
                                      style: const TextStyle(color: Colors.grey),
                                    ),
                                  ],
                                ),
                                if (_expandedStates[index]) ...[
                                  const SizedBox(height: 8.0),
                                  // Description
                                  Text(
                                    product.description,
                                    style: const TextStyle(fontSize: 14.0),
                                  ),
                                  const SizedBox(height: 8.0),
                                  // Go to Details Button
                                  Center(
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ProductDetailsScreen(
                                              product: product,
                                            ),
                                          ),
                                        );
                                      },
                                      child: const Text('Go to details'),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          // Back to Top Button
          if (_showBackToTopButton)
            Positioned(
              bottom: 16,
              right: 16,
              child: FloatingActionButton(
                onPressed: () {
                  _scrollController.animateTo(
                    0,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                  );
                },
                child: const Icon(Icons.arrow_upward),
              ),
            ),
        ],
      ))
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
