import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Book Store',
      theme: ThemeData(
        primaryColor: Colors.indigo,
        colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Colors.amber),
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Montserrat', // Using custom font
        textTheme: TextTheme(
          headline6: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey[800]),
          subtitle1: TextStyle(fontSize: 16, color: Colors.grey[800]),
        ),
      ),
      home: LoginPage(), // Redirecting to login page initially
    );
  }
}

// Login Page
class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  // Hardcoded credentials
  static const String _validUsername = 'user';
  static const String _validPassword = 'password';

  // Function to validate credentials
  bool _validateCredentials(String username, String password) {
    return username == _validUsername && password == _validPassword;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Username',
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              obscureText: true, // Masking password
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                String username = _usernameController.text;
                String password = _passwordController.text;
                if (_validateCredentials(username, password)) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => BookListScreen()),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Invalid username or password!'),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(
                'Login',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Book List Screen
class BookListScreen extends StatefulWidget {
  @override
  _BookListScreenState createState() => _BookListScreenState();
}

class _BookListScreenState extends State<BookListScreen> {
  TextEditingController _controller = TextEditingController();
  List<String> _books = [
    'Book 1',
    'Book 2',
    'Book 3',
    // Add more book titles here
  ];

  List<String> _filteredBooks = [];

  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadBooks();
  }

  void _loadBooks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _books = prefs.getStringList('books') ?? [];
    });
  }

  void _saveBooks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList('books', _books);
  }

  void _addBook(String bookName) {
    setState(() {
      _books.add(bookName);
      _saveBooks();
    });
  }

  void _updateBook(int index, String currentName) {
    showDialog(
      context: context,
      builder: (context) {
        TextEditingController _updateController =
            TextEditingController(text: currentName);
        return AlertDialog(
          title: Text('Update Book'),
          content: TextField(
            controller: _updateController,
            decoration: InputDecoration(labelText: 'New Book Name'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _books[index] = _updateController.text;
                  _saveBooks();
                });
                Navigator.pop(context);
              },
              child: Text('Update'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _deleteBook(int index) {
    setState(() {
      _books.removeAt(index);
      _saveBooks();
    });
  }

  @override
  Widget build(BuildContext context) {
    _filteredBooks = _books.where((book) => book.toLowerCase().contains(_searchQuery.toLowerCase())).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Book Store'),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () {
              Navigator.pop(context); // Logout and go back to login page
            },
          ),
        ],
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
          Expanded(
            child: ListView.builder(
              itemCount: _filteredBooks.length,
              itemBuilder: (context, index) {
                return Card(
                  elevation: 3,
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  color: Colors.grey[200], // Background color of the card
                  child: ListTile(
                    title: Text(
                      _filteredBooks[index],
                      style: Theme.of(context).textTheme.headline6,
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () => _updateBook(index, _filteredBooks[index]),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () => _deleteBook(index),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('Add Book'),
                content: TextField(
                  controller: _controller,
                  decoration: InputDecoration(labelText: 'Book Name'),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      _addBook(_controller.text);
                      _controller.clear();
                      Navigator.pop(context);
                    },
                    child: Text('Add'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('Cancel'),
                  ),
                ],
              );
            },
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
