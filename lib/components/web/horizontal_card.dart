import 'package:flutter/material.dart';
import 'package:memorare/utils/route_names.dart';
import 'package:memorare/utils/router.dart';

class HorizontalCard extends StatefulWidget {
  final String authorName;
  final String quoteId;
  final String quoteName;
  final String referenceName;

  HorizontalCard({
    this.authorName = '',
    this.quoteId,
    this.quoteName,
    this.referenceName = '',
  });

  @override
  _HorizontalCardState createState() => _HorizontalCardState();
}

class _HorizontalCardState extends State<HorizontalCard> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 700.0,
      height: 350.0,
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          children: <Widget>[
            Card(
              child: InkWell(
                onTap: () {
                  FluroRouter.router.navigateTo(
                    context,
                    QuotePageRoute.replaceFirst(':id', widget.quoteId)
                  );
                },
                child: Padding(
                padding: EdgeInsets.all(60.0),
                child: Text(
                  widget.quoteName,
                  style: TextStyle(
                    fontSize: 27.0,
                  ),
                ),
              ),
              )
            ),
            Padding(
              padding: const EdgeInsets.only(top: 15.0),
              child: Text(
                widget.authorName,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
