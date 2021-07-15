
import 'dart:async';

import 'package:observable/observable.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum CacheLevel {HEAVY, MEDIUM, VOLATILE, NONE}

class MomdayCache extends PropertyChangeNotifier {

  static const Map _config = {
    'medium_ttl': 1000 * 60 * 60 * 2, //2 hours
    'heavy_ttl': 1000 * 60 * 60 * 24 * 7 //7 days
  };

  Map<String, String> _cache;
  SharedPreferences _prefs;
  bool _isInitialized = false;

  static final MomdayCache _momdayCache = new MomdayCache._internal();
  MomdayCache._internal() {
    SharedPreferences.getInstance().then((prefs) {
      this._prefs = prefs;
      this._cache = {};
      this._isInitialized = true;
      this.notifyPropertyChange(#_isInitialized, false, true);
    });
  }
  factory MomdayCache() {
    return MomdayCache._momdayCache;
  }

  Future<void> put(String url, String value, CacheLevel cacheLevel) async {

    await this.isInitialized;

    if (cacheLevel != CacheLevel.NONE) {
      this._cache[url] = value;

      if (cacheLevel == CacheLevel.MEDIUM || cacheLevel == CacheLevel.HEAVY) {
        this._prefs.setString('cache_' + url, value);

        int ttl = cacheLevel == CacheLevel.MEDIUM? MomdayCache._config['medium_ttl'] :
        MomdayCache._config['heavy_ttl'];
        int expiryTime = DateTime.now().millisecondsSinceEpoch + ttl;

        this._prefs.setInt('cache_' + url + '_expiry',  expiryTime);
      }
    }

  }

  Future<String> get(String url) async {

    await this.isInitialized;

    if (this._cache[url] != null) {
      return this._cache[url];
    }

    var value = this._prefs.getString('cache_' + url);
    var expiry = this._prefs.getInt('cache_' + url + '_expiry');

    if (value == null) {
      return null;
    }

    if (expiry < DateTime.now().millisecondsSinceEpoch) {
      this._prefs.remove('cache_' + url);
      this._prefs.remove('cache_' + url + '_expiry');
      return null;
    }

    this._cache[url] = value;
    return value;
  }

  Future<void> clearCache() async {
    await this.isInitialized;

    var keys = this._prefs.getKeys();

    var cacheKeys = keys.where((key) => key.startsWith('cache_'));

    await Future.wait(cacheKeys.map((key) => this._prefs.remove(key)));

    this._cache = {};
  }

  get isInitialized async {
    if (this._isInitialized) {
      return this._isInitialized;
    } else {
      await this.changes.first;
      return this._isInitialized;
    }
  }
}