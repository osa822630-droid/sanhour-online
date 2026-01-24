import 'package:flutter/material.dart';
import '../widgets/search_bar.dart';
import '../widgets/horizontal_list.dart';

class OffersScreen extends StatelessWidget {
  const OffersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('العروض')),
      body: Column(
        children: [
          const SearchBarWidget(),
          Expanded(
            child: ListView(
              children: const [
                HorizontalList(title: 'عروض مميزة', type: 'featured_offers'),
                HorizontalList(
                    title: 'عروض تنتهي قريباً', type: 'ending_offers'),
                HorizontalList(title: 'عروض كل المحلات', type: 'all_offers'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
