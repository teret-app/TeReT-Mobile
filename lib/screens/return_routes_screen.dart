import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ReturnRoutesScreen extends StatefulWidget {
  const ReturnRoutesScreen({super.key});

  @override
  State<ReturnRoutesScreen> createState() => _ReturnRoutesScreenState();
}

class _ReturnRoutesScreenState extends State<ReturnRoutesScreen> {
  final fromController = TextEditingController();
  final toController = TextEditingController();
  final capacityController = TextEditingController();
  final dateController = TextEditingController();

  List routes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchRoutes();
  }

  Future<void> fetchRoutes() async {
    try {
      final response = await http.get(
        Uri.parse("http://10.0.2.2:3000/return-routes"),
      );

      if (response.statusCode == 200) {
        setState(() {
          routes = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> createRoute() async {
    if (fromController.text.trim().isEmpty ||
        toController.text.trim().isEmpty ||
        capacityController.text.trim().isEmpty ||
        dateController.text.trim().isEmpty) {
      return;
    }

    await http.post(
      Uri.parse("http://10.0.2.2:3000/return-routes"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "fromCity": fromController.text.trim(),
        "toCity": toController.text.trim(),
        "date": dateController.text.trim(),
        "capacity": capacityController.text.trim(),
        "transporterEmail": "driver@test.com"
      }),
    );

    fromController.clear();
    toController.clear();
    capacityController.clear();
    dateController.clear();

    await fetchRoutes();
  }

  Future<void> selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      final formattedDate =
          "${picked.day.toString().padLeft(2, '0')}.${picked.month.toString().padLeft(2, '0')}.${picked.year}";
      setState(() {
        dateController.text = formattedDate;
      });
    }
  }

  Widget routeCard(dynamic route) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: const Icon(Icons.local_shipping, color: Colors.green),
        title: Text("${route["fromCity"]} → ${route["toCity"]}"),
        subtitle: Text(
          "Datum povratka: ${route["date"]}\nSlobodan prostor: ${route["capacity"]} paleta",
        ),
      ),
    );
  }

  @override
  void dispose() {
    fromController.dispose();
    toController.dispose();
    capacityController.dispose();
    dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Povratne rute"),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: fetchRoutes,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  TextField(
                    controller: fromController,
                    decoration: const InputDecoration(
                      labelText: "Grad polaska",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: toController,
                    decoration: const InputDecoration(
                      labelText: "Grad odredišta",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: capacityController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Slobodan prostor u kamionu (broj paleta)",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: dateController,
                    readOnly: true,
                    onTap: selectDate,
                    decoration: const InputDecoration(
                      labelText: "Datum povratka",
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: createRoute,
                      child: const Text("Objavi povratnu rutu"),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (routes.isEmpty)
                    const Text("Još nema objavljenih povratnih ruta.")
                  else
                    ...routes.map((route) => routeCard(route)),
                ],
              ),
            ),
    );
  }
}