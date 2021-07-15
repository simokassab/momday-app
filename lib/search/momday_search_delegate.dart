import 'package:flutter/material.dart';
import 'package:momday_app/search/search_helpers.dart';

class MomdaySearchDelegate extends SearchDelegate<SearchCriteria> {

  List<String> suggestions;

  Widget buildSuggestions(BuildContext context) {

    if (query.trim().length == 0) {
      return ListView(
        children: SearchHelper().searchHistory.map((entry) {
          return ListTile(
            leading: const Icon(Icons.history),
            title: Text(entry),
            onTap: () {
              this._chooseSuggestion(context, entry);
            },
          );
        }).toList(),
      );
    }

    this.suggestions = SearchHelper().getSuggestions(query);

    return ListView(
      children: this.suggestions.map((suggestion) {
        return ListTile(
          leading: const Icon(null),
          title: Text(suggestion),
          onTap: () {
            this._chooseSuggestion(context, suggestion);
          },
        );
      }).toList()
    );
  }

  Widget buildResults(BuildContext context) {
    return Container();
  }

  Widget buildLeading(BuildContext context) {
    return new IconButton(
      icon: new AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
      onPressed: () {
        close(context, null);
      },
    );
  }

  List<Widget> buildActions(BuildContext context) {
    return this.query.isNotEmpty? [
      new IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
          showSuggestions(context);
        },
      )
    ] : [];
  }

  @override
  void showResults(BuildContext context) {

    if (this.suggestions.length == 0) return;

    this._chooseSuggestion(context, this.suggestions[0]);

  }

  _chooseSuggestion(BuildContext context, String suggestion) {
    var criteria = SearchHelper().getSearchCriteriaFromOption(suggestion);
    SearchHelper().storeSuggestionInHistory(suggestion);
    this.close(context, criteria);
  }
}