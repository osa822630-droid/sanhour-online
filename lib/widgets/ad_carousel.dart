import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class AdCarousel extends StatelessWidget {
  const AdCarousel({super.key});

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      options: CarouselOptions(
        height: 200.0,
        autoPlay: true,
        enlargeCenterPage: true,
      ),
      items: [1, 2, 3].map((i) {
        return Container(
          margin: const EdgeInsets.all(5.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
            color: Colors.amber,
          ),
          child: Center(
            child: Text(
              'إعلان $i',
              style: const TextStyle(fontSize: 16.0),
            ),
          ),
        );
      }).toList(),
    );
  }
}
