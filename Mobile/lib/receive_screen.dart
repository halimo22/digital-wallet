import 'dart:convert';
import 'package:flutter/material.dart';

class ReceiveScreen extends StatefulWidget {
  @override
  _ReceiveScreenState createState() => _ReceiveScreenState();
}

class _ReceiveScreenState extends State<ReceiveScreen> {
  TextEditingController amountController = TextEditingController();
  String base64QRCode = ''; // Holds the Base64-encoded QR code from the backend
  bool isLoading = false;

  Future<void> fetchQRCode(String amount) async {
    // Simulate a backend request to fetch the QR code
    setState(() {
      isLoading = true;
    });

    // Mock backend response (replace with actual backend call)
    await Future.delayed(Duration(seconds: 2)); // Simulated delay
    String mockBase64QRCode = await getMockQRCodeFromBackend(amount);

    setState(() {
      base64QRCode = mockBase64QRCode;
      isLoading = false;
    });
  }

  Future<String> getMockQRCodeFromBackend(String amount) async {
    // Replace this with your API call to fetch a Base64-encoded QR code
    // Here is an example of how you might encode a QR code:
    String qrData = "eWalletApp|amount:$amount";
    var bytes = utf8.encode(qrData);
    return base64Encode(bytes); // Simulated Base64 QR code
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[900],
        title: Text("Receive Money"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Enter Amount",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Enter amount",
              ),
            ),
            SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  String amount = amountController.text.trim();
                  if (amount.isEmpty || double.tryParse(amount) == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Please enter a valid amount")),
                    );
                  } else {
                    fetchQRCode(amount);
                  }
                },
                child: Text("Fetch QR Code"),
              ),
            ),
            SizedBox(height: 24),
            if (isLoading)
              Center(
                child: CircularProgressIndicator(),
              ),
            if (!isLoading && base64QRCode.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Scan this QR Code to Receive Money",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  Center(
                    child: Image.memory(
                      base64Decode("iVBORw0KGgoAAAANSUhEUgAAAJQAAACUCAYAAAB1PADUAAAAAklEQVR4AewaftIAAAT3SURBVO3BQY4jRxAEwfAC//9l1xzzVECjk7NaKczwR6qWnFQtOqladFK16KRq0UnVopOqRSdVi06qFp1ULTqpWnRSteikatFJ1aKTqkUnVYs+eQnIb1LzBJBJzQTkRs0EZFLzBJBJzQ2Q36TmjZOqRSdVi06qFn2yTM0mIG+omYBMaiYgE5AngNyomYBMam7UbAKy6aRq0UnVopOqRZ98GZAn1DwB5A0gN2omIDdqfhOQJ9R800nVopOqRSdViz75n1EzAZnUTECeAHKjZlLzX3JSteikatFJ1aJP/mPUTEDeUDMBmYA8AeRGzd/spGrRSdWik6pFn3yZmt8EZFIzAfkmNb9Jzb/JSdWik6pFJ1WLPlkG5E9SMwGZ1ExAboBMaiYgN0AmNROQSc0NkH+zk6pFJ1WLTqoW4Y/8xYC8oeYGyBNqboDcqPmbnVQtOqladFK1CH/kBSCTmgnIJjU3QG7U/CYgk5ongGxS800nVYtOqhadVC3CH1kEZFIzAblRcwNkUvMGkDfUPAHkm9Q8AWRS88ZJ1aKTqkUnVYs+WaZmAjKpmYDcAJnUTEAmNROQTWqeADKpeQPIG0AmNZtOqhadVC06qVr0yUtAJjWb1NyomYBMaiYgk5oJyKRmAjKp2QTkRs0EZAIyqZnUTEAmNW+cVC06qVp0UrUIf2QRkEnNBGRSMwG5UfMEkEnNE0AmNROQSc0E5A01E5BJzQ2QSc03nVQtOqladFK16JNfpuZGzRNA"
                          "JjWb1ExAJjUTkEnNBGRSMwGZgExqJiA3am6ATGreOKladFK16KRq0SfL1ExA/iQ1E5AbNd+kZgIyqZmATEAmNROQGyCTmk0nVYtOqhadVC365CUgk5pJzSYgk5oJyKRmUjMBuQFyA+Sb1NwAmdT8SSdVi06qFp1ULfrkJTUTkBs1E5BJzQTkm9TcqHkCyATkRs0EZFIzAZnUTEBu1HzTSdWik6pFJ1WLPnkJyKTmDSCTmjeA3KiZgDyhZlJzA+RGzQRkUjMBuVEzAblR88ZJ1aKTqkUnVYs++TIgk5obNROQSc0E5Ak1E5An1ExAnlDzhJoJyKRmAjIBmdR800nVopOqRSdViz75w9RMQCY1E5BJzRtqJiCTmgnIjZoJyARkUjMBmdTcALlRcwNkUvPGSdWik6pFJ1WLPvmXAzKpuQEyqZmATGomNROQSc0NkEnNDZAbIE+omYDcqNl0UrXopGrRSdUi/JG/GJAbNTdAJjU3QG7UTECeUPMEkBs1N0AmNW+cVC06qVp0UrXok5eA/CY1k5ongPwmNROQJ4BMam7U3ACZ1Gw6qVp0UrXopGrRJ8vUbAJyA2RSc6NmAnID5EbNBORGzQTkRs0TQCY1v+mkatFJ1aKTqkWffBmQJ9S8AeQJNTdqboBMaiYgTwB5Q80E5AbIpOaNk6pFJ1WLTqoWffIfo2YCMqmZgExqJiBPAJnUTEBu1NwAmdTcqPlNJ1WLTqoWnVQt+uR/Bsg3qZmATGpugNyomYC8oWbTSdWik6pFJ1WLPvkyNd+kZgJyo2YC8oaaGzU3QG7UTEBu1NwA+aaTqkUnVYtOqhZ9sgzIbwLyTWomIE8AuVFzA+RGzQ2QSc03nVQtOqladFK1CH+kaslJ1aKTqkUnVYtOqhadVC06qVp0UrXopGrRSdWik6pFJ1WLTqoWnVQtOqladFK16B+6zlRFs26+1wAAAABJRU5ErkJggg=="),
                      width: 200,
                      height: 200,
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

void main() => runApp(MaterialApp(home: ReceiveScreen()));