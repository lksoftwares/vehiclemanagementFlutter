import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class NoDataScreen extends StatelessWidget {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('No Data Example')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CachedNetworkImage(
                imageUrl: 'https://media.giphy.com/media/3o6Zt5pPH7hT1VJpK4/giphy.gif',
                errorWidget: (context, url, error) => Icon(Icons.error),
                width: 150,
                height: 150,
              ),
              SizedBox(height: 20),
              Text(
                'No Data Found!',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        )

    );
  }
}


