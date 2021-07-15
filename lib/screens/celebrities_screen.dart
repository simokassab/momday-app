import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:momday_app/backend_helpers/momday_backend.dart';
import 'package:momday_app/models/models.dart';
import 'package:momday_app/momday_localizations.dart';
import 'package:momday_app/momday_utils.dart';
import '../styles/momday_colors.dart';
import 'package:momday_app/screens/main_screen.dart';
import 'package:momday_app/widgets/elegant_future_builder/elegant_future_builder.dart';
import 'package:momday_app/widgets/featured/featured.dart';
import 'package:momday_app/widgets/momday_network_image/momday_network_image.dart';
import 'package:momday_app/widgets/page_header/page_header.dart';

class CelebritiesScreen extends StatefulWidget {
  @override
  _CelebritiesScreenState createState() => _CelebritiesScreenState();
}

class _CelebritiesScreenState extends State<CelebritiesScreen> {
  _CharGroup selectedCharGroup;
  String searchTerm;

  @override
  void initState() {
    super.initState();
    selectedCharGroup = _CharGroup(first: null, last: null);
    this.searchTerm = '';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).padding,
      child: Column(
        children: <Widget>[
          MainScreen.of(context).getMomdayBar(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 8.0, left: 8.0),
              child: ListView(
                children: <Widget>[
                  PageHeader(
                    title: tTitle(context, 'celebrities'),
                  ),
                  SizedBox(
                    height: 8.0,
                  ),
                  TextField(
                    decoration:
                        getMomdayInputDecoration(tTitle(context, 'search')),
                    onChanged: (value) {
                      setState(() {
                        this.searchTerm = value;
                      });
                    },
                  ),
                  _CharactersHeader(
                    language: Localizations.localeOf(context).languageCode,
                    selectedCharGroup: this.selectedCharGroup,
                    onCharacterGroupTap: (charGroup) {
                      setState(() {
                        this.selectedCharGroup = charGroup;
                      });
                    },
                  ),
                  Container(
                    height: 300,
                    child: ElegantMemoizedFutureBuilder(
                      futureCallBack: MomdayBackend().getCelebrities,
                      contentBuilder: (context, data) {
                        var celebrities =
                            CelebrityModel.fromDynamicList(data['data']);
                        var filteredCelebrities;
                        if (this.searchTerm.isNotEmpty) {
                          filteredCelebrities =
                              this._filterCelebritiesBySearchTerm(celebrities);
                        } else {
                          filteredCelebrities =
                              this._filterCelebritiesByCharGroup(celebrities);
                        }

                        return _CelebritiesGrid(
                          celebrities: filteredCelebrities,
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 10.0),
                  Row(
                    children: [
                      Icon(
                        Icons.clear_rounded,
                        color: MomdayColors.MomdayGold,
                      ),
                      Text(
                        tTitle(context, 'featured_items'),
                        // textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 25, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  Featured(
                    hasOverlay: true,
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  List<CelebrityModel> _filterCelebritiesByCharGroup(
      List<CelebrityModel> celebrities) {
    return celebrities.where((celebrity) {
      if (this.selectedCharGroup.first == null) {
        return true;
      }

      return celebrity.firstName[0].compareTo(this.selectedCharGroup.first) >=
              0 &&
          celebrity.firstName[0].compareTo(this.selectedCharGroup.last) <= 0;
    }).toList();
  }

  List<CelebrityModel> _filterCelebritiesBySearchTerm(
      List<CelebrityModel> celebrities) {
    return celebrities
        .where((celebrity) => celebrity.fullName
            .toLowerCase()
            .contains(this.searchTerm.toLowerCase()))
        .toList();
  }
}

class _CelebritiesGrid extends StatelessWidget {
  final List<CelebrityModel> celebrities;

  _CelebritiesGrid({this.celebrities});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      padding: EdgeInsets.zero,
      mainAxisSpacing: 8.0,
      children: this
          .celebrities
          .map((celebrity) => InkWell(
                child: Column(
                  children: <Widget>[
                    Expanded(
                      child: AspectRatio(
                          aspectRatio: 1.0,
                          child: celebrity.squareImage != null
                              ? MomdayNetworkImage(
                                  imageUrl: celebrity.squareImage,
                                )
                              : AssetImage("assets/images/no_celebrity.png")),
                    ),
                    SizedBox(height: 8.0),
                    celebrity.fullName != null
                        ? Text(celebrity.fullName.toUpperCase(),
                            style: cancelArabicFontDelta(context).copyWith(
                              fontWeight: FontWeight.w800,
                            ))
                        : Container()
                  ],
                ),
                onTap: () {
                  Navigator.of(context)
                      .pushNamed('/celebrity/${celebrity.celebrityId}');
                },
              ))
          .toList(),
    );
  }
}

class _CharGroup {
  final String first;
  final String last;
  final String display;

  _CharGroup({this.first, this.last, this.display});

  @override
  bool operator ==(other) {
    return this.first == other.first && this.last == other.last;
  }

  // simple implementation for the hashcode, not the best one but that's ok for
  // the given usecase
  int get hashCode => this.first.hashCode + this.last.hashCode;
}

typedef _CharacterGroupTapCallBack(_CharGroup groupStart);

class _CharactersHeader extends StatelessWidget {
  final String language;
  final _CharGroup selectedCharGroup;
  final _CharacterGroupTapCallBack onCharacterGroupTap;

  _CharactersHeader(
      {this.language, this.selectedCharGroup, this.onCharacterGroupTap});

  @override
  Widget build(BuildContext context) {
    List<_CharGroup> charGroups = this.language == 'en'
        ? [
            _CharGroup(first: 'A', last: 'D', display: 'ABCD'),
            _CharGroup(first: 'E', last: 'H', display: 'EFGH'),
            _CharGroup(first: 'I', last: 'L', display: 'IJKL'),
            _CharGroup(first: 'M', last: 'O', display: 'MNO'),
            _CharGroup(first: 'P', last: 'R', display: 'PQR'),
            _CharGroup(first: 'S', last: 'U', display: 'STU'),
            _CharGroup(first: 'V', last: 'Z', display: 'V-Z'),
          ]
        : [
            _CharGroup(first: 'ا', last: 'ث', display: 'ا-ث'),
            _CharGroup(first: 'ج', last: 'خ', display: 'ج-خ'),
            _CharGroup(first: 'د', last: 'ز', display: 'د-ز'),
            _CharGroup(first: 'س', last: 'ص', display: 'س-ص'),
            _CharGroup(first: 'ط', last: 'غ', display: 'ط-غ'),
            _CharGroup(first: 'ف', last: 'ل', display: 'ف-ل'),
            _CharGroup(first: 'م', last: 'ي', display: 'م-ي'),
          ];

    charGroups.insert(0,
        _CharGroup(first: null, last: null, display: tTitle(context, 'all')));

    var inactiveWeight =
        this.language == 'ar' ? FontWeight.w300 : FontWeight.w600;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: charGroups
            .expand((charGroup) => [
                  InkWell(
                    child: Text(
                      charGroup.display,
                      style: cancelArabicFontDelta(context).copyWith(
                          fontWeight: this.selectedCharGroup == charGroup
                              ? FontWeight.w800
                              : inactiveWeight),
                    ),
                    onTap: () {
                      this.onCharacterGroupTap(charGroup);
                    },
                  ),
                  charGroup != charGroups.last
                      ? Container(
                          width: 0.5,
                          height: 16.0,
                          color: Colors.black.withOpacity(0.5),
                        )
                      : Container()
                ])
            .toList(),
      ),
    );
  }
}
