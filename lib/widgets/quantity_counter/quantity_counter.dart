import 'package:flutter/material.dart';
import 'package:momday_app/styles/momday_colors.dart';

typedef ChangeQuantityCallBack(int newQuantity);

class QuantityCounter extends StatefulWidget {
  final int quantity;
  final int min;
  final int max;
  final ChangeQuantityCallBack changeQuantityCallback;

  QuantityCounter(
      {this.min = 1, this.max, this.quantity, this.changeQuantityCallback});

  @override
  QuantityCounterState createState() {
    return new QuantityCounterState();
  }
}

class QuantityCounterState extends State<QuantityCounter> {
  bool _isIncreasing;
  bool _isDecreasing;

  @override
  void initState() {
    super.initState();
    this._isIncreasing = false;
    this._isDecreasing = false;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      foregroundDecoration: BoxDecoration(border: Border.all(width: 0.1)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            foregroundDecoration: BoxDecoration(
                border: BorderDirectional(end: BorderSide(width: 0.1))),
            child: InkWell(
              child: Icon(
                Icons.remove,
                size: 20.0,
                color: this._isDecreasing ? Colors.grey : null,
              ),
              onTap: this._decrease,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              this.widget.quantity.toString(),
              style: TextStyle(color: MomdayColors.MomdayGold),
            ),
          ),
          Container(
            foregroundDecoration: BoxDecoration(
                border: BorderDirectional(start: BorderSide(width: 0.1))),
            child: InkWell(
                child: Icon(
                  Icons.add,
                  size: 20.0,
                  color: this._isIncreasing ? Colors.grey : null,
                ),
                onTap: this._increase),
          )
        ],
      ),
    );
  }

  _decrease() async {
    if (!this._isDecreasing) {
      if (this.widget.min == null || this.widget.quantity > this.widget.min) {
        setState(() {
          this._isDecreasing = true;
        });

        await this.widget.changeQuantityCallback(this.widget.quantity - 1);

        setState(() {
          this._isDecreasing = false;
        });
      }
    }
  }

  _increase() async {
    if (!this._isIncreasing) {
      if (this.widget.max == null || this.widget.quantity < this.widget.max) {
        setState(() {
          this._isIncreasing = true;
        });
        await this.widget.changeQuantityCallback(this.widget.quantity + 1);
        setState(() {
          this._isIncreasing = false;
        });
      }
    }
  }
}
