import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cached_network_image/cached_network_image.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: HomeScreen(),
  ));
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedCategory = "All";
  String searchQuery = "";

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
      appBar: AppBar(title: const Text("E-Library")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              decoration: const InputDecoration(
                hintText: "Search books...",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
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
              children: ["All", "Fiction", "Science", "History"]
                  .map((category) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: ChoiceChip(
                          label: Text(category),
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
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.7,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: filteredBooks.length,
                itemBuilder: (context, index) {
                  final book = filteredBooks[index];
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
                      elevation: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: CachedNetworkImage(
                              imageUrl: book["cover"]!,
                              fit: BoxFit.cover,
                              placeholder: (context, url) =>
                                  const Center(child: CircularProgressIndicator()),
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.error),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
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
                },
              ),
            ),
          ),
        ],
      ),
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
  bool isDownloading = false;

  Future<void> downloadPDF() async {
    setState(() {
      isDownloading = true;
    });

    String url = widget.book["pdfUrl"]!;
    String fileName = "${widget.book["title"]!.replaceAll(" ", "_")}.pdf";

    try {
      var status = await Permission.storage.request();
      if (!status.isGranted) {
        setState(() => isDownloading = false);
        return;
      }

      Directory dir = await getApplicationDocumentsDirectory();
      String savePath = "${dir.path}/$fileName";

      await Dio().download(url, savePath);
      setState(() {
        isDownloading = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Download Complete!")));
    } catch (e) {
      setState(() {
        isDownloading = false;
      });
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
            padding: const EdgeInsets.all(10),
            child: Text(widget.book["description"]!),
          ),
          ElevatedButton(
            onPressed: isDownloading ? null : downloadPDF,
            child: Text(isDownloading ? "Downloading..." : "Download PDF"),
          ),
        ],
      ),
    );
  }
}

List<Map<String, String>> books = [
  {
    "title": "The Future of AI",
    "category": "Science",
    "cover": "https://images.unsplash.com/photo-1512820790803-83ca734da794",
    "pdfUrl": "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf",
    "description": "A deep dive into the future of artificial intelligence."
  },
  {
    "title": "Mysterious Island",
    "category": "Fiction",
    "cover": "https://images.unsplash.com/photo-1524995997946-a1c2e315a42f",
    "pdfUrl": "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf",
    "description": "A thrilling adventure on a deserted island."
  },
  {
    "title": "World War II History",
    "category": "History",
    "cover": "https://images.unsplash.com/photo-1512820790803-83ca734da794",
    "pdfUrl": "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf",
    "description": "An in-depth analysis of World War II."
  }
];