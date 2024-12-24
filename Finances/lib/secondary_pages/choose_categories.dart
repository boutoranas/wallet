import 'package:flutter/material.dart';

import '../utils/app_data.dart';

class ChooseCategory extends StatelessWidget {
  const ChooseCategory({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          shape: Border(bottom: BorderSide(width: 1)),
          title: Text("Choose category"),
        ),
        body: ListView(
          physics: BouncingScrollPhysics(),
          children: [
            Padding(padding: EdgeInsets.only(bottom: 10)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                "Categories",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(padding: EdgeInsets.only(bottom: 10)),
            ...List.generate(
                categories.length,
                (i) => ListTile(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChooseSubcategory(
                                  category: categories[i],
                                  categories: categories),
                            )).then((value) {
                          if (value != null) {
                            Navigator.pop(context, value);
                          }
                        });
                      },
                      key: ValueKey(categories[i].name),
                      title: Text(categories[i].name),
                      leading: CircleAvatar(
                        backgroundColor: categories[i].color,
                        child: Container(
                          child: Icon(
                            categories[i].iconData,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ), //
                      trailing: Icon(Icons.arrow_right_outlined),
                    ))
          ],
        ));
  }
}

class Category {
  String name;
  IconData iconData;
  Color color;
  Category({required this.name, required this.iconData, required this.color});
}

class ChooseSubcategory extends StatefulWidget {
  final List<Category> categories;
  final Category category;
  const ChooseSubcategory(
      {super.key, required this.category, required this.categories});

  @override
  State<ChooseSubcategory> createState() => _ChooseSubcategoryState();
}

class _ChooseSubcategoryState extends State<ChooseSubcategory> {
  @override
  Widget build(BuildContext context) {
    List<SubCategory> subcategoriesToChoose = subcategories
        .where((element) => element.category == widget.category)
        .toList();
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        shape: Border(bottom: BorderSide(width: 1)),
        title: Text("Choose sub-category"),
      ),
      body: ListView(
        physics: BouncingScrollPhysics(),
        children: [
          Padding(padding: EdgeInsets.only(bottom: 10)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              "Sub-categories",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(padding: EdgeInsets.only(bottom: 10)),
          ...List.generate(
              subcategoriesToChoose.length,
              (i) => ListTile(
                    onTap: () {
                      Navigator.pop(
                          context,
                          subcategoriesToChoose[i].name != "General"
                              ? subcategoriesToChoose[i].name
                              : subcategoriesToChoose[i].category.name);
                    },
                    key: ValueKey(subcategoriesToChoose[i].name),
                    title: Text(subcategoriesToChoose[i].name),
                    leading: CircleAvatar(
                      backgroundColor: subcategoriesToChoose[i].color,
                      child: Container(
                        child: Icon(
                          subcategoriesToChoose[i].iconData,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ), //
                    trailing: Icon(Icons.arrow_right_outlined),
                  ))
        ],
      ),
    );
  }
}

class SubCategory {
  String name;
  Category category;
  IconData iconData;
  Color color;
  SubCategory({
    required this.name,
    required this.iconData,
    required this.color,
    required this.category,
  });
}
