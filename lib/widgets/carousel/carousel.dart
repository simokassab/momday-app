import 'package:flutter/material.dart';
import 'package:momday_app/momday_localizations.dart';
import 'dart:async';
import 'package:momday_app/styles/momday_colors.dart';
import 'package:momday_app/widgets/momday_network_image/momday_network_image.dart';

enum IndicatorPosition { Below, Inside }
typedef void CarouselItemTapCallback(int index);

class Carousel extends StatefulWidget {
  //All the images on this Carousel.
  final List images;
  final String video;
  //The transition animation timing curve. Default is [Curves.ease]
  final Curve animationCurve;

  //The transition animation duration. Default is 300ms.
  final Duration animationDuration;

  // The base size of the dots. Default is 8.0
  final double dotSize;

  // The color of the selected dot. Default is #C79544
  final Color dotSelectedColor;

  // The distance between the center of each dot. Default is 25.0
  final double dotSpacing;

  // The Color of each dot. Default is Colors.white
  final Color dotColor;

  // The background Color of the dots. Default is [Colors.grey[800].withOpacity(0.5)]
  final Color dotBgColor;

  // Enable or Disable the indicator (dots). Default is true
  final bool showIndicator;

  //Padding Size of the background Indicator. Default is 20.0
  final double indicatorBgPadding;

  //How to show the images in the box. Default is cover
  final BoxFit boxFit;

  //Enable/Disable radius Border for the images. Default is false
  final bool borderRadius;

  //Border Radius of the images. Default is [Radius.circular(8.0)]
  final Radius radius;

  //Move the Indicator From the Bottom
  final double moveIndicatorFromBottom;

  //Remove the radius bottom from the indicator background. Default false
  final bool noRadiusForIndicator;

  //Enable/Disable Image Overlay Shadow. Default false
  final bool overlayShadow;

  //Choose the color of the overlay Shadow color. Default Colors.grey[800]
  final Color overlayShadowColors;

  //Choose the size of the Overlay Shadow, from 0.0 to 1.0. Default 0.5
  final double overlayShadowSize;

  //Enable/Disable the auto play of the slider. Default true
  final bool autoplay;

  //Duration of the Auto play slider by seconds. Default 3 seconds
  final Duration autoplayDuration;

  final double imageHeight;

  final double aspectRatio;

  final String subtext;

  final CarouselItemTapCallback onItemTap;

  final Widget midAnnouncement;

  final IndicatorPosition indicatorPosition;

  Carousel(
      {this.images,
      this.video,
      this.animationCurve = Curves.ease,
      this.animationDuration = const Duration(milliseconds: 300),
      this.dotSize = 8.0,
      this.dotSpacing = 25.0,
      this.dotSelectedColor = const Color.fromRGBO(199, 149, 68, 1.0),
      this.dotColor = MomdayColors.MomdayGray,
      this.dotBgColor,
      this.showIndicator = true,
      this.indicatorBgPadding = 20.0,
      this.boxFit = BoxFit.cover,
      this.borderRadius = false,
      this.radius,
      this.imageHeight,
      this.moveIndicatorFromBottom = 0.0,
      this.noRadiusForIndicator = false,
      this.overlayShadow = false,
      this.overlayShadowColors,
      this.overlayShadowSize = 0.5,
      this.subtext,
      this.autoplay = true,
      this.autoplayDuration = const Duration(seconds: 3),
      this.onItemTap,
      this.aspectRatio,
      this.midAnnouncement,
      this.indicatorPosition = IndicatorPosition.Below})
      : assert(images != null),
        assert(animationCurve != null),
        assert(animationDuration != null),
        assert(dotSize != null),
        assert(dotSpacing != null),
        assert(dotSelectedColor != null),
        assert(dotColor != null);

  @override
  State createState() => new CarouselState();
}

class CarouselState extends State<Carousel> {
  final _controller = new PageController();

  Timer timer;

  @override
  void initState() {
    super.initState();

    if (widget.autoplay) {
      this.timer = new Timer.periodic(widget.autoplayDuration, (_) {
        if ((_controller.page - (widget.images.length - 1)).abs() < 0.1) {
          _controller.animateToPage(
            0,
            duration: widget.animationDuration,
            curve: widget.animationCurve,
          );
        } else {
          _controller.nextPage(
              duration: widget.animationDuration, curve: widget.animationCurve);
        }
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    this.timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> listImages = [];

    for (int i = 0; i < widget.images.length; i++) {
      listImages.add(InkWell(
        onTap: () {
          widget.onItemTap(i);
        },
        child: new Container(
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius
                ? new BorderRadius.all(widget.radius != null
                    ? widget.radius
                    : new Radius.circular(8.0))
                : null,
          ),
          foregroundDecoration: widget.overlayShadow
              ? BoxDecoration(color: Colors.white.withOpacity(0.5))
              : null,
          child: widget.video != null &&
                  widget.images[i].toString() == widget.video
              ? Center(
                  child: SizedBox(
                      child: FlatButton(
                  onPressed: () {},
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        tTitle(context, 'preview_video'),
                        style: TextStyle(fontSize: 12),
                      ),
                      Icon(Icons.play_circle_filled),
                    ],
                  ),
                )))
              : MomdayNetworkImage(
                  imageUrl: widget.images[i] != null ? widget.images[i] : '',
                ),
        ),
      ));
    }

    final pageView = PageView(
      physics: new AlwaysScrollableScrollPhysics(),
      controller: _controller,
      children: listImages,
    );

    final imageSlider = Stack(
      children: <Widget>[
        Center(
          child: Container(
              height: widget.imageHeight,
              child: widget.aspectRatio != null
                  ? AspectRatio(
                      aspectRatio: widget.aspectRatio, child: pageView)
                  : pageView),
        ),
        widget.midAnnouncement != null
            ? Positioned(
                left: 0.0,
                top: 0.0,
                right: 0.0,
                bottom: 0.0,
                child: Center(
                  child: widget.midAnnouncement,
                ),
              )
            : Container(),
        widget.subtext != null
            ? Positioned(
                bottom: 0.0,
                right: 0.0,
                width: 130.0,
                child: Container(
                  child: FlatButton(
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    color: Colors.black,
                    child: Text(widget.subtext,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.button),
                    onPressed: () {
                      widget.onItemTap(this._controller.page.round());
                    },
                  ),
                ),
              )
            : Container()
      ],
    );

    final indicatorWidget = widget.showIndicator
        ? new Container(
            child: new Container(
              decoration: new BoxDecoration(
                borderRadius: widget.borderRadius
                    ? (widget.noRadiusForIndicator
                        ? null
                        : new BorderRadius.only(
                            bottomLeft: widget.radius != null
                                ? widget.radius
                                : new Radius.circular(8.0),
                            bottomRight: widget.radius != null
                                ? widget.radius
                                : new Radius.circular(8.0)))
                    : null,
              ),
              padding: new EdgeInsets.all(widget.indicatorBgPadding),
              child: new Center(
                child: new DotsIndicator(
                  controller: _controller,
                  itemCount: listImages.length,
                  color: widget.dotColor,
                  dotSize: widget.dotSize,
                  dotSpacing: widget.dotSpacing,
                  dotSelectedColor: widget.dotSelectedColor,
                  onPageSelected: (int page) {
                    _controller.animateToPage(
                      page,
                      duration: widget.animationDuration,
                      curve: widget.animationCurve,
                    );
                  },
                ),
              ),
            ),
          )
        : new Container();

    if (widget.indicatorPosition == IndicatorPosition.Below) {
      return new Column(
        children: <Widget>[imageSlider, indicatorWidget],
      );
    } else {
      return Stack(
        children: <Widget>[
          imageSlider,
          Positioned(
            left: 0.0,
            right: 0.0,
            bottom: 0.0,
            child: indicatorWidget,
          )
        ],
      );
    }
  }
}

/// An indicator showing the currently selected page of a PageController
class DotsIndicator extends AnimatedWidget {
  DotsIndicator(
      {this.controller,
      this.itemCount,
      this.onPageSelected,
      this.color,
      this.dotSize,
      this.dotSelectedColor,
      this.dotSpacing})
      : super(listenable: controller);

  // The PageController that this DotsIndicator is representing.
  final PageController controller;

  // The number of items managed by the PageController
  final int itemCount;

  // Called when a dot is tapped
  final ValueChanged<int> onPageSelected;

  // The color of the dots.
  final Color color;

  // The base size of the dots
  final double dotSize;

  // The color of the selected dot
  final Color dotSelectedColor;

  // The distance between the center of each dot
  final double dotSpacing;

  Widget _buildDot(int index) {
    return new Container(
      width: dotSpacing,
      child: new Center(
        child: new Material(
          color:
              (index - (controller.page ?? controller.initialPage)).abs() < 0.1
                  ? dotSelectedColor
                  : color,
          type: MaterialType.circle,
          child: new Container(
            width: dotSize,
            child: new InkWell(
              onTap: () => onPageSelected(index),
            ),
            height: dotSize,
          ),
        ),
      ),
    );
  }

  Widget build(BuildContext context) {
    return new Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: new List<Widget>.generate(itemCount, _buildDot),
    );
  }
}
