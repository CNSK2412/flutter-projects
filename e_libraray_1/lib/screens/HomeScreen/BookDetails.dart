import 'package:e_libraray_1/screens/HomeScreen/HomeScreen.dart';
import 'package:flutter/material.dart';

class BookDetails extends StatefulWidget {
  final Book book; // Receive the book object

  const BookDetails({super.key, required this.book});
  @override
  State<BookDetails> createState() => _BookDetailsState();
}

class _BookDetailsState extends State<BookDetails> {
  bool isFavorite = false;
  // Constructor to accept book object
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(193, 2, 151, 156),
        title: Text(
          widget.book.title,
          style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0)),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_outline,
              color: isFavorite
                  ? const Color.fromARGB(255, 255, 0, 0)
                  : const Color.fromARGB(255, 0, 0, 0),
            ),
            onPressed: () {
              setState(() {
                isFavorite = !isFavorite;
              });
              // Handle favorite action if needed
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Book Image
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  widget.book.imageUrl,
                  width: double.infinity,
                  height: 250,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: 20),

              // Book Title
              Text(
                widget.book.title,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 10),

              // Author Name
              Text(
                'by ${widget.book.author}',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 20),

              // Description (You can add your own description here)
              Text(
                'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nullam varius ligula at nisl gravida, nec luctus felis volutpat. Curabitur auctor nulla ut eros ullamcorper, vitae auctor est varius. Ut ultricies odio a magna auctor, a aliquet sapien varius.',
                style: TextStyle(
                  fontSize: 16,
                  height: 1.6,
                ),
              ),
              SizedBox(height: 20),

              // Maybe you could add buttons for actions (like borrowing or saving)
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    // Add action like "Borrow Book" or "Add to Wishlist"
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                    backgroundColor: Color.fromARGB(193, 2, 151, 156),
                    textStyle: TextStyle(fontSize: 16),
                  ),
                  child: Text('Download'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}