import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart'; // Import for star rating bar

import '../models/products.dart'; // Update this with the actual path to your Product model

class ProductDetailsScreen extends StatefulWidget {
  final Product product;

  // Constructor to accept the product details
  const ProductDetailsScreen({Key? key, required this.product}) : super(key: key);

  @override
  _ProductDetailsScreenState createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  bool _expandReviews = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product.title), // Display product title in the AppBar
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Product Images with Paging Indicator
            CarouselSlider(
              items: widget.product.images.map((imageUrl) {
                return Image.network(imageUrl, fit: BoxFit.cover);
              }).toList(),
              options: CarouselOptions(
                height: 250.0,
                enlargeCenterPage: true,
                enableInfiniteScroll: false,
                viewportFraction: 1.0,
                autoPlay: true,
              ),
            ),
            const SizedBox(height: 16.0),

            // Product Title
            Text(
              widget.product.title,
              style: const TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8.0),

            // Price and Rating
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '\$${widget.product.price}',
                  style: const TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                RatingBar.builder(
                  initialRating: widget.product.rating,
                  minRating: 1,
                  direction: Axis.horizontal,
                  allowHalfRating: true,
                  itemCount: 5,
                  itemSize: 24.0,
                  itemBuilder: (context, index) => const Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  onRatingUpdate: (rating) {},
                ),
              ],
            ),
            const SizedBox(height: 16.0),

            // Product Description
            Text(
              widget.product.description,
              style: const TextStyle(fontSize: 16.0),
            ),
            const SizedBox(height: 16.0),

            // Reviews Section
            const Text(
              'Reviews',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8.0),

            // Horizontal scrollable cards for reviews
            Container(
              height: 120.0, // Adjust this based on desired card size
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: widget.product.reviews.length,
                itemBuilder: (context, index) {
                  final review = widget.product.reviews[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RatingBar.builder(
                            initialRating: review.rating.toDouble(),
                            minRating: 1,
                            direction: Axis.horizontal,
                            allowHalfRating: true,
                            itemCount: 5,
                            itemSize: 20.0,
                            itemBuilder: (context, index) => const Icon(
                              Icons.star,
                              color: Colors.amber,
                            ),
                            onRatingUpdate: (rating) {},
                          ),
                          const SizedBox(height: 8.0),
                          // Review text with 2 lines limit
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                review.comment,
                                style: const TextStyle(fontSize: 14.0),
                                maxLines: 2, // Limit comment to 2 lines
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (review.comment.length > 100) // Only show "See More" for long reviews
                                GestureDetector(
                                  onTap: () {
                                    _showReviewDialog(context, review.comment);
                                  },
                                  child: const Text(
                                    'See More',
                                    style: TextStyle(
                                      color: Colors.blue,
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16.0),

            // Expand/Collapse Button for Reviews
            if (widget.product.reviews.length > 5)
              GestureDetector(
                onTap: () {
                  setState(() {
                    _expandReviews = !_expandReviews;
                  });
                },
                child: Text(
                  _expandReviews ? 'Show Less' : 'Show More',
                  style: const TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Function to show the full review in a pop-up dialog
  void _showReviewDialog(BuildContext context, String fullReview) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog( //currently no long texts come from the API
          title: const Text('Full Review'),
          content: SingleChildScrollView(
            child: Text(fullReview),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
