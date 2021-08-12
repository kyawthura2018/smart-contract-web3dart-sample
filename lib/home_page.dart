import 'package:flutter/material.dart';

import 'doc_contract_page.dart';
import 'greeting_page.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home"),
      ),
      body: Container(
        child: Center(
          child: Text("This is Home Page"),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text("AKT",
                    style: TextStyle(
                      fontSize: 28,
                      color: Colors.blue,
                    )),
                minRadius: 28,
              ),
              accountName: Text("Aung Kyaw Thura"),
              accountEmail: Text("aungkyawthura.sbo@gmail.com"),
            ),
            ListTile(
              leading: Icon(Icons.accessibility_new),
              title: Text("Greeting SC"),
              subtitle: Text("Smart Contract Deployment"),
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GreetingApp(),
                  )),
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.accessibility_new),
              title: Text("Document SC"),
              subtitle: Text("Smart Contract Deployment"),
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DocumentApp(),
                  )),
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.accessibility_new),
              title: Text("Greeting SC"),
              subtitle: Text("Smart Contract Deployment"),
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GreetingApp(),
                  )),
            ),
            Divider(),
          ],
        ),
      ),
    );
  }
}
