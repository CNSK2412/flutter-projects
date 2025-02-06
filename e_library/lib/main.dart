import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isDarkMode = true; // Flag to toggle dark mode

  @override
  Widget build(BuildContext context) {
    return AnimatedTheme(
      data: isDarkMode
          ? ThemeData.dark().copyWith(
              primaryColor: Colors.orangeAccent,
              scaffoldBackgroundColor: Color(0xFF121212),
              textTheme: GoogleFonts.latoTextTheme(),
            )
          : ThemeData.light().copyWith(
              primaryColor: Colors.blueAccent,
              scaffoldBackgroundColor: Color(0xFFFAFAFA),
              textTheme: GoogleFonts.latoTextTheme(),
            ),
      duration: const Duration(milliseconds: 300), // Smooth transition duration
      child: MaterialApp(
        title: 'E-Library',
        debugShowCheckedModeBanner: false,
        home: HomeScreen(
          isDarkMode: isDarkMode,
          toggleTheme: toggleTheme,
        ),
      ),
    );
  }

  // Toggle dark and light mode
  void toggleTheme() {
    setState(() {
      isDarkMode = !isDarkMode;
    });
  }
}

class HomeScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback toggleTheme;

  const HomeScreen(
      {Key? key, required this.isDarkMode, required this.toggleTheme})
      : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedCategory = "All";
  String searchQuery = "";
  bool isGrid = true;

  @override
  Widget build(BuildContext context) {
    List<Map<String, String>> filteredBooks = books.where((book) {
      bool matchesCategory =
          selectedCategory == "All" || book["category"] == selectedCategory;
      bool matchesSearch =
          book["title"]!.toLowerCase().contains(searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("E-Library", style: TextStyle(color: Colors.white)),
        backgroundColor:
            widget.isDarkMode ? Colors.orangeAccent : Colors.blueAccent,
        actions: [
          Switch(
            value: widget.isDarkMode,
            onChanged: (value) {
              widget.toggleTheme();
            },
            activeColor: Colors.white,
            inactiveThumbColor: Colors.blueAccent,
            inactiveTrackColor: Colors.white38,
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
                fillColor: Colors.blueAccent.withOpacity(0.2),
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.search, color: Colors.white70),
              ),
              style: const TextStyle(color: Colors.white),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                "All",
                "Fiction",
                "Science",
                "History",
                "Biography",
                "Self-Help",
                "Technology"
              ]
                  .map((category) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: ChoiceChip(
                          label: Text(category,
                              style: const TextStyle(color: Colors.white)),
                          backgroundColor: Colors.blueAccent.withOpacity(0.2),
                          selectedColor: Colors.orangeAccent,
                          selected: selectedCategory == category,
                          onSelected: (selected) {
                            setState(() {
                              selectedCategory = category;
                            });
                          },
                        ),
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 10),
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
                      itemCount: filteredBooks.length,
                      itemBuilder: (context, index) {
                        return bookCard(filteredBooks[index]);
                      },
                    )
                  : ListView.builder(
                      itemCount: filteredBooks.length,
                      itemBuilder: (context, index) {
                        return bookListTile(filteredBooks[index]);
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget bookCard(Map<String, String> book) {
    return GestureDetector(
      onTap: () => openBookDetails(book),
      child: Card(
        color: const Color(0xFF252525),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
                child: CachedNetworkImage(
                  imageUrl: book["cover"]!,
                  fit: BoxFit.cover,
                  placeholder: (context, url) =>
                      const Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) =>
                      const Icon(Icons.error, color: Colors.red),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                book["title"]!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.orangeAccent),
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
      title: Text(book["title"]!,
          style: const TextStyle(color: Colors.orangeAccent)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Author: ${book["author"]!}",
              style: const TextStyle(color: Colors.white70)),
          Text("Published: ${book["year"]!}",
              style: const TextStyle(color: Colors.white70)),
          Text(book["description"]!,
              style: const TextStyle(color: Colors.white54, fontSize: 12)),
        ],
      ),
      onTap: () => openBookDetails(book),
    );
  }

  void openBookDetails(Map<String, String> book) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => BookDetailsScreen(book: book)),
    );
  }
}

class BookDetailsScreen extends StatefulWidget {
  final Map<String, String> book;
  const BookDetailsScreen({super.key, required this.book});

  @override
  _BookDetailsScreenState createState() => _BookDetailsScreenState();
}

class _BookDetailsScreenState extends State<BookDetailsScreen> {
  double downloadProgress = 0.0;

  Future<void> downloadPDF(BuildContext context) async {
    String url = widget.book["pdfUrl"]!;
    String fileName = "${widget.book["title"]!.replaceAll(" ", "_")}.pdf";
    Directory dir = await getApplicationDocumentsDirectory();
    String savePath = "${dir.path}/$fileName";

    try {
      await Dio().download(
        url,
        savePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            setState(() {
              downloadProgress = (received / total) * 100;
            });
          }
        },
      );
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Download Complete!")));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Download Failed!")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.book["title"]!)),
      body: Column(
        children: [
          Image.network(widget.book["cover"]!, height: 250),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(widget.book["description"]!,
                style: const TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () => downloadPDF(context),
            child: const Text("Download PDF"),
          ),
          if (downloadProgress > 0)
            LinearProgressIndicator(value: downloadProgress / 100),
        ],
      ),
    );
  }
}

List<Map<String, String>> books = [
  {
    "title": "The Future of AI",
    "category": "Technology",
    "cover":
        "https://i.pinimg.com/736x/e2/44/c1/e244c15f6e36060c3044484b81e2737f.jpg",
    "pdfUrl":
        "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf",
    "author": "John Doe",
    "year": "2023",
    "description": "A deep dive into AI advancements."
  },
  {
    "title": "Mysterious Island",
    "category": "Fiction",
    "cover": "https://source.unsplash.com/200x300/?adventure,fiction",
    "pdfUrl":
        "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf",
    "author": "Jules Verne",
    "year": "1874",
    "description": "An exploration of a mysterious island."
  },
  {
    "title": "Mysterious Island",
    "category": "Fiction",
    "cover": "https://source.unsplash.com/200x300/?adventure,fiction",
    "pdfUrl":
        "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf",
    "author": "Jules Verne",
    "year": "1874",
    "description": "An exploration of a mysterious island."
  },
  {
    "title": "Mysterious Island",
    "category": "Fiction",
    "cover": "https://source.unsplash.com/200x300/?adventure,fiction",
    "pdfUrl":
        "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf",
    "author": "Jules Verne",
    "year": "1874",
    "description": "An exploration of a mysterious island."
  },
  {
    "title": "Mysterious Island",
    "category": "Fiction",
    "cover": "https://source.unsplash.com/200x300/?adventure,fiction",
    "pdfUrl":
        "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf",
    "author": "Jules Verne",
    "year": "1874",
    "description": "An exploration of a mysterious island."
  },
  {
    "title": "Mysterious Island",
    "category": "Fiction",
    "cover": "https://source.unsplash.com/200x300/?adventure,fiction",
    "pdfUrl":
        "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf",
    "author": "Jules Verne",
    "year": "1874",
    "description": "An exploration of a mysterious island."
  },
  {
    "title": "Mysterious Island",
    "category": "Fiction",
    "cover": "https://source.unsplash.com/200x300/?adventure,fiction",
    "pdfUrl":
        "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf",
    "author": "Jules Verne",
    "year": "1874",
    "description": "An exploration of a mysterious island."
  },
  {
    "title": "Mysterious Island",
    "category": "Fiction",
    "cover": "https://source.unsplash.com/200x300/?adventure,fiction",
    "pdfUrl":
        "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf",
    "author": "Jules Verne",
    "year": "1874",
    "description": "An exploration of a mysterious island."
  },
  {
    "title": "Mysterious Island",
    "category": "Fiction",
    "cover": "https://source.unsplash.com/200x300/?adventure,fiction",
    "pdfUrl":
        "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf",
    "author": "Jules Verne",
    "year": "1874",
    "description": "An exploration of a mysterious island."
  },
  {
    "title": "Mysterious Island",
    "category": "Fiction",
    "cover": "https://source.unsplash.com/200x300/?adventure,fiction",
    "pdfUrl":
        "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf",
    "author": "Jules Verne",
    "year": "1874",
    "description": "An exploration of a mysterious island."
  },
  {
    "title": "Mysterious Island",
    "category": "Fiction",
    "cover": "https://source.unsplash.com/200x300/?adventure,fiction",
    "pdfUrl":
        "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf",
    "author": "Jules Verne",
    "year": "1874",
    "description": "An exploration of a mysterious island."
  },
  {
    "title": "Mysterious Island",
    "category": "Fiction",
    "cover": "https://source.unsplash.com/200x300/?adventure,fiction",
    "pdfUrl":
        "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf",
    "author": "Jules Verne",
    "year": "1874",
    "description": "An exploration of a mysterious island."
  },
  {
    "title": "Mysterious Island",
    "category": "Fiction",
    "cover": "https://source.unsplash.com/200x300/?adventure,fiction",
    "pdfUrl":
        "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf",
    "author": "Jules Verne",
    "year": "1874",
    "description": "An exploration of a mysterious island."
  },
  {
    "title": "Mysterious Island",
    "category": "Fiction",
    "cover": "https://source.unsplash.com/200x300/?adventure,fiction",
    "pdfUrl":
        "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf",
    "author": "Jules Verne",
    "year": "1874",
    "description": "An exploration of a mysterious island."
  },
  {
    "title": "Mysterious Island",
    "category": "Fiction",
    "cover": "https://source.unsplash.com/200x300/?adventure,fiction",
    "pdfUrl":
        "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf",
    "author": "Jules Verne",
    "year": "1874",
    "description": "An exploration of a mysterious island."
  },
  {
    "title": "Mysterious Island",
    "category": "Fiction",
    "cover": "https://source.unsplash.com/200x300/?adventure,fiction",
    "pdfUrl":
        "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf",
    "author": "Jules Verne",
    "year": "1874",
    "description": "An exploration of a mysterious island."
  },
];
