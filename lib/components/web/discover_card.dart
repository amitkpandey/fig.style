import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:memorare/state/colors.dart';
import 'package:memorare/router/route_names.dart';
import 'package:memorare/router/router.dart';
import 'package:supercharged/supercharged.dart';

class DiscoverCard extends StatefulWidget {
  final double elevation;
  final double height;
  final String id;
  final String imageUrl;
  final Function itemBuilder;
  final String name;
  final Function onSelected;
  final EdgeInsetsGeometry padding;
  final double titleFontSize;
  final String type;
  final double width;

  DiscoverCard({
    this.elevation      = 3.0,
    this.height         = 330.0,
    this.id,
    this.imageUrl       = '',
    this.itemBuilder,
    this.name           = '',
    this.onSelected,
    this.padding        = EdgeInsets.zero,
    this.titleFontSize  = 18.0,
    this.type           = 'reference',
    this.width          = 250.0,
  });

  @override
  _DiscoverCardState createState() => _DiscoverCardState();
}

class _DiscoverCardState extends State<DiscoverCard> {
  double opacity = 0.5;
  double width;
  double height;
  double elevation;
  double textOpacity = 0.0;
  EdgeInsetsGeometry assetImgPadding;

  @override
  initState() {
    super.initState();

    setState(() {
      width = widget.width;
      height = widget.height;
      elevation = widget.elevation;

      assetImgPadding = width > 300.0 ?
        const EdgeInsets.symmetric(
          horizontal: 80.0,
          vertical: 40.0,
        ) :
        const EdgeInsets.symmetric(
          horizontal: 40.0,
          vertical: 35.0,
        );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding,
      child: Column(
        children: <Widget>[
          AnimatedContainer(
            height: height,
            width: width,
            duration: 250.milliseconds,
            curve: Curves.bounceInOut,
            child: Card(
              elevation: elevation,
              clipBehavior: Clip.antiAliasWithSaveLayer,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0),
              ),
              child: background(),
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: SizedBox(
              width: widget.width - 30.0,
              child: Text(
                widget.name,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: widget.titleFontSize,
                ),
              ),
            ),
          ),

          if (widget.itemBuilder != null && widget.onSelected != null)
            PopupMenuButton<String>(
              icon: Opacity(
                opacity: .6,
                child: Icon(Icons.more_horiz),
              ),
              onSelected: widget.onSelected,
              itemBuilder: widget.itemBuilder,
            ),
        ],
      ),
    );
  }

  Widget background() {
    final isImageOk = widget.imageUrl != null &&
      widget.imageUrl.length > 0;

    return Stack(
      children: <Widget>[
        Positioned.fill(
          child: isImageOk ?
          Ink.image(
            image: NetworkImage(widget.imageUrl),
            fit: BoxFit.cover,
          ) :
          Padding(
            padding: assetImgPadding,
            child: Observer(
              builder: (context) {
                return Image.asset(
                  widget.type == 'reference' ?
                  'assets/images/textbook-${stateColors.iconExt}.png' :
                  'assets/images/profile-${stateColors.iconExt}.png',
                  alignment: Alignment.center,
                );
              }
            )
          ),
        ),

        Positioned.fill(
          child: InkWell(
            onTap: () {
              final route = widget.type == 'reference' ?
                ReferenceRoute.replaceFirst(':id', widget.id) :
                AuthorRoute.replaceFirst(':id', widget.id);

              FluroRouter.router.navigateTo(
                context,
                route,
              );
            },
            onHover: (isHover) {
              if (isHover) {
                opacity = 0.0;
                width = widget.width + 2.5;
                height = widget.height + 2.5;
                elevation = widget.elevation + 2;
              }
              else {
                opacity = 0.5;
                width = widget.width;
                height = widget.height;
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
}
