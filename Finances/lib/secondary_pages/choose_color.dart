import 'package:flutter/material.dart';

class ChooseColor extends StatelessWidget {
  const ChooseColor({super.key});

  @override
  Widget build(BuildContext context) {
    List<Color> colors = [
      const Color.fromARGB(255, 5, 56, 99),
      const Color.fromARGB(255, 0, 92, 168),
      Colors.blue,
      const Color.fromARGB(255, 131, 183, 226),
      const Color.fromARGB(255, 22, 226, 209),
      const Color.fromARGB(255, 35, 236, 42),
      Colors.green,
      const Color.fromARGB(255, 6, 99, 9),
      Color.fromARGB(255, 60, 208, 19),
      const Color.fromARGB(255, 154, 214, 15),
      Colors.yellow,
      const Color.fromARGB(255, 255, 212, 57),
      Colors.orange,
      const Color.fromARGB(255, 253, 102, 26),
      Colors.red,
      const Color.fromARGB(255, 244, 31, 16),
      const Color.fromARGB(255, 168, 15, 4),
      const Color.fromARGB(255, 221, 11, 81),
      const Color.fromARGB(255, 245, 66, 126),
      const Color.fromARGB(255, 231, 28, 217),
      const Color.fromARGB(255, 172, 11, 162),
      const Color.fromARGB(255, 127, 8, 148),
      const Color.fromARGB(255, 233, 145, 255),
      const Color.fromARGB(255, 255, 145, 222),
      Color.fromARGB(255, 255, 176, 145),
      Color.fromARGB(255, 149, 100, 81),
      Color.fromARGB(255, 133, 56, 25),
      Color.fromARGB(255, 71, 28, 11),
      Colors.black,
      const Color.fromARGB(255, 66, 66, 66),
    ];
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        shape: const Border(bottom: BorderSide(width: 1)),
        title: const Text("Choose color"),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: ListView(
          physics: const BouncingScrollPhysics(),
          children: [
            const Padding(padding: EdgeInsets.only(bottom: 10)),
            ...List.generate(
              colors.length,
              (index) => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Material(
                    color: colors[index],
                    borderRadius: BorderRadius.circular(15),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(15),
                      onTap: () {
                        Navigator.pop(context, colors[index]);
                      },
                      child: Container(
                        height: 50,
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(width: 1)),
                      ),
                    ),
                  ),
                  const Padding(padding: EdgeInsets.only(bottom: 12)),
                ],
              ),
            ),
            const Padding(padding: EdgeInsets.only(bottom: 10)),
          ],
        ),
      ),
    );
  }
}
