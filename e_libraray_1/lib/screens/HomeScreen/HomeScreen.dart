import 'package:e_libraray_1/screens/HomeScreen/BookCard.dart';
import 'package:flutter/material.dart';
//import 'package:shared_preferences/shared_preferences.dart';

class Book {
  final String title;
  final String author;
  final String imageUrl;

  Book({
    required this.title,
    required this.author,
    required this.imageUrl,
  });
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Book> bookList = [
    Book(
      title: 'Book Title 1',
      author: 'Author 1',
      imageUrl: 'assets/cartoon-boy.jpg',
    ),
    Book(
      title: 'Book Title 2',
      author: 'Author 2',
      imageUrl: 'assets/dog.jpg',
    ),
    Book(
      title: 'Book Title 3',
      author: 'Author 3',
      imageUrl: 'assets/logo.jpg',
    ),
  ];

  List<Book> filteredBooks = []; // List to store filtered books
  String query = '';

  @override
  void initState() {
    super.initState();
    filteredBooks = bookList; // Initialize with all books
  }

  void updateSearchQuery(String query) {
    setState(() {
      this.query = query;
      filteredBooks = bookList
          .where((book) =>
              book.title.toLowerCase().contains(query.toLowerCase()) ||
              book.author.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(193, 2, 151, 156),
        title: Text('E-Library',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: Colors.white)),
        actions: [
          Padding(
              padding: EdgeInsets.all(10),
              child: IconButton(
                icon: Icon(Icons.notifications),
                color: Colors.white,
                onPressed: () {},
              ))
        ],
      ),
      body: Column(
        children: [
          SafeArea(
            child: Container(
              padding: const EdgeInsets.all(10),
              child: TextField(
                onChanged: updateSearchQuery, // Update on text change
                decoration: InputDecoration(
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: EdgeInsets.all(15),
                  hintText: 'Search books....',
                  prefixIcon: const Icon(Icons.search_outlined),
                ),
              ),
            ),
          ),
          SizedBox(height: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(5),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.7,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                ),
                itemCount: filteredBooks.length,
                itemBuilder: (context, index) {
                  return BookCard(book: filteredBooks[index]);
                },
              ),
            ),
          )
        ],
      ),
    );
  }
}




