import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Item Entry App',
      home: ItemEntryApp(),
    );
  }
}

class Item {
  final int id;
  final String name;
  final int amount;
  final double price;
  final DateTime createdAt;

  Item({
    required this.id,
    required this.name,
    required this.amount,
    required this.price,
    required this.createdAt,
  });
}

class ItemEntryApp extends StatefulWidget {
  @override
  _ItemEntryAppState createState() => _ItemEntryAppState();
}

class _ItemEntryAppState extends State<ItemEntryApp> {
  // --- Password/Login ---
  String hardcodedPassword = "1234";
  int attemptCount = 0;
  bool isBlocked = false;
  DateTime? blockEndTime;
  TextEditingController passwordController = TextEditingController();
  bool loggedIn = false;

  // --- Item Entry ---
  final nameController = TextEditingController();
  final amountController = TextEditingController();
  final priceController = TextEditingController();
  List<Item> items = [];

  void handleLogin() {
    if (isBlocked) {
      final now = DateTime.now();
      if (blockEndTime != null && now.isBefore(blockEndTime!)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Blocked! Try after 1 hour.')),
        );
        return;
      } else {
        isBlocked = false;
        attemptCount = 0;
      }
    }

    if (passwordController.text == hardcodedPassword) {
      attemptCount = 0;
      setState(() {
        loggedIn = true;
      });
    } else {
      attemptCount++;
      if (attemptCount >= 2) {
        isBlocked = true;
        blockEndTime = DateTime.now().add(Duration(hours: 1));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Blocked for 1 hour!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Incorrect password!')),
        );
      }
    }
  }

  void addItem() {
    if (nameController.text.isEmpty ||
        amountController.text.isEmpty ||
        priceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('All fields are required')),
      );
      return;
    }

    setState(() {
      items.add(Item(
        id: items.length + 1,
        name: nameController.text,
        amount: int.tryParse(amountController.text) ?? 0,
        price: double.tryParse(priceController.text) ?? 0.0,
        createdAt: DateTime.now(),
      ));
      nameController.clear();
      amountController.clear();
      priceController.clear();
    });
  }

  void cancelItem() {
    nameController.clear();
    amountController.clear();
    priceController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Item Entry App')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: loggedIn ? buildItemEntry() : buildLogin(),
      ),
    );
  }

  Widget buildLogin() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Enter 4-digit password:'),
        SizedBox(height: 8),
        TextField(
          controller: passwordController,
          obscureText: true,
          keyboardType: TextInputType.number,
          maxLength: 4,
          decoration: InputDecoration(border: OutlineInputBorder()),
        ),
        SizedBox(height: 8),
        ElevatedButton(onPressed: handleLogin, child: Text('Login')),
      ],
    );
  }

  Widget buildItemEntry() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(controller: nameController, decoration: InputDecoration(labelText: 'Name')),
          TextField(
            controller: amountController,
            decoration: InputDecoration(labelText: 'Amount'),
            keyboardType: TextInputType.number,
          ),
          TextField(
            controller: priceController,
            decoration: InputDecoration(labelText: 'Price'),
            keyboardType: TextInputType.number,
          ),
          Row(
            children: [
              ElevatedButton(onPressed: addItem, child: Text('Confirm')),
              SizedBox(width: 10),
              ElevatedButton(onPressed: cancelItem, child: Text('Cancel')),
            ],
          ),
          SizedBox(height: 20),
          Text('Items:', style: TextStyle(fontWeight: FontWeight.bold)),
          ...items.map((item) => Text(
              '${item.id}. ${item.name} - ${item.amount} pcs @ \$${item.price} (${item.createdAt.toLocal()})')),
        ],
      ),
    );
  }
}
