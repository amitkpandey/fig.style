import 'package:flash/flash.dart';
import 'package:flutter/material.dart';
import 'package:figstyle/screens/author_page.dart';
import 'package:figstyle/types/author.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:supercharged/supercharged.dart';

/// A widget which displays an author's image url
/// in an circle shape. Delivered with hover animation.
class CircleAuthor extends StatefulWidget {
  final Author author;
  final double size;
  final double elevation;
  final EdgeInsetsGeometry padding;
  final Function itemBuilder;
  final Function onSelected;

  CircleAuthor({
    @required this.author,
    this.elevation = 3.0,
    this.padding = EdgeInsets.zero,
    this.size = 150.0,
    this.itemBuilder,
    this.onSelected,
  });

  @override
  _CircleAuthorState createState() => _CircleAuthorState();
}

class _CircleAuthorState extends State<CircleAuthor> {
  double size;
  double elevation;
  double opacity;

  @override
  initState() {
    super.initState();

    setState(() {
      size = widget.size;
      elevation = widget.elevation;
      opacity = 0.5;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding,
      child: Column(
        children: <Widget>[
          backgroundContainer(),
          name(),
          popupMenuButton(),
        ],
      ),
    );
  }

  Widget background() {
    final author = widget.author;
    final isImageOk = author.urls.image?.isNotEmpty;

    return Stack(
      children: <Widget>[
        Positioned.fill(
          child: isImageOk
              ? Ink.image(
                  image: NetworkImage(author.urls.image),
                  fit: BoxFit.cover,
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 80.0,
                    vertical: 40.0,
                  ),
                  child: Opacity(
                    opacity: 0.6,
                    child: Icon(
                      Icons.library_books,
                      size: 60.0,
                    ),
                  ),
                ),
        ),
        Positioned.fill(
          child: InkWell(
            onTap: () => onTap(author),
            onHover: (isHover) {
              if (isHover) {
                opacity = 0.0;
                size = widget.size + 2.5;
                elevation = widget.elevation + 2;
              } else {
                opacity = 0.5;
                size = widget.size;
                elevation = widget.elevation;
              }

              setState(() {});
            },
            child: Container(
              color: Color.fromRGBO(0, 0, 0, opacity),
            ),
          ),
        ),
      ],
    );
  }

  Widget backgroundContainer() {
    return AnimatedContainer(
      height: size,
      width: size,
      duration: 250.milliseconds,
      curve: Curves.bounceInOut,
      child: Material(
        elevation: elevation,
        shape: CircleBorder(),
        clipBehavior: Clip.hardEdge,
        color: Colors.transparent,
        child: background(),
      ),
    );
  }

  Widget name() {
    return Container(
      padding: const EdgeInsets.only(top: 20.0),
      width: 120.0,
      child: Opacity(
        opacity: 0.6,
        child: Text(
          widget.author.name,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18.0,
          ),
        ),
      ),
    );
  }

  Widget popupMenuButton() {
    if (widget.itemBuilder == null || widget.onSelected == null) {
      return Padding(padding: EdgeInsets.zero);
    }

    return PopupMenuButton<String>(
      icon: Opacity(
        opacity: .6,
        child: Icon(Icons.more_horiz),
      ),
      onSelected: widget.onSelected,
      itemBuilder: widget.itemBuilder,
    );
  }

  Future onTap(Author author) {
    if (MediaQuery.of(context).size.width > 600.0) {
      return showFlash(
        context: context,
        persistent: false,
        builder: (context, controller) {
          return Flash.dialog(
            controller: controller,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            enableDrag: true,
            margin: const EdgeInsets.only(
              left: 120.0,
              right: 120.0,
            ),
            borderRadius: const BorderRadius.all(
              Radius.circular(8.0),
            ),
            child: FlashBar(
              message: Container(
                height: MediaQuery.of(context).size.height - 100.0,
                padding: const EdgeInsets.all(60.0),
                child: AuthorPage(
                  id: author.id,
                ),
              ),
            ),
          );
        },
      );
    }

    return showCupertinoModalBottomSheet(
      context: context,
      builder: (context, scrollController) => AuthorPage(
        id: author.id,
        scrollController: scrollController,
      ),
    );
  }
}
