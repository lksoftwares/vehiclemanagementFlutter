import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class NoDataScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('No Data')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CachedNetworkImage(
                imageUrl: 'https://media.giphy.com/media/3ohrypGmT9bFovUzmM/giphy.gif?cid=790b7611rzrqyeyim5kc5b7wpnhevfrgha4jv5q5soe8vyth&ep=v1_gifs_search&rid=giphy.gif&ct=g',
                errorWidget: (context, url, error) => Icon(Icons.error),
                width: 200,
                height: 200,
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


