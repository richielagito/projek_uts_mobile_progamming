import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.black,
          title: const SizedBox(
            height: 50,
            width: 120,
            child: Image(image: AssetImage('assets/images/img1.png')),
          ),
        ),
        body: Column(
          children: [
            Container(
              color: Colors.grey.shade700,
              height: 1,
              width: MediaQuery.of(context).size.width,
            )
          ],
        ));
  }
}

Widget _listItem(int index) {
  return ListTile(
      leading: CircleAvatar(backgroundImage: AssetImage("assets/profile.png")),
      title: Text(
        "Geda.Gedi",
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        "Hello this is Geda gedi ",
        overflow: TextOverflow.clip,
        maxLines: 3,
      ));
}
