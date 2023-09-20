import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:like_app/datas/users.dart';

class NumbersWidget extends StatelessWidget {
  DocumentSnapshot<Map<String, dynamic>> user;

  NumbersWidget(this.user);

  @override
  Widget build(BuildContext context) => Row(     //////
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          buildButton(context, user["ranking"].toString(), 'Ranking'),
          buildDivider(context),
          buildButton(context, user["likes"].length.toString(), 'Likes'),
          buildDivider(context),
          buildButton(context, user["posts"].length.toString(), 'Posts'),
        ],
      );
  Widget buildDivider(BuildContext context) => Container(
        height: MediaQuery.of(context).size.height * 0.024,
        child: VerticalDivider(),
      );

  Widget buildButton(BuildContext context, String value, String text) =>
      MaterialButton(
        padding: EdgeInsets.symmetric(vertical: 4),
        onPressed: () {},
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text(
              value,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: MediaQuery.of(context).size.height * 0.028),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.004),
            Text(
              text,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
}