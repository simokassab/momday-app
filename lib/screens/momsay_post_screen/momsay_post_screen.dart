import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:momday_app/app_state_manager.dart';
import 'package:momday_app/bloc_provider.dart';
import 'package:momday_app/models/models.dart';
import 'package:momday_app/momday_localizations.dart';
import 'package:momday_app/momday_utils.dart';
import 'package:momday_app/screens/main_screen.dart';
import 'package:momday_app/screens/momsay_post_screen/momsay_author_bio.dart';
import 'package:momday_app/screens/momsay_post_screen/momsay_post_bloc.dart';
import 'package:momday_app/styles/momday_colors.dart';
import 'package:momday_app/widgets/elegant_stream_builder/elegant_stream_builder.dart';
import 'package:momday_app/widgets/momday_card/momday_card.dart';
import 'package:momday_app/widgets/page_header/page_header.dart';
import 'package:flutter_html/flutter_html.dart';

class MomsayPostScreen extends StatefulWidget {
  final String postId;

  MomsayPostScreen({this.postId});

  @override
  MomsayPostScreenState createState() {
    return new MomsayPostScreenState();
  }
}

class MomsayPostScreenState extends State<MomsayPostScreen> {
  MomsayPostBloc bloc;

  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    this.bloc = MomsayPostBloc(postId: this.widget.postId);

    this.bloc.init();

    this.bloc.actionStream.forEach((action) {
      if (action.type == MomsayPostActionTypes.AddComment &&
          action.data['parentCommentId'] == null) {
        this._scrollController.animateTo(
            this._scrollController.position.maxScrollExtent,
            duration: Duration(milliseconds: 500),
            curve: Curves.linear);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: this._scrollController,
      children: <Widget>[
        MainScreen.of(context).getMomdayBar(),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[
              PageHeader(
                title: tUpper(context, 'momsay'),
              ),
              SizedBox(height: 24.0),
              BlocProvider(bloc: this.bloc, child: _MomsayPost())
            ],
          ),
        ),
      ],
    );
  }
}

class _MomsayPost extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElegantStreamBuilder<MomsayPostModel>(
      loadingHeight: MediaQuery.of(context).size.height * 0.8,
      stream: BlocProvider.of<MomsayPostBloc>(context).dataStream,
      contentBuilder: (context, post) {
        return Column(
          children: <Widget>[
            MomdayCard(
                child: Column(children: [
              ListTile(
                leading: CircleAvatar(
                  backgroundImage:
//                      post.author.image == null ?
                      AssetImage("assets/images/no_image_author.png"),
//            : CachedNetworkImageProvider(post.author.image),
                  backgroundColor: MomdayColors.MomdayGray,
                ),
                title: post.author.name != null
                    ? Text(
                        post.author.name.toUpperCase(),
                        style: cancelArabicFontDelta(context).copyWith(
                            color: MomdayColors.MomdayGold,
                            fontWeight: FontWeight.bold),
                      )
                    : Container(),
                subtitle: InkWell(
                  onTap: () => this._showAuthorBio(context, post.author),
                  child: Text(
                    tLower(context, 'view_author_bio'),
                    style: cancelArabicFontDelta(context).copyWith(
                        fontStyle: FontStyle.italic,
                        color: MomdayColors.LocationGray),
                  ),
                ),
                trailing: Text(
                  convertDateToUserFriendly(
                      post.date, Localizations.localeOf(context).languageCode),
                  textAlign: TextAlign.end,
                  style: cancelArabicFontDelta(context).copyWith(
                    color: MomdayColors.NoteGray,
                  ),
                ),
              ),
              Divider(),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      post.name,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 20.0, fontWeight: FontWeight.w600),
                    ),
                    SizedBox(
                      height: 8.0,
                    ),
                    DefaultTextStyle(
                      style: cancelArabicFontDelta(context),
                      child: Html(
                        data: post.description,
                        onLinkTap: (link) {
                          Navigator.of(context, rootNavigator: true)
                              .push(MaterialPageRoute(
                                  builder: (_) => WebviewScaffold(
                                        url: link,
                                        appBar: AppBar(
                                          backgroundColor: Colors.white,
                                          iconTheme: IconThemeData(
                                              color: MomdayColors.MomdayGold),
                                        ),
                                      )));
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ])),
            _CommentsAndLikes(),
          ],
        );
      },
    );
  }

  _showAuthorBio(BuildContext context, MomsayAuthorModel author) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => MomsayAuthorBio(
              author: author,
            )));
  }
}

class _CommentsAndLikes extends StatelessWidget {
  _CommentsAndLikes();

  @override
  Widget build(BuildContext context) {
    return LimitedBox(
      maxHeight: 500.0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _InteractWithPost(),
          SizedBox(
            height: 16.0,
          ),
          Expanded(child: _Comments())
        ],
      ),
    );
  }
}

class _Comments extends StatefulWidget {
  @override
  __CommentsState createState() => __CommentsState();
}

class __CommentsState extends State<_Comments> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final bloc = BlocProvider.of<MomsayPostBloc>(context);
    bloc.actionStream.forEach((action) {
      if (action.type == MomsayPostActionTypes.AddComment &&
          action.data['parentCommentId'] == null) {
        Timer(Duration(milliseconds: 500), () {
          this._scrollController.animateTo(
              this._scrollController.position.maxScrollExtent,
              duration: Duration(milliseconds: 500),
              curve: Curves.easeOut);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bloc = BlocProvider.of<MomsayPostBloc>(context);
    final comments = bloc.postData.comments;

    final commentsWidgets = comments
        .map((comment) => _Comment(
              comment: comment,
              repliable: true,
            ))
        .toList();

    return Scrollbar(
      child: ListView(
          controller: this._scrollController,
          shrinkWrap: true,
          children: commentsWidgets),
    );
  }
}

class _Comment extends StatefulWidget {
  final CommentModel comment;
  final bool repliable; // can users reply to this comment

  _Comment({this.comment, this.repliable});

  @override
  _CommentState createState() {
    return new _CommentState();
  }
}

class _CommentState extends State<_Comment> {
  bool _areRepliesShown;

  final _writeCommentKey = GlobalKey<__WriteCommentState>();

  @override
  void initState() {
    super.initState();
    this._areRepliesShown = false;
  }

  @override
  Widget build(BuildContext context) {
    final commentBody = Container(
        padding: const EdgeInsets.all(8.0),
        color: MomdayColors.CommentBackgroundColor,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              this.widget.comment.author,
              style: cancelArabicFontDelta(context).copyWith(
                  color: MomdayColors.LocationGray,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(
              width: 8.0,
            ),
            Expanded(
              child: Text(
                this.widget.comment.text,
                style: cancelArabicFontDelta(context)
                    .copyWith(color: MomdayColors.LocationGray),
              ),
            )
          ],
        ));

    final commentOptions = Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          width: 8.0,
        ),
        InkWell(
          onTap: () => this._viewReplies(true),
          child: Text(
            tSentence(context, 'reply'),
            style: cancelArabicFontDelta(context).copyWith(
                fontWeight: FontWeight.w600, color: MomdayColors.LocationGray),
          ),
        ),
        SizedBox(
          width: 16.0,
        ),
        this.widget.comment.replies.length > 0 && !this._areRepliesShown
            ? InkWell(
                onTap: this._viewReplies,
                child: Text(
                  tLower(context, 'view_replies') +
                      ' ( ${this.widget.comment.replies.length} )',
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: MomdayColors.LocationGray),
                ),
              )
            : Container(),
        this.widget.comment.replies.length > 0 && this._areRepliesShown
            ? InkWell(
                onTap: this._hideReplies,
                child: Text(
                  tLower(context, 'hide_replies'),
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: MomdayColors.LocationGray),
                ),
              )
            : Container(),
      ],
    );

    final commentReplies = Padding(
      padding: const EdgeInsetsDirectional.only(start: 32.0, top: 2.0),
      child: Column(
        children: widget.comment.replies
            .map<Widget>((reply) => _Comment(
                  comment: reply,
                  repliable: false,
                ))
            .toList()
              ..add(Padding(
                padding: const EdgeInsetsDirectional.only(start: 4.0),
                child: _WriteComment(
                  key: this._writeCommentKey,
                  parentCommentId: widget.comment.id,
                ),
              )),
      ),
    );

    return Padding(
        padding: const EdgeInsets.all(4.0),
        child: Column(
            children: <Widget>[commentBody]
              ..addAll(widget.repliable
                  ? [
                      SizedBox(
                        height: 2.0,
                      ),
                      commentOptions,
                    ]
                  : [])
              ..addAll(this._areRepliesShown ? [commentReplies] : [])));
  }

  _viewReplies([bool withFocus = false]) async {
    setState(() {
      this._areRepliesShown = true;
    });

    if (withFocus) {
      while (this._writeCommentKey.currentState == null) {
        await Future.delayed(Duration(milliseconds: 10));
      }
      this._writeCommentKey.currentState.focus();
    }
  }

  _hideReplies() {
    setState(() {
      this._areRepliesShown = false;
    });
  }
}

class _InteractWithPost extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bloc = BlocProvider.of<MomsayPostBloc>(context);
    final numberOfLikes = bloc.postData.numberOfLikes;
    final numberOfComments = bloc.postData.comments.length;

    return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              _ToggleLike(),
              bloc.postData.commentStatus
                  ? Expanded(
                      child: _WriteComment(),
                    )
                  : Container(),
            ],
          ),
          SizedBox(
            height: 4.0,
          ),
          Row(
            children: <Widget>[
              SizedBox(
                  width: 40.0,
                  child: Text(
                      convertNumberToUserFriendly(numberOfLikes,
                          Localizations.localeOf(context).languageCode),
                      textAlign: TextAlign.center,
                      style: cancelArabicFontDelta(context)
                          .copyWith(color: MomdayColors.LocationGray))),
              bloc.postData.commentStatus
                  ? Expanded(
                      child: Padding(
                      padding: const EdgeInsetsDirectional.only(start: 8.0),
                      child: Text(
                        tCount(context, 'comment', numberOfComments, true),
                        style: cancelArabicFontDelta(context)
                            .copyWith(color: MomdayColors.LocationGray),
                      ),
                    ))
                  : Container(),
            ],
          )
        ]);
  }
}

class _ToggleLike extends StatefulWidget {
  @override
  __ToggleLikeState createState() => __ToggleLikeState();
}

class __ToggleLikeState extends State<_ToggleLike> {
  bool _isTogglingLike;

  @override
  void initState() {
    super.initState();
    this._isTogglingLike = false;
  }

  @override
  Widget build(BuildContext context) {
    final bloc = BlocProvider.of<MomsayPostBloc>(context);
    final isLikedByUser = bloc.postData.isLikedByUser;

    return IconButton(
        icon: Icon(
          Icons.thumb_up,
          color:
              isLikedByUser ? MomdayColors.MomdayGold : MomdayColors.MomdayGray,
        ),
        onPressed: this._isTogglingLike ? null : this._onToggleLike);
  }

  _onToggleLike() async {
    final appManager = AppStateManager.of(context);
    if (!appManager.account.isLoggedIn) {
      askForLogin(context, 'like_this_post');
      return;
    }

    final bloc = BlocProvider.of<MomsayPostBloc>(context);

    setState(() {
      this._isTogglingLike = true;
    });

    await bloc.toggleLike();

    setState(() {
      this._isTogglingLike = false;
    });
  }
}

class _WriteComment extends StatefulWidget {
  final String parentCommentId;

  _WriteComment({Key key, this.parentCommentId}) : super(key: key);

  @override
  __WriteCommentState createState() => __WriteCommentState();
}

class __WriteCommentState extends State<_WriteComment> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();
  String _commentText;
  bool _isSendingComment;

  focus() {
    FocusScope.of(context).requestFocus(this._commentFocusNode);
  }

  @override
  void initState() {
    super.initState();
    this._isSendingComment = false;
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(fontFamily:'VAG',
        hintColor: MomdayColors.MomdayGold,
        primaryColor: MomdayColors.MomdayGold,
      ),
      child: Form(
        key: this._formKey,
        child: TextFormField(
            controller: this._commentController,
            focusNode: this._commentFocusNode,
            keyboardType: TextInputType.multiline,
            maxLines: null,
            inputFormatters: [LengthLimitingTextInputFormatter(1000)],
            decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.zero,
                ),
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        width: 0.1, color: MomdayColors.LocationGray),
                    borderRadius: BorderRadius.zero),
                hintText: tLower(
                    context,
                    widget.parentCommentId == null
                        ? 'write_your_comment'
                        : 'add_your_reply'),
                hintStyle: TextStyle(color: MomdayColors.LocationGray),
                isDense: true,
                suffixIcon: IconButton(
                    icon: Icon(Icons.send),
                    onPressed:
                        this._isSendingComment ? null : this._onSendComment)),
            validator: (value) {
              if (value.isEmpty) {
                return tSentence(context, 'field_required');
              }
            },
            onSaved: (value) => this._commentText = value),
      ),
    );
  }

  _onSendComment() async {
    final appManager = AppStateManager.of(context);
    if (!appManager.account.isLoggedIn) {
      askForLogin(context, 'comment_on_this_post');
      return;
    }

    if (this._formKey.currentState.validate()) {
      this._formKey.currentState.save();

      final bloc = BlocProvider.of<MomsayPostBloc>(context);

      setState(() {
        this._isSendingComment = true;
      });

      final author =
          appManager.account.firstName + " " + appManager.account.lastName;

      int commentId = await bloc.comment(
          comment: CommentModel(
              text: this._commentText, author: author, replies: []),
          parentCommentId: widget.parentCommentId);

      if (commentId == -1) {
        showTextSnackBar(context, tSentence(context, 'comment_error'));
      } else {
        showTextSnackBar(context, tSentence(context, 'comment_submitted'));
      }

      setState(() {
        this._commentFocusNode.unfocus();
        this._isSendingComment = false;
        this._commentController.text = '';
      });
    }
  }
}
