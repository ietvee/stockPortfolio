import 'package:flutter/material.dart';

class FavoriteWordsRoute extends StatelessWidget {
  final List<List<dynamic>> favoriteItems;

  const FavoriteWordsRoute({Key? key, required this.favoriteItems}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorite Company'),
      ),
      body: ListView.separated(
        itemCount: favoriteItems.length,
        separatorBuilder: (BuildContext context, int index) => Divider(),
        itemBuilder: (BuildContext context, int index) => ListTile(
          title: Text(favoriteItems[index][1].toString()),
        ),
      ),
    );
  }
}