import 'package:flutter/material.dart';

class BookListScreen extends StatefulWidget {
  @override
  _BookListScreenState createState() => _BookListScreenState();
}

class _BookListScreenState extends State<BookListScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Book Store'),
      ),
      body: Column(
        children: [
          TextField(
            onChanged: (query) {
              setState(() {
                _searchQuery = query;
              });
            },
            decoration: InputDecoration(
              hintText: 'Search books...',
              prefixIcon: Icon(Icons.search),
            ),
          ),
          // Display book list here
        ],
      ),
    );
  }
}
