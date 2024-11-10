import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login.dart';

class IPSet extends StatefulWidget {
  const IPSet({Key? key}) : super(key: key);

  @override
  State<IPSet> createState() => _IPSetState();
}

class _IPSetState extends State<IPSet> {
  final TextEditingController ipController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text("Care Circle"),
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: TextField(
                  controller: ipController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Enter IP Address",
                    hintText: "Enter a valid IP address",
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () async {
                    String ip = ipController.text.trim();
                    if (ip.isNotEmpty) {
                      final sh = await SharedPreferences.getInstance();
                      sh.setString("url", "http://$ip:8000");
                      sh.setString('imgurl', "http://$ip:8000");
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const Login()),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Please enter a valid IP address")),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.cyan,
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  ),
                  child: const Text("Connect", style: TextStyle(fontSize: 18)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}