import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_device_type/flutter_device_type.dart';
import 'package:like_app/services/comment_service.dart';
import 'package:like_app/services/userService.dart';

class CommentCard extends StatefulWidget {

  final String? commentId;
  final String? uId;

  const CommentCard({super.key, required this.commentId, required this.uId});

  @override
  State<CommentCard> createState() => _CommentCardState();
}

class _CommentCardState extends State<CommentCard> {

  DocumentSnapshot<Map<String, dynamic>>? commentInfo;

  bool isLoading = true;
  bool isCommentLike = false;
  int likes = 0;
  String commentOwnerUid = "";

  bool isOwnComment = false;

  DatabaseService databaseService = new DatabaseService();

  @override
  void initState() {
    super.initState();
    getCommentInfo();
    
  }

  getCommentInfo() async {
    CommentService commentService = new CommentService(commentId: widget.commentId);
    await commentService.getCommentInfo().then((value) => {
      commentInfo = value,
      if (mounted) {
        setState(() {
          likes = commentInfo!["likedUsers"].length;

          isCommentLike = commentInfo!["likedUsers"].contains(widget.uId);

          isLoading = false;

          commentOwnerUid = commentInfo!["uId"];

          isOwnComment = commentOwnerUid == widget.uId;

        })
      }
    });
  }

  @override
  Widget build(BuildContext context) {

    double fontSize;
    double radiusWidth;
    double iconSize;

    CommentService commentService = new CommentService(commentId: widget.commentId);

    if(Device.get().isTablet) {
      fontSize = MediaQuery.of(context).size.width * 0.026;
      radiusWidth = MediaQuery.of(context).size.width * 0.026;
      iconSize = MediaQuery.of(context).size.width * 0.03;

    }
    else {
      fontSize = MediaQuery.of(context).size.width * 0.037;
      radiusWidth = MediaQuery.of(context).size.width * 0.035;
      iconSize = MediaQuery.of(context).size.width * 0.038;

    }

    return isLoading? Center(child: CircularProgressIndicator(color: Theme.of(context).primaryColor,),) : 
    GestureDetector(
      onDoubleTap: () async {
        setState(() {
          if (isCommentLike) {
            isCommentLike = false;
            likes = likes - 1;
            commentService.removeCommentLikeUser(widget.uId!);
          } else {
            isCommentLike = true;
            likes = likes + 1;
            commentService.addCommentLikeUser(widget.uId!);
          }
        });

        if (isCommentLike) {
          await databaseService.plusCommentLike(commentOwnerUid);

        } else {
          await databaseService.minusCommentLike(commentOwnerUid);
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.height * 0.023,
          horizontal: MediaQuery.of(context).size.width * 0.03
        ),
        child:
       Stack(
        children: [
           Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage("https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png"),
              radius: radiusWidth,
            ),
            Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.02, top: MediaQuery.of(context).size.height * 0.01),
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(color: Colors.black, fontSize: fontSize * 0.9),
                        children: [
                          TextSpan(
                            text: commentInfo!["username"],
                            style: TextStyle(fontWeight: FontWeight.bold)
                          ),
                          TextSpan(
                            text: " " + commentInfo!["posted"],
                            style: TextStyle(fontWeight: FontWeight.normal, fontSize: fontSize * 0.9)
                          ),
                        ]
                      )
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.02, top: MediaQuery.of(context).size.height * 0.005),
                    child: RichText(text: TextSpan(
                      style: TextStyle(color: Colors.black, fontSize: fontSize),
                      text: commentInfo!["description"],
                    )),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.02, top: MediaQuery.of(context).size.height * 0.008),
                    child: Text(
                      likes.toString() + " likes",
                      style: TextStyle(
                        fontSize: fontSize * 0.9,
                        fontWeight: FontWeight.w400
                      ),
                    ),
                  )
                ],
              ),
          ],
        ),
        isOwnComment ?
         Positioned(child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.04,
              child: IconButton(onPressed: () async {
                setState(() {
                  if (isCommentLike) {
                    isCommentLike = false;
                    likes = likes - 1;
                    commentService.removeCommentLikeUser(widget.uId!);
                    
                  } else {
                    isCommentLike = true;
                    likes = likes + 1;
                    commentService.addCommentLikeUser(widget.uId!);
                  }
                });

                if (isCommentLike) {
                  await databaseService.plusCommentLike(widget.uId!);

                } else {
                  await databaseService.minusCommentLike(widget.uId!);
                }
              }, icon: isCommentLike? Icon(Icons.favorite, size: iconSize, color: Colors.red,) : Icon(Icons.favorite_border_outlined, size: iconSize)), 
            ),
            IconButton(onPressed: () {
              _showOptionMenu();
            }, 
              icon: Icon(Icons.more_vert_rounded, size: MediaQuery.of(context).size.width * 0.04)
            ), 
          ],
         ), left: MediaQuery.of(context).size.width * 0.78,) :
         Positioned(child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.08,
              child: IconButton(onPressed: () async {
                setState(() {
                  if (isCommentLike) {
                    isCommentLike = false;
                    likes = likes - 1;
                    commentService.removeCommentLikeUser(widget.uId!);
                  } else {
                    isCommentLike = true;
                    likes = likes + 1;
                    commentService.addCommentLikeUser(widget.uId!);
                  }
                });

                if (isCommentLike) {
                  await databaseService.plusCommentLike(widget.uId!);

                } else {
                  await databaseService.minusCommentLike(widget.uId!);
                }
              }, icon: isCommentLike? Icon(Icons.favorite, size: iconSize, color: Colors.red,) : Icon(Icons.favorite_border_outlined, size: iconSize)), 
            ),
          ],
         ), left: MediaQuery.of(context).size.width * 0.78,)
        ]
       ) 
      ),
    );
  }

  void _showOptionMenu() {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(25.0)
          )
        ),
        builder: (BuildContext context) {
          return Container(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(Icons.edit),
                  title: Text('Edit Comment'),
                  onTap: () async{
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.remove_circle),
                  title: Text('Remove Comment'),
                  onTap: () async{
                    Navigator.pop(context);
                  },
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.02,)
              ],
            ),
          );
        }
      );
  }
}