import 'package:e_libraray_1/provider/favorite_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

class BookCard extends StatelessWidget {
  final Book book;
  const BookCard({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    final favoriteProvider = Provider.of<FavoriteProvider>(context);
    final isFavorite =
        favoriteProvider.isFavorite(book.title); // Check if favorite

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BookDetails(book: book),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(10)),
                child: Image.asset(
                  book.imageUrl,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          book.title,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'by ${book.author}',
                          style: TextStyle(color: Colors.grey[600]),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      favoriteProvider.toggleFavorite(book.title);
                    },
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_outline,
                      color: isFavorite ? Colors.red : Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
