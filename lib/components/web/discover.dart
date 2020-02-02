import 'package:flutter/material.dart';
import 'package:memorare/components/web/discover_card.dart';
import 'package:memorare/components/web/firestore_app.dart';
import 'package:memorare/types/author.dart';
import 'package:memorare/types/reference.dart';

class Discover extends StatefulWidget {
  @override
  _DiscoverState createState() => _DiscoverState();
}

class _DiscoverState extends State<Discover> {
  List<Reference> references = [];
  List<Author> authors = [];

  bool isLoading = false;

  @override
  initState() {
    super.initState();

    if (references.length > 0) { return; }
    fetchAuthorsAndReferences();
  }

  @override
  Widget build(BuildContext context) {
    final cards = createCards();

    return SizedBox(
      height: 600.0,
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 60.0),
            child: Text(
              'DISCOVER',
              style: TextStyle(
                fontSize: 16.0,
              ),
            ),
          ),

          SizedBox(
            width: 50.0,
            child: Divider(thickness: 2.0,),
          ),

          Padding(
            padding: const EdgeInsets.only(bottom: 40.0),
            child: Opacity(
              opacity: .6,
              child: Text(
                'Learn knowledge about an author or a reference.'
              ),
            ),
          ),

          SizedBox(
            height: 440.0,
            child: ListView(
              padding: EdgeInsets.symmetric(
                vertical: 40.0,
                horizontal: 80.0
              ),
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              children: cards,
            ),
          )
        ],
      ),
    );
  }

  List<Widget> createCards() {
    List<Widget> cards = [];

    for (var reference in references) {
      cards.add(
        DiscoverCard(
          name: reference.name,
          summary: reference.summary,
        ),
      );
    }

    for (var author in authors) {
      cards.add(
        DiscoverCard(
          name: author.name,
          summary: author.summary,
        ),
      );
    }

    return cards;
  }

  void fetchAuthorsAndReferences() async {
    if (!this.mounted) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    List<Reference> referencesList = [];
    List<Author> authorsList = [];

    try {
      final refsSnapshot = await FirestoreApp.instance
        .collection("references")
        .where('lang', '==', 'en')
        .orderBy('updatedAt', 'desc')
        .limit(2)
        .get();

      if (!refsSnapshot.empty) {
        refsSnapshot.forEach((docSnapshot) {
          final ref = Reference.fromJSON(docSnapshot.data());
          referencesList.add(ref);
        });
      }

      final authorsSnapshot = await FirestoreApp.instance
        .collection('authors')
        .limit(1)
        .get();

      if (!authorsSnapshot.empty) {
        authorsSnapshot.forEach((doc) {
          final author = Author.fromJSON(doc.data());
          authorsList.add(author);
        });
      }

      if (!this.mounted) {
        return;
      }

      setState(() {
        authors = authorsList;
        references = referencesList;

        isLoading = false;
      });

    } catch (error, stackTrace) {
      debugPrint('error => $error');
      debugPrint(stackTrace.toString());

      setState(() {
        isLoading = false;
      });
    }
  }
}
