import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
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
        primaryColor: Colors.deepPurpleAccent,
        scaffoldBackgroundColor: Colors.grey[100],
        textTheme: GoogleFonts.poppinsTextTheme(),
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
  bool isGrid = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("E-Library", style: TextStyle(color: Colors.white)),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple, Colors.blueAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(isGrid ? Icons.list : Icons.grid_view,
                color: Colors.white),
            onPressed: () => setState(() => isGrid = !isGrid),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: isGrid
              ? GridView.builder(
                  key: const ValueKey(1),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.7,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: books.length,
                  itemBuilder: (context, index) {
                    return bookCard(books[index]);
                  },
                )
              : ListView.builder(
                  key: const ValueKey(2),
                  itemCount: books.length,
                  itemBuilder: (context, index) {
                    return bookListTile(books[index]);
                  },
                ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        onPressed: () {},
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget bookCard(Map<String, String> book) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BookDetailsScreen(book: book),
          ),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 8,
        shadowColor: Colors.deepPurpleAccent.withOpacity(0.4),
        child: Column(
          children: [
            Expanded(
              child: Hero(
                tag: book["title"]!,
                child: ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(15)),
                  child: CachedNetworkImage(
                    imageUrl: book["cover"]!,
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                        const Center(child: CircularProgressIndicator()),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.broken_image, size: 50),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Text(
                book["title"]!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold),
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
        imageUrl: book["cover"]!,
        width: 50,
        fit: BoxFit.cover,
        errorWidget: (context, url, error) => const Icon(Icons.broken_image),
      ),
      title: Text(book["title"]!,
          style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text("Author: ${book["author"]!}"),
      trailing: const Icon(Icons.arrow_forward_ios,
          size: 18, color: Colors.deepPurple),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BookDetailsScreen(book: book),
          ),
        );
      },
    );
  }
}

class BookDetailsScreen extends StatelessWidget {
  final Map<String, String> book;
  const BookDetailsScreen({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(book["title"]!),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Hero(
              tag: book["title"]!,
              child: CachedNetworkImage(
                imageUrl: book["cover"]!,
                height: 250,
                fit: BoxFit.cover,
                errorWidget: (context, url, error) =>
                    const Icon(Icons.broken_image, size: 100),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              book["author"]!,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              book["description"]!,
              textAlign: TextAlign.justify,
            ),
          ],
        ),
      ),
    );
  }
}

List<Map<String, String>> books = [
  {
    "title": "The Future of AI",
    "author": "John Doe",
    "cover": "https://source.unsplash.com/200x300/?technology,ai",
    "description": "A deep dive into AI advancements."
  },
  {
    "title": "Mysterious Island",
    "author": "Jules Verne",
    "cover": "https://source.unsplash.com/200x300/?adventure,book",
    "description": "An exploration of a mysterious island."
  }
];
