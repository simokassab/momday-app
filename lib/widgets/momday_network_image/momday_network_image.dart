import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:momday_app/styles/momday_colors.dart';

class MomdayNetworkImage extends StatelessWidget {

  final String imageUrl;
  final double height;
  final double width;
  final Color color;
  final BlendMode colorBlendMode;

  MomdayNetworkImage({this.imageUrl, this.height, this.width, this.color, this.colorBlendMode});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: MomdayColors.MomdayGray,
        image: DecorationImage(
          image: AssetImage('assets/images/logo_full_blurred.png'),
          fit: BoxFit.fitWidth,
        )
      ),
      child: Image(
        height: this.height,
        width: this.width,
        image: CachedNetworkImageProvider(this.imageUrl),
        fit: BoxFit.fill,
        color: this.color,
        colorBlendMode: this.colorBlendMode,
      ),
    );
  }
}
