import 'dart:async';

import 'package:flutter/material.dart';
import 'package:momday_app/momday_localizations.dart';
import 'package:momday_app/widgets/centralized_progress/centralized_progress.dart';
import 'package:momday_app/widgets/momday_error/momday_error.dart';

typedef Widget ContentBuilder<T>(BuildContext context, T data);
class ElegantStreamBuilder<T> extends StatelessWidget {

  final Stream<T> stream;
  final double loadingHeight;
  final double errorHeight;
  final ContentBuilder contentBuilder;
  final VoidCallback onTryAgain;
  final bool isFullPage;
  final bool fullError;

  ElegantStreamBuilder({
    this.stream,
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

    return StreamBuilder<T>(
      stream: this.stream,
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

              print(error);
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