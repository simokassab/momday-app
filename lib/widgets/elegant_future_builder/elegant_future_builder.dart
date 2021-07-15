import 'dart:async';

import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:momday_app/momday_localizations.dart';
import 'package:momday_app/widgets/centralized_progress/centralized_progress.dart';
import 'package:momday_app/widgets/momday_error/momday_error.dart';

typedef Widget ContentBuilder<T>(BuildContext context, T data);
class ElegantFutureBuilder extends StatelessWidget {

  final Future future;
  final double loadingHeight;
  final double errorHeight;
  final ContentBuilder contentBuilder;
  final VoidCallback onTryAgain;
  final bool isFullPage;
  final bool fullError;

  ElegantFutureBuilder({
    this.future,
    this.loadingHeight,
    this.errorHeight,
    this.contentBuilder,
    this.onTryAgain,
    this.fullError : true,
    this.isFullPage : false
  });

  @override
  Widget build(BuildContext context) {

    final screenHeight = MediaQuery.of(context).size.height * 0.8;

    final loadingHeight = this.isFullPage? screenHeight : this.loadingHeight;
    final errorHeight = this.isFullPage? screenHeight : this.errorHeight;

    return FutureBuilder(
      future: this.future,
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:

            final indicator = CentralizedProgressIndicator(
                height: loadingHeight
            );

            if (this.isFullPage) {
              return this._getFullScreenColumn(
                child: indicator,
                context: context
              );
            } else {
              return indicator;
            }

            break;
          default:
            if (snapshot.hasError) {
              final error = MomdayError(
                height: errorHeight,
                error: snapshot.error,
                full: this.fullError,
                onTryAgain: this.onTryAgain
              );

              if (this.isFullPage) {
                return this._getFullScreenColumn(
                  child: error,
                  context: context
                );
              } else {
                return error;
              }
            } else {
              return contentBuilder(context, snapshot.data);
            }
        }
      },
    );
  }

  Widget _getFullScreenColumn({Widget child, BuildContext context}) {
    return Column(
      children: <Widget>[
        SizedBox(height: 8.0),
        Row(
          children: <Widget>[
            InkWell(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Icon(
                  getLocalizedBackwardArrowIcon(context),
                  size: 24.0,
                ),
              ),
              onTap: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
        child
      ],
    );
  }
}

typedef Future FutureCallBack();
class ElegantMemoizedFutureBuilder extends StatefulWidget {

  final FutureCallBack futureCallBack;
  final double loadingHeight;
  final double errorHeight;
  final ContentBuilder contentBuilder;
  final bool isFullPage;
  final bool fullError;

  ElegantMemoizedFutureBuilder({
    this.futureCallBack,
    this.loadingHeight,
    this.errorHeight,
    this.contentBuilder,
    this.fullError : true,
    this.isFullPage : false,
    Key key
  }): super(key: key);

  @override
  ElegantMemoizedFutureBuilderState createState() => ElegantMemoizedFutureBuilderState();
}

class ElegantMemoizedFutureBuilderState extends State<ElegantMemoizedFutureBuilder> {

  AsyncMemoizer _memoizer;

  @override
  void initState() {
    super.initState();
    this._memoizer = AsyncMemoizer();
  }

  void reset() {
    setState(() {
      this._memoizer = AsyncMemoizer();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ElegantFutureBuilder(
      isFullPage: widget.isFullPage,
      fullError: widget.fullError,
      contentBuilder: widget.contentBuilder,
      future: this._memoizer.runOnce(widget.futureCallBack),
      loadingHeight: widget.loadingHeight,
      errorHeight: widget.errorHeight,
      onTryAgain: this.reset,
    );
  }
}

