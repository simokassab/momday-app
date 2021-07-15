import 'package:flutter/material.dart';
import 'package:momday_app/models/models.dart';
import 'package:momday_app/momday_localizations.dart';

class ProductContactInfo extends StatefulWidget {

  MyListProductModel selectedProduct;

  ProductContactInfo({this.selectedProduct});

  @override
  ProductContactInfoState createState() {
    return new ProductContactInfoState();
  }
}

class ProductContactInfoState extends State<ProductContactInfo> {

  TextEditingController emailController;
  TextEditingController phoneController;
  TextEditingController locationController;

  String phoneNumber;
  String email;
  String location;

  @override
  void initState() {

    emailController = TextEditingController(text: email);
    phoneController = TextEditingController(text: phoneNumber);
    locationController = TextEditingController(text: location);

    if(this.widget.selectedProduct != null){

      if(this.location == "")
        this.location = this.widget.selectedProduct.pickupLocation;
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: ListView(
          children: <Widget>[
            Text(
                tTitle(context, "contact_info"),
                style: new TextStyle(
                    fontSize: 30.0,
                    color: Colors.black
                )
            ),
            Container(
              margin: EdgeInsets.only(top: 10),
              child: Text(
                  tSentence(context, "contact_info_details"),
                  style: new TextStyle(
                      fontSize: 17.0,
                      color: Colors.black)
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 10),
              child: Text(
                  tSentence(context, "contact_info_disclaimer"),
                  style: new TextStyle(
                      fontSize: 17.0,
                      color: Colors.black)
              ),
            ),
            Container(
              margin: EdgeInsetsDirectional.only(top: 10),
              child: TextField(
                decoration: new InputDecoration(
                    border: new OutlineInputBorder(
                        borderSide: new BorderSide(color: Colors.teal)
                    ),
                    hintText: tTitle(context, "email"),
                    suffixIcon: const Icon(
                      Icons.person,
                      color: Colors.grey,
                    ),
                    suffixStyle: const TextStyle(color: Colors.black)),
                controller: emailController,
              ),
            ),
            Container(
              margin: EdgeInsetsDirectional.only(top: 10),
              child: TextField(
                decoration: new InputDecoration(
                    border: new OutlineInputBorder(
                        borderSide: new BorderSide(color: Colors.teal)
                    ),
                    hintText: tTitle(context, "phone"),
                    suffixIcon: const Icon(
                      Icons.phone,
                      color: Colors.grey,
                    ),
                    suffixStyle: const TextStyle(color: Colors.black)
                ),
                keyboardType: TextInputType.number,
                controller: phoneController,
              ),
            ),
            Container(
              margin: EdgeInsetsDirectional.only(top: 10),
              child: TextField(
                decoration: new InputDecoration(
                    border: new OutlineInputBorder(
                        borderSide: new BorderSide(color: Colors.teal)
                    ),
                    hintText: tTitle(context, "pickup"),
                    suffixIcon: const Icon(
                      Icons.location_on,
                      color: Colors.grey,
                    ),
                    suffixStyle: const TextStyle(color: Colors.black)
                ),
                controller: locationController,
              ),
            ),
          ]
      ),
    );
  }
}