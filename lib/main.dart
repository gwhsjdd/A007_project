import 'package:flutter/material.dart';
import 'dart:async';

void main() {
  runApp(const ItemTrackerApp());
}

class Item {
  String name;
  int amount;
  double price;
  DateTime timestamp;

  Item({required this.name, required this.amount, required this.price})
      : timestamp = DateTime.now();
}

class ItemTrackerApp extends StatelessWidget {
  const ItemTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Item Tracker',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: const LoginPage(),
    );
  }
}

// --- Login Page ---
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _passwordController = TextEditingController();
  final String hardcodedPassword = "1234"; // 4-digit password
  int attempts = 0;
  DateTime? blockedUntil;
  String? message;

  void login() {
    final now = DateTime.now();

    if (blockedUntil != null && now.isBefore(blockedUntil!)) {
      setState(() {
        message =
            "Too many wrong attempts! Try again at ${blockedUntil!.hour}:${blockedUntil!.minute}";
      });
      return;
    }

    if (_passwordController.text == hardcodedPassword) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const HomePage()));
    } else {
      attempts++;
      if (attempts >= 2) {
        blockedUntil = now.add(const Duration(hours: 1));
        attempts = 0;
        setState(() {
          message =
              "Too many wrong attempts! Blocked until ${blockedUntil!.hour}:${blockedUntil!.minute}";
        });
      } else {
        setState(() {
          message = "Wrong password. ${2 - attempts} attempt(s) left.";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          width: 300, // flatter box
          decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(5)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Enter 4-digit password",
                style: TextStyle(fontSize: 16),
              ),
              TextField(
                controller: _passwordController,
                keyboardType: TextInputType.number,
                obscureText: true,
                maxLength: 4,
                decoration: const InputDecoration(counterText: ""),
              ),
              ElevatedButton(onPressed: login, child: const Text("Login")),
              if (message != null)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    message!,
                    style: const TextStyle(color: Colors.red),
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }
}

// --- Home Page ---
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Item> items = [];
  final TextEditingController nameController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController priceController = TextEditingController();

  void addItem() {
    if (nameController.text.isEmpty ||
        amountController.text.isEmpty ||
        priceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("All fields are required")));
      return;
    }

    final item = Item(
        name: nameController.text,
        amount: int.tryParse(amountController.text) ?? 0,
        price: double.tryParse(priceController.text) ?? 0.0);

    setState(() {
      items.add(item);
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
      appBar: AppBar(title: const Text("Item Tracker")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // --- Input Box ---
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(5)),
              child: Column(
                children: [
                  TextField(
                    controller: nameController,
                    decoration:
                        const InputDecoration(labelText: "Item Name"),
                  ),
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "Amount"),
                  ),
                  TextField(
                    controller: priceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "Price"),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                          onPressed: addItem, child: const Text("Confirm")),
                      ElevatedButton(
                          onPressed: cancelItem, child: const Text("Cancel")),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 20),

            // --- Items List ---
            Expanded(
              child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return ListTile(
                      leading: Text("${index + 1}"), // automatic index
                      title: Text(item.name),
                      subtitle: Text(
                          "Amount: ${item.amount}, Price: \$${item.price.toStringAsFixed(2)}\n${item.timestamp.toString().split(".")[0]}"),
                    );
                  }),
            )
          ],
        ),
      ),
    );
  }
}
