import 'dart:io';
import 'package:flutter/material.dart';

import 'package:async/async.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:momday_app/backend_helpers/momday_cache.dart';
import 'package:momday_app/config.dart';
import 'package:observable/observable.dart';
import 'package:path/path.dart';
import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class MomdayHttp extends PropertyChangeNotifier {
  final String _baseUrl = EnvironmentConfig.of('url');
  final String _basicToken = '';
  String _bearerToken;
  String _language;
  String xsession;
  SharedPreferences _prefs;

  bool _isInitialized = false;

  static final MomdayHttp _momdayHttp = new MomdayHttp._internal();
  MomdayHttp._internal();
  factory MomdayHttp() {
    return MomdayHttp._momdayHttp;
  }

  get language => _language;

  Future<void> init() async {
    if (!this._isInitialized) {
      this._prefs = await SharedPreferences.getInstance();
      await this.getToken();
      await this.getSession();

      this._isInitialized = true;
      this.notifyPropertyChange(#_isInitialized, false, true);
    }
  }

  Future<void> reset() async {
    this._isInitialized = false;
    this._bearerToken = null;
    await this.init();
  }

  Future<void> getSession() async {
    String tempBearer = this._prefs.getString('xsession');

    if (tempBearer != null) {
      this.xsession = tempBearer;
    } else {
      dynamic bearerResponse = await this.get('feed/rest_api/session', null);
      if (bearerResponse['data'] != null) {
        this.xsession = bearerResponse['data']['session'];
        await this._prefs.setString('xsession', this.xsession);
        print("session is ${this.xsession}");
      }
    }
  }

  Future<void> getToken() async {
    String tempBearer = this._prefs.getString('bearer_token');

    if (tempBearer != null) {
      this._bearerToken = tempBearer;
    } else {
      dynamic bearerResponse = await this.post(
          'feed/rest_api/gettoken&grant_type=client_credentials', [], true);
      if (bearerResponse['data'] != null) {
        this._bearerToken = bearerResponse['data']['access_token'];
        await this._prefs.setString('bearer_token', this._bearerToken);
      }
    }
  }

  Future<void> refreshToken() async {
    dynamic bearerResponse = await this.post(
        'feed/rest_api/gettoken&grant_type=client_credentials',
        {'old_token': this._bearerToken},
        true);
    if (bearerResponse['data'] != null) {
      this._bearerToken = bearerResponse['data']['access_token'];
      await this._prefs.setString('bearer_token', this._bearerToken);
    }
  }

  Future<dynamic> post(String url, dynamic body,
      [bool useBasic = false]) async {
    Map<String, String> headers = {};
    print("headers is ${headers['Authorization']}");
    print("usebasic is ${useBasic}");
    print("bearer is ${this._bearerToken}");
    // headers['Authorization'] =
    //     useBasic ? 'Basic ${this._basicToken}' : 'Bearer ${this._bearerToken}';
    headers['Content-type'] = 'application/json';
    headers['Accept'] = 'application/json';
    headers['X-Oc-Merchant-Language'] = this._language;
    headers['X-Oc-Merchant-Id'] = 'OqwXfoqzhle0xfhcqhWVLDOGvhbfH51E';
    headers['X-Oc-Session'] = this.xsession;
    print(headers);
    print("posting to " + this._baseUrl + url);
    http.Response response = await http.post(Uri.parse(this._baseUrl + url),
        headers: headers, body: json.encode(body));

    dynamic answer;
    try {
      answer = json.decode(response.body);
    } catch (error) {
      answer = {
        'success': '0',
        'error': {'text': 'Failed to handle response', 'data': response.body}
      };
    }

    answer = await this
        ._handleTokenIssuesIfAny(answer, () => this.post(url, body, useBasic));

    print("answer is $answer");
    return answer;
  }

  Future<dynamic> uploadAttachment(String filePath, bool isVideo,
      [bool useBasic = false]) async {
    File file = File(filePath);
    http.ByteStream stream =
        new http.ByteStream(DelegatingStream.typed(file.openRead()));
    var length = await file.length();

    var uri = Uri.parse(this._baseUrl + "rest/momday/preloved/upload_file");

    Map<String, String> headers = {};
    headers['Authorization'] =
        useBasic ? 'Basic ${this._basicToken}' : 'Bearer ${this._bearerToken}';
    headers['Content-type'] = 'multipart/form-data';
    headers['X-Oc-Merchant-Language'] = this._language;
    headers['X-Oc-Merchant-Id'] = 'OqwXfoqzhle0xfhcqhWVLDOGvhbfH51E';
    headers['X-Oc-Session'] = this.xsession;

    http.MultipartRequest request = new http.MultipartRequest("POST", uri);

    request.headers.addAll(headers);

    var multipartFile = new http.MultipartFile('file', stream, length,
        filename: basename(file.path),
        contentType:
            isVideo ? MediaType('video', 'mp4') : MediaType('image', 'jpeg'));

    request.files.add(multipartFile);

    final responseBody = await request.send().then((streamedResponse) {
      return http.Response.fromStream(streamedResponse);
    }).then((response) {
      return response.body;
    });

    print("responseBody is $responseBody");

    return jsonDecode(responseBody);
  }

  Future<dynamic> put(String url, dynamic body, [bool useBasic = false]) async {
    Map<String, String> headers = {};
    headers['Authorization'] =
        useBasic ? 'Basic ${this._basicToken}' : 'Bearer ${this._bearerToken}';
    headers['Content-type'] = 'application/json';
    headers['X-Oc-Merchant-Language'] = this._language;
    headers['X-Oc-Merchant-Id'] = 'OqwXfoqzhle0xfhcqhWVLDOGvhbfH51E';
    headers['X-Oc-Session'] = this.xsession;

    http.Response response = await http.put(Uri.parse(this._baseUrl + url),
        headers: headers, body: json.encode(body));

    dynamic answer;
    try {
      answer = json.decode(response.body);
    } catch (error) {
      answer = {
        'success': '0',
        'error': {'text': 'Failed to handle response', 'data': response.body}
      };
    }

    answer = await this
        ._handleTokenIssuesIfAny(answer, () => this.put(url, body, useBasic));

    return answer;
  }

  Future<dynamic> get(String url, String XSession,
      {CacheLevel cacheLevel = CacheLevel.NONE, String imageDimensions}) async {
    print("reading from " + this._baseUrl + url);

    var cachedValue = await MomdayCache().get(url);
    if (cachedValue != null) {
      return json.decode(cachedValue);
    }

    Map<String, String> headers = {};
    headers['Authorization'] = 'Bearer ${this._bearerToken}';
    headers['X-Oc-Merchant-Language'] = this._language;
    headers['X-Oc-Merchant-Id'] = 'OqwXfoqzhle0xfhcqhWVLDOGvhbfH51E';
    if (XSession != null) headers['X-Oc-Session'] = this.xsession;

    if (imageDimensions != null) {
      headers['X-Oc-Image-Dimension'] = imageDimensions;
    }

    http.Response response = await http.get(
      Uri.parse(this._baseUrl + url),
      headers: headers,
    );

    dynamic answer;
    try {
      answer = json.decode(response.body);
      print("response from " + url + " is $answer");
    } catch (error) {
      answer = {
        'error': {
          'success': '0',
          'text': 'Failed to handle response',
          'data': response.body
        }
      };
    }

    answer = await this
        ._handleTokenIssuesIfAny(answer, () => this.get(url, XSession));

    MomdayCache().put(url, json.encode(answer), cacheLevel);

    return answer;
  }

  Future<dynamic> delete(String url) async {
    Map<String, String> headers = {};
    headers['Authorization'] = 'Bearer ${this._bearerToken}';
    headers['X-Oc-Merchant-Language'] = this._language;
    headers['X-Oc-Merchant-Id'] = 'OqwXfoqzhle0xfhcqhWVLDOGvhbfH51E';
    headers['X-Oc-Session'] = this.xsession;

    http.Response response = await http.delete(
      Uri.parse(this._baseUrl + url),
      headers: headers,
    );

    dynamic answer;
    try {
      answer = json.decode(response.body);
    } catch (error) {
      answer = {
        'error': {
          'success': '0',
          'text': 'Failed to handle response',
          'data': response.body
        }
      };
    }

    answer = await this._handleTokenIssuesIfAny(answer, () => this.delete(url));

    return answer;
  }

  Future<dynamic> _handleTokenIssuesIfAny(
      dynamic response, Function callback) async {
    if (response['success'] == 0 &&
        response['error'][0] == 'The access token provided has expired') {
      await this.refreshToken();
      response = await callback();
    } else if (response['success'] == 0 &&
        response['error'][0] == 'The access token provided is invalid') {
      await this._prefs.remove('bearer_token');
      await this.getToken();
      response = await callback();
    }

    return response;
  }

  Future<dynamic> requestToPayfort(dynamic body) async {
    Map<String, String> headers = {};
    headers['Content-type'] = 'application/json';

    print(
        "posting to https://sbpaymentservices.payfort.com/FortAPI/paymentApi");
    http.Response response = await http.post(
        Uri.parse("https://sbpaymentservices.payfort.com/FortAPI/paymentApi"),
        headers: headers,
        body: json.encode(body));

    dynamic answer;
    try {
      answer = json.decode(response.body);
    } catch (error) {}
    print("answer is $answer");
    return answer;
  }

  Future<dynamic> requestToAramex(dynamic body) async {
    Map<String, String> headers = {};
    headers['Content-type'] = 'application/json';

    print(
        "posting to https://ws.dev.aramex.net/ShippingAPI.V2/Shipping/Service_1_0.svc/json/CreateShipments");
    http.Response response = await http.post(
        Uri.parse(
            "https://ws.aramex.net/ShippingAPI.V2/Shipping/Service_1_0.svc/json/CreateShipments"),
        headers: headers,
        body: body);

    dynamic answer;
    try {
      answer = json.decode(response.body);
    } catch (error) {}
    print("answer is $answer");
    return answer;
  }

  get isInitialized async {
    if (this._isInitialized) {
      return this._isInitialized;
    } else {
      await this.changes.first;
      return this._isInitialized;
    }
  }

  set language(String language) {
    this._language = language;
  }
}
