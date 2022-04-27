import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';

class ImagePreviewScreen extends GetView {
  @override
  Widget build(BuildContext context) {
    var image = Get.arguments['image'];
    return Scaffold(
      backgroundColor: Colors.blueGrey.shade900,
      body: SafeArea(
        child: Stack(
          children: [
            Hero(
              tag: image,
              child: CachedNetworkImage(
                  imageUrl: image,
                  height: Get.height,
                  width: Get.width,
                  placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      )),
                  errorWidget: (context, url, errro) =>
                  const Center(
                    child: Icon(
                      Icons.broken_image_outlined,
                      color: Colors.white,
                    ),
                  )
              ),
            ),
            Positioned(
              right: 10,
              top: 10,
              child: SizedBox(
                height: 32,
                width: 32,
                child: ClipOval(
                  child: Material(
                    color: Colors.blueGrey.shade900,
                    child: InkWell(
                      onTap: (){
                        Get.back();
                      },
                      splashColor: Colors.blueGrey.shade500,
                      child: const Icon(
                        Icons.cancel,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
