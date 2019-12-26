import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:memorare/data/mutations.dart';
import 'package:memorare/data/queries.dart';
import 'package:memorare/types/colors.dart';
import 'package:memorare/types/quotes_list.dart';
import 'package:provider/provider.dart';

enum ButtonType {
  icon,
  tile,
}

class AddToListButton extends StatefulWidget {
  final BuildContext context;
  final Function onBeforeShowSheet;
  final String quoteId;
  final ButtonType type;

  AddToListButton({
    this.context,
    this.onBeforeShowSheet,
    this.quoteId,
    this.type = ButtonType.icon
  });

  @override
  _AddToListButtonState createState() => _AddToListButtonState();
}

class _AddToListButtonState extends State<AddToListButton> {
  List<QuotesList> quotesLists = [];

  String newListName = '';
  String newListDescription = '';

  int limit = 20;
  int order = 1;
  int skip = 0;

  bool isLoading = false;
  bool hasErrors = false;
  Error error;

  @override
  Widget build(BuildContext context) {
    return widget.type == ButtonType.icon ?
      IconButton(
        icon: Icon(
          Icons.playlist_add,
          size: 30.0,
        ),
        onPressed: () {
          if (widget.onBeforeShowSheet != null) {
            widget.onBeforeShowSheet();
          }

          showBottomSheetList();
        },
      ):
      ListTile(
        onTap: () {
          if (widget.onBeforeShowSheet != null) {
            widget.onBeforeShowSheet();
          }

          showBottomSheetList();
        },
        leading: Icon(Icons.playlist_add),
        title: Text(
          'Add to...',
          style: TextStyle(
            fontWeight: FontWeight.bold
          ),
        ),
      );
  }

  void showBottomSheetList() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setSheetState) {
            final newListButton = ListTile(
              onTap: () async {
                final res = await showNewListDialog(context);
                if (res) { Navigator.pop(context); }
              },
              leading: Icon(Icons.add),
              title: Text(
                'New list',
                textAlign: TextAlign.start,
                style: TextStyle(
                  fontSize: 20.0,
                ),
              ),
            );

            List<Widget> tiles = [];

            if (hasErrors) {
              tiles.add(
                Padding(
                  padding: EdgeInsets.all(5.0),
                  child: Column(
                    children: <Widget>[
                      Text(
                        'There was an issue while loading your lists.'
                      ),
                      FlatButton(
                        onPressed: () {
                          fetchLists()
                          .then((resp) {
                            setSheetState(() {
                              quotesLists = resp;
                            });
                          });
                        },
                        child: Padding(
                          padding: EdgeInsets.all(5.0),
                          child: Text('Retry'),
                        ),
                      )
                    ],
                  ),
                )
              );
            }

            if (quotesLists.length == 0 && !isLoading) {
              tiles.add(LinearProgressIndicator());

              fetchLists()
                .then((resp) {
                  setSheetState(() {
                    quotesLists = resp;
                  });
                })
                .catchError((err) {
                  setSheetState(() {
                    error = err;
                    hasErrors = true;
                    isLoading = false;
                  });
                });
            } else {
              for (var list in quotesLists) {
                tiles.add(
                  ListTile(
                    onTap: () {
                      addQuoteToList(
                        context: context,
                        listId: list.id,
                        listName: list.name
                      );

                      Navigator.pop(context);
                    },
                    title: Text(
                      list.name,
                    ),
                  )
                );
              }
            }

            return ListView(
              children: <Widget>[
                newListButton,
                Divider(),
                ...tiles
              ],
            );
          },
        );
      }
    );
  }

  Future<List<QuotesList>> fetchLists() {
    isLoading = true;

    return Queries
    .lists(context, limit, order, skip)
    .then((resp) {
      isLoading = false;

      return resp.entries;
    })
    .catchError((err) {
      return [];
    });
  }

  Future<bool> showNewListDialog(BuildContext context) {
    final accent = Provider.of<ThemeColor>(context).accent;

    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text(
            'Create a new list'
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 25.0),
          children: <Widget>[
            TextField(
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Name',
                labelStyle: TextStyle(color: accent),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: accent,
                    width: 2.0
                  ),
                ),
              ),
              onChanged: (newValue) {
                newListName = newValue;
              },
            ),
            Padding(padding: EdgeInsets.only(top: 10.0),),
            TextField(
              decoration: InputDecoration(
                labelText: 'Description',
                labelStyle: TextStyle(color: accent),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: accent,
                    width: 2.0
                  ),
                ),
              ),
              onChanged: (newValue) {
                newListDescription = newValue;
              },
            ),
            Padding(padding: EdgeInsets.only(top: 20.0),),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                FlatButton(
                  onPressed: () {
                    return Navigator.of(context).pop(false);
                  },
                  child: Text(
                    'Cancel',
                  ),
                ),

                RaisedButton(
                  color: accent,
                  onPressed: () {
                    createNewList(context);
                    return Navigator.of(context).pop(true);
                  },
                  child: Text(
                    'Create',
                    style: TextStyle(color: Colors.white),
                  ),
                )
              ],
            ),
          ],
        );
      }
    );
  }

  void addQuoteToList({BuildContext context, String listId, String listName}) {
    final _context = widget.context ?? context;

    UserMutations
    .addUniqToList(context, listId, widget.quoteId)
    .then((resp) {
      if (resp.boolean) {
        Flushbar(
          duration: Duration(seconds: 3),
          backgroundColor: ThemeColor.success,
          message: 'Added to the list $listName.',
        )..show(_context);
        return;
      }

      Flushbar(
        duration: Duration(seconds: 3),
        backgroundColor: ThemeColor.error,
        message: resp.message,
      )..show(_context);
    });
  }

  void createNewList(BuildContext context) {
    final _context = widget.context ?? context;

    UserMutations
    .createList(
      context: context,
      name: newListName,
      description: newListDescription,
      quoteId: widget.quoteId,
    ).then((quotesListResp) {
      Flushbar(
        duration: Duration(seconds: 3),
        backgroundColor: ThemeColor.success,
        message: 'Your new list $newListName has been created.',
      )..show(_context);
    })
    .catchError((err) {
      Flushbar(
        duration: Duration(seconds: 3),
        backgroundColor: ThemeColor.error,
        message: 'Could not create your new list. Try again later or contact us.',
      )..show(_context);
    });
  }
}
