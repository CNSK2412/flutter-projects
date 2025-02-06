import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final Set<Map<String, String>> favoriteBooks = {};

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'E-Library',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF80C4FF), // Light blue
        scaffoldBackgroundColor: const Color(0xFFFFF8E7), // Soft beige
        textTheme: GoogleFonts.latoTextTheme(),
      ),
      home: HomeScreen(favoriteBooks: favoriteBooks),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final Set<Map<String, String>> favoriteBooks;
  const HomeScreen({super.key, required this.favoriteBooks});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedCategory = "All";
  String searchQuery = "";
  bool isGrid = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("E-Library", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF80C4FF),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      FavoritesScreen(favoriteBooks: widget.favoriteBooks),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(isGrid ? Icons.list : Icons.grid_view,
                color: Colors.white),
            onPressed: () {
              setState(() {
                isGrid = !isGrid;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search books...",
                fillColor: const Color(0xFFA8E6CF)
                    .withOpacity(0.3), // Light green tint
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF6D6D6D)),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: isGrid
                  ? GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.75,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: books.length,
                      itemBuilder: (context, index) {
                        return bookCard(books[index]);
                      },
                    )
                  : ListView.builder(
                      itemCount: books.length,
                      itemBuilder: (context, index) {
                        return bookListTile(books[index]);
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget bookCard(Map<String, String> book) {
    bool isFavorite = widget.favoriteBooks.contains(book);
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BookDetailsScreen(
              book: book,
              favoriteBooks: widget.favoriteBooks,
            ),
          ),
        ).then((_) {
          setState(() {});
        });
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: CachedNetworkImage(
                    imageUrl: book["cover"]!,
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Text(book["title"]!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            Positioned(
              top: 5,
              right: 5,
              child: IconButton(
                icon: Icon(isFavorite ? Icons.star : Icons.star_border,
                    color: Colors.yellow),
                onPressed: () {
                  setState(() {
                    if (isFavorite) {
                      widget.favoriteBooks.remove(book);
                    } else {
                      widget.favoriteBooks.add(book);
                    }
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget bookListTile(Map<String, String> book) {
    return ListTile(
      leading: CachedNetworkImage(
          imageUrl: book["cover"]!, width: 50, fit: BoxFit.cover),
      title: Text(book["title"]!),
      subtitle: Text("Author: ${book["author"]!}"),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BookDetailsScreen(
              book: book,
              favoriteBooks: widget.favoriteBooks,
            ),
          ),
        ).then((_) {
          setState(() {});
        });
      },
    );
  }
}

class BookDetailsScreen extends StatefulWidget {
  final Map<String, String> book;
  final Set<Map<String, String>> favoriteBooks;
  const BookDetailsScreen(
      {super.key, required this.book, required this.favoriteBooks});

  @override
  _BookDetailsScreenState createState() => _BookDetailsScreenState();
}

class _BookDetailsScreenState extends State<BookDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    bool isFavorite = widget.favoriteBooks.contains(widget.book);

    return Scaffold(
      appBar: AppBar(title: Text(widget.book["title"]!)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CachedNetworkImage(imageUrl: widget.book["cover"]!, height: 200),
            const SizedBox(height: 10),
            Text(widget.book["author"]!,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text(widget.book["description"]!),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: Icon(isFavorite ? Icons.star : Icons.star_border,
                      color: Colors.yellow),
                  onPressed: () {
                    setState(() {
                      if (isFavorite) {
                        widget.favoriteBooks.remove(widget.book);
                      } else {
                        widget.favoriteBooks.add(widget.book);
                      }
                    });
                  },
                ),
                ElevatedButton(
                  child: const Text("Download"),
                  onPressed: () {},
                ),
                ElevatedButton(
                  child: const Text("Online View"),
                  onPressed: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class FavoritesScreen extends StatelessWidget {
  final Set<Map<String, String>> favoriteBooks;
  const FavoritesScreen({super.key, required this.favoriteBooks});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Favorites")),
      body: ListView(
        children: favoriteBooks
            .map((book) => ListTile(title: Text(book["title"]!)))
            .toList(),
      ),
    );
  }
}

List<Map<String, String>> books = [
  {
    "title": "The Future of AI",
    "author": "John Doe",
    "cover":
        "https://i.pinimg.com/736x/e2/44/c1/e244c15f6e36060c3044484b81e2737f.jpg",
    "description": "A deep dive into AI advancements."
  },
  {
    "title": "Mysterious Island",
    "author": "Jules Verne",
    "cover": "https://source.unsplash.com/200x300/?adventure,fiction",
    "description": "An exploration of a mysterious island."
  }
];
