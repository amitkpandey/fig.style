import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:memorare/actions/drafts.dart';
import 'package:memorare/actions/temp_quotes.dart';
import 'package:memorare/components/web/add_quote_app_bar.dart';
import 'package:memorare/components/web/full_page_error.dart';
import 'package:memorare/components/web/full_page_loading.dart';
import 'package:memorare/data/add_quote_inputs.dart';
import 'package:memorare/router/route_names.dart';
import 'package:memorare/router/router.dart';
import 'package:memorare/screens/add_quote/help/author.dart';
import 'package:memorare/screens/add_quote/help/comment.dart';
import 'package:memorare/screens/add_quote/help/content.dart';
import 'package:memorare/screens/add_quote/help/reference.dart';
import 'package:memorare/screens/add_quote/help/topics.dart';
import 'package:memorare/screens/web/add_quote_author.dart';
import 'package:memorare/screens/web/add_quote_comment.dart';
import 'package:memorare/screens/web/add_quote_content.dart';
import 'package:memorare/screens/web/add_quote_reference.dart';
import 'package:memorare/screens/web/add_quote_topics.dart';
import 'package:memorare/state/colors.dart';
import 'package:memorare/state/user_state.dart';
import 'package:memorare/utils/snack.dart';

class AddQuoteSteps extends StatefulWidget {
  @override
  _AddQuoteStepsState createState() => _AddQuoteStepsState();
}

class _AddQuoteStepsState extends State<AddQuoteSteps> {
  int currentStep     = 0;
  bool isCheckingAuth = false;
  bool isCompleted    = false;
  bool isSubmitting   = false;
  String errorMessage = '';

  bool canManage = false;

  String fabText = 'Submit quote';
  Icon fabIcon = Icon(Icons.send);
  bool isFabVisible = true;
  bool isSmallView = false;

  AddQuoteType actionIntent;
  AddQuoteType actionResult;

  var steps = [
    // The first step is defined
    // in the stepperSections() function
    // to allow the use of a member function.

    Step(
      title: const Text('Topics'),
      content: AddQuoteTopics(),
    ),

    Step(
      title: const Text('Author'),
      content: AddQuoteAuthor(),
    ),

    Step(
      title: const Text('Reference'),
      content: AddQuoteReference(),
    ),

    Step(
      title: const Text('Comments'),
      content: AddQuoteComment(),
    ),
  ];

  var helpSteps = [
    HelpContent(),
    HelpTopics(),
    HelpAuthor(),
    HelpReference(),
    HelpComment(),
  ];

  @override
  void initState() {
    super.initState();
    checkAuth();

    if (AddQuoteInputs.quote.id.isNotEmpty) {
      fabText = 'Save quote';
      fabIcon = Icon(Icons.save);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: isFabVisible
        ? FloatingActionButton.extended(
          onPressed: () => propose(),
          backgroundColor: stateColors.primary,
          foregroundColor: Colors.white,
          icon: fabIcon,
          label: Text(fabText,),
        )
        : Padding(padding: EdgeInsets.zero,),
      body: CustomScrollView(
        slivers: <Widget>[
          AddQuoteAppBar(
            help: helpSteps[currentStep],
            title: AddQuoteInputs.quote.id.isEmpty
              ? 'New quote'
              : 'Edit quote',
          ),

          SliverLayoutBuilder(
            builder: (context, constrains) {
              isSmallView = constrains.crossAxisExtent < 600.0;
              return body();
            },
          ),
        ],
      ),
    );
  }

  Widget body() {
    if (errorMessage.isNotEmpty) {
      return SliverList(
        delegate: SliverChildListDelegate([
          FullPageError(
            message: errorMessage,
          ),
        ]),
      );
    }

    if (isCheckingAuth) {
      return SliverList(
        delegate: SliverChildListDelegate([
          FullPageLoading(),
        ]),
      );
    }

    if (isSubmitting) {
      return SliverList(
        delegate: SliverChildListDelegate([
          FullPageLoading(
            title: AddQuoteInputs.quote.id.isEmpty
            ? 'Submitting quote...'
            : 'Saving quote...',
          ),
        ]),
      );
    }

    if (isCompleted) {
      return completedView();
    }

    return stepperSections();
  }

  Widget completedView() {
    return SliverList(
      delegate: SliverChildListDelegate([
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 60.0,
            vertical: 140.0,
          ),
          child: Column(
            children: <Widget>[
              Container(
                width: 500.0,
                padding: const EdgeInsets.only(top: 10.0),
                child: Opacity(
                  opacity: .8,
                  child: Text(
                    getResultMessage(
                      actionIntent: actionIntent,
                      actionResult: actionResult,
                    ),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22.0,
                    ),
                  ),
                ),
              ),

              Container(
                width: 500.0,
                padding: const EdgeInsets.only(top: 10.0),
                child: Opacity(
                  opacity: .5,
                  child: Text(
                    getResultSubMessage(
                      actionIntent: actionIntent,
                      actionResult: actionResult,
                    ),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 17.0,
                    ),
                  ),
                ),
              ),

              completedViewActions(),
            ],
          ),
        ),
      ]),
    );
  }

  Widget completedViewActions() {
    return isSmallView
      ? smallNavActions()
      : largeNavActions();
  }

  Widget largeAction({
    String labelText = '',
    Function onTap,
    Widget icon,
    Color backgroundIconColor,
  }) {
    return SizedBox(
      width: 120.0,
      child: Column(
        children: <Widget>[
          Material(
            elevation: 3.0,
            color: backgroundIconColor,
            shape: CircleBorder(),
            clipBehavior: Clip.hardEdge,
            child: InkWell(
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: icon,
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: Opacity(
              opacity: 0.6,
              child: Text(
                labelText,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget largeNavActions() {
    return Padding(
      padding: const EdgeInsets.only(
        top: 100.0,
        bottom: 200.0,
      ),
      child: Wrap(
        spacing: 40.0,
        runSpacing: 20.0,
        children: <Widget>[
          largeAction(
            labelText: 'Home',
            icon: Icon(Icons.home, color: Colors.white),
            backgroundIconColor: Colors.green.shade400,
            onTap: () => FluroRouter.router.navigateTo(context, RootRoute),
          ),

          largeAction(
            labelText: 'Add another quote',
            icon: Icon(Icons.add, color: Colors.white),
            backgroundIconColor: stateColors.primary,
            onTap: () {
              AddQuoteInputs.clearQuoteData();
              AddQuoteInputs.clearTopics();
              AddQuoteInputs.clearComment();

              FluroRouter.router.navigateTo(
                context,
                AddQuoteContentRoute,
                replace: true,
              );
            },
          ),

          largeAction(
            labelText: canManage
              ? 'Admin temporary quotes'
              : 'Temporary quotes',
            icon: Icon(Icons.timelapse, color: Colors.white),
            backgroundIconColor: Colors.orange,
            onTap: () {
              final route = canManage
                ? AdminTempQuotesRoute
                : TempQuotesRoute;

              FluroRouter.router.navigateTo(
                context,
                route,
                replace: true,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget smallActionCard({
    String labelText = '',
    Function onTap,
    Color iconBackgroundColor,
    Widget icon,
  }) {
    return Container(
      width: 400.0,
      padding: const EdgeInsets.all(10.0),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: <Widget>[
              CircleAvatar(
                radius: 30.0,
                backgroundColor: iconBackgroundColor,
                foregroundColor: Colors.white,
                child: icon,
              ),

              Padding(padding: const EdgeInsets.only(left: 30.0)),

              Expanded(
                flex: 2,
                child: Opacity(
                  opacity: 0.6,
                  child: Text(
                    labelText,
                    style: TextStyle(
                      fontSize: 20.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget smallNavActions() {
    return Padding(
      padding: const EdgeInsets.only(
        top: 100.0,
        bottom: 200.0,
      ),
      child: Column(
        children: <Widget>[
          smallActionCard(
            labelText: 'Home',
            icon: Icon(Icons.home,),
            iconBackgroundColor: Colors.green.shade400,
            onTap: () => FluroRouter.router.navigateTo(context, RootRoute),
          ),

          smallActionCard(
            labelText: 'Add another quote',
            icon: Icon(Icons.add,),
            iconBackgroundColor: stateColors.primary,
            onTap: () {
              AddQuoteInputs.clearQuoteData();
              AddQuoteInputs.clearTopics();
              AddQuoteInputs.clearComment();

              FluroRouter.router.navigateTo(
                context,
                AddQuoteContentRoute,
                replace: true,
              );
            },
          ),

          smallActionCard(
            labelText: canManage
              ? 'Admin temporary quotes'
              : 'Temporary quotes',
            icon: Icon(Icons.timelapse,),
            iconBackgroundColor: Colors.orange,
            onTap: () {
              final route = canManage
                ? AdminTempQuotesRoute
                : TempQuotesRoute;

              FluroRouter.router.navigateTo(
                context,
                route,
                replace: true,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget stepperSections() {
    return SliverPadding(
      padding: EdgeInsets.symmetric(
        vertical: 80.0,
        horizontal: isSmallView
          ? 0.0
          : 80,
      ),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          Stepper(
            currentStep: currentStep,
            onStepContinue: next,
            onStepCancel: cancel,
            onStepTapped: (step) => goTo(step),
            steps: [
              Step(
                title: Text('Content'),
                content: AddQuoteContent(
                  onSaveDraft: () => saveQuoteDraft(),
                ),
              ),

              ...steps,
            ] //steps,
          ),
        ])
      ),
    );
  }

  void next() {
    currentStep + 1 != (steps.length + 1) // + 1 dynamic step
        ? goTo(currentStep + 1)
        : propose();
  }

  void cancel() {
    if (currentStep > 0) {
      goTo(currentStep - 1);
      return;
    }

    Navigator.pop(context);
  }

  void goTo(int step) {
    setState(() => currentStep = step);
  }

  void checkAuth() async {
    setState(() {
      isCheckingAuth = true;
      isFabVisible = false;
    });

    try {
      final userAuth = await userState.userAuth;

      setState(() {
        isCheckingAuth = false;
        isFabVisible = true;
      });

      if (userAuth == null) {
        FluroRouter.router.navigateTo(context, SigninRoute);
        return;
      }

      final user = await Firestore.instance
        .collection('users')
        .document(userAuth.uid)
        .get();

      if (!user.exists) { return; }

      setState(() {
        canManage = user.data['rights']['user:managequote'] == true;
      });

    } catch (error) {
      debugPrint(error.toString());
      isCheckingAuth = false;
      FluroRouter.router.navigateTo(context, SigninRoute);
    }
  }

  bool badQuoteFormat() {
    if (AddQuoteInputs.quote.name.isEmpty) {
      showSnack(
        context: context,
        message: "The quote's content cannot be empty.",
        type: SnackType.error,
      );

      return true;
    }

    if (AddQuoteInputs.quote.topics.length == 0) {
      showSnack(
        context: context,
        message: 'You must select at least 1 topics for the quote.',
        type: SnackType.error,
      );

      return true;
    }

    return false;
  }

  void propose() async {
    if (badQuoteFormat()) {
      return;
    }

    actionIntent = AddQuoteType.tempquote;

    setState(() {
      isSubmitting = true;
      isFabVisible = false;
    });

    final success = await proposeQuote(context: context);

    if (success) {
      setState(() {
        actionResult = AddQuoteType.tempquote;
        isSubmitting = false;
        isCompleted = true;
      });

      if (AddQuoteInputs.isOfflineDraft) {
        deleteOfflineDraft(
          createdAt: AddQuoteInputs.draft.createdAt.toString(),
        );
      }

      if (AddQuoteInputs.draft != null) {
        await deleteDraft(
          context: context,
          draft: AddQuoteInputs.draft,
        );
      }

      return;
    }

    // Don't duplicate the draft (if it's already one)
    if (AddQuoteInputs.draft != null) {
      setState(() {
        actionResult = AddQuoteType.draft;
        isSubmitting = false;
        isCompleted = true;
      });

      return;
    }

    final successDraft = await saveDraft(
      context: context,
    );

    if (successDraft) {
      setState(() {
        actionResult = AddQuoteType.draft;
        isSubmitting = false;
        isCompleted = true;
      });

      if (AddQuoteInputs.isOfflineDraft) {
        deleteOfflineDraft(
          createdAt: AddQuoteInputs.draft.createdAt.toString(),
        );
      }

      return;
    }

    await saveOfflineDraft(context: context);
    actionResult = AddQuoteType.offline;
  }

  void saveQuoteDraft() async {
    if (AddQuoteInputs.quote.name.isEmpty) {
      showSnack(
        context: context,
        message: "The quote's content cannot be empty.",
        type: SnackType.error,
      );

      return;
    }

    actionIntent = AddQuoteType.draft;

    final successDraft = await saveDraft(
      context: context,
    );

    if (successDraft) {
      setState(() {
        actionResult = AddQuoteType.draft;
        isSubmitting = false;
        isCompleted = true;
      });

      if (AddQuoteInputs.isOfflineDraft) {
        deleteOfflineDraft(
          createdAt: AddQuoteInputs.draft.createdAt.toString(),
        );
      }

      return;
    }

    await saveOfflineDraft(context: context);

    setState(() {
      actionResult = AddQuoteType.offline;
      isSubmitting = false;
      isCompleted = true;
    });
  }
}