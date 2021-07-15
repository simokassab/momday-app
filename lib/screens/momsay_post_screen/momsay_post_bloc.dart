import 'dart:async';
import 'package:momday_app/backend_helpers/momday_backend.dart';
import 'package:momday_app/bloc_provider.dart';
import 'package:momday_app/models/models.dart';
import 'package:momday_app/momday_utils.dart';

enum MomsayPostActionTypes {FetchData, ToggleLike, AddComment}

class Action {
  MomsayPostActionTypes type;
  dynamic data;

  Action(this.type, this.data);
}

class MomsayPostBloc extends BlocBase {

  String postId;

  MomsayPostModel postData;

  StreamController<MomsayPostModel> _postController = StreamController<MomsayPostModel>();
  StreamSink<MomsayPostModel> get _in => _postController.sink;
  Stream<MomsayPostModel> get dataStream => _postController.stream;

  StreamController<Action> _actionController = StreamController<Action>.broadcast();
  StreamSink<Action> get _inAction => _actionController.sink;
  Stream<Action> get actionStream => _actionController.stream;

  MomsayPostBloc({this.postId});

  @override
  dispose() {
    _postController.close();
    _in.close();
    _actionController.close();
    _inAction.close();
  }

  @override
  init() {
    this._getPost(this.postId);
  }

  _getPost(postId) async {

    final post = await MomdayBackend().getMomsayPost(postId);

    if (post != null) {
      this.postData = MomsayPostModel.fromDynamic(post);
      this._in.add(this.postData);
      this._inAction.add(Action(MomsayPostActionTypes.FetchData, this.postData));
    }
  }

  toggleLike() async {

    final newVal = !this.postData.isLikedByUser;

    await MomdayBackend().setLikeOnMomsayPost(this.postId, newVal);

    this.postData.isLikedByUser = newVal;

    if (newVal == false) {
      this.postData.numberOfLikes--;
    } else {
      this.postData.numberOfLikes++;
    }

    this._in.add(this.postData);
    this._inAction.add(Action(MomsayPostActionTypes.ToggleLike, newVal));
  }

  Future<int> comment({CommentModel comment, String parentCommentId}) async {

    final commentId = await MomdayBackend().addCommentToMomsayPost(
      postId: this.postId,
      comment: comment.text,
      parentCommentId: parentCommentId
    );

    if(commentId == -1){
      return commentId;
    }

    comment.id =  commentId.toString();
    if (parentCommentId == null) {
      this.postData.comments.add(comment);
    } else {
      final parentComment = this.postData.comments.firstWhere((comment) => comment.id == parentCommentId);

      parentComment.replies.add(comment);
    }

    this._in.add(this.postData);
    this._inAction.add(Action(MomsayPostActionTypes.AddComment,
      {
        'comment': comment,
        'parentCommentId': parentCommentId
      })
    );

    return commentId;
  }
}