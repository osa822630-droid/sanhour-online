import 'package:flutter/material.dart';
import '../providers/shops_provider.dart';
import 'package:provider/provider.dart';

class HorizontalList extends StatelessWidget {
  final String title;
  final String type;

  const HorizontalList({super.key, required this.title, required this.type});

  @override
  Widget build(BuildContext context) {
    final shopsProvider = Provider.of<ShopsProvider>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: shopsProvider.shops.length,
            itemBuilder: (context, index) {
              final shop = shopsProvider.shops[index];
              return Container(
                width: 150,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                child: Card(
                  child: Column(
                    children: [
                      Image.network(
                        shop.imageUrl,
                        width: 150,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              shop.name,
                              style: const TextStyle(fontSize: 14),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Row(
                              children: [
                                const Icon(Icons.star, size: 16, color: Colors.amber),
                                Text('${shop.rating}'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}