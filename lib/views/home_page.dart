import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_products_api/models/products.dart';
import 'package:flutter_products_api/services/remote/remote_service.dart';

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
  List<int> _currentPageIndex = [];  // Track the current page index for each card

  late Products? products = Products(products: [], total: 0, skip: 0, limit: 0);
  var isLoaded = false;

  @override
  void initState() {
    super.initState();
    getData();
    _scrollController.addListener(() {
      setState(() {
        _showBackToTopButton = _scrollController.offset >
            300; // Show button if scrolled past 300px
      });
    });
  }

  getData() async {
    try {
      products = await RemoteService().getProducts();
      if (products != null) {
        setState(() {
          // Initialize _expandedStates and _currentPageIndex
          _expandedStates = List.generate(products!.products.length, (_) => false);
          _currentPageIndex = List.generate(products!.products.length, (_) => 0);  // Set initial index to 0
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Flutter example"),
      ),
      body: isLoaded
          ? (products!.products.isEmpty
          ? const Center(child: Text("No products available"))
          : Stack(
        children: [
          ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(8.0),
            itemCount: products!.products.length,
            itemBuilder: (context, index) {
              final product = products?.products[index];

              if (product == null) {
                return const SizedBox.shrink();
              }

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _expandedStates[index] =
                    !_expandedStates[index];
                  });
                },
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(
                      vertical: 10.0, horizontal: 15.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
                            CarouselSlider(
                              items: product?.images.map((imageUrl) {
                                return Image.network(imageUrl,
                                    fit: BoxFit.cover);
                              }).toList(),
                              options: CarouselOptions(
                                height: 150.0,
                                enlargeCenterPage: true,
                                enableInfiniteScroll: true,
                                viewportFraction: 1.0,
                                onPageChanged: (index, reason) {
                                  setState(() {
                                    _currentPageIndex[products!.products.indexOf(product)] = index;
                                  });
                                },
                              ),
                            ),
                            Positioned(
                              bottom: 8,
                              left: 0,
                              right: 0,
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.center,
                                children: List.generate(
                                  product?.images.length ?? 0,
                                      (pageIndex) {
                                    return Container(
                                      width: 8.0,
                                      height: 8.0,
                                      margin: const EdgeInsets
                                          .symmetric(horizontal: 4.0),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: pageIndex ==
                                            _currentPageIndex[products!.products.indexOf(product)]
                                            ? Colors.white
                                            : Colors.grey,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8.0),
                        Center(
                          child: Text(
                            product?.title ?? 'No title',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18.0,
                            ),
                            maxLines: _expandedStates[index] ? 3 : 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(height: 4.0),
                        Center(
                          child: Text(
                            product?.description ?? 'No description',
                            style: const TextStyle(fontSize: 14.0),
                            maxLines: _expandedStates[index] ? 15 : 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        if (_expandedStates[index])
                          Align(
                            alignment: Alignment.center,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ProductDetailsScreen(
                                          product: products!
                                              .products[index],
                                        ),
                                  ),
                                );
                              },
                              child: const Text('Go to details'),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
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
