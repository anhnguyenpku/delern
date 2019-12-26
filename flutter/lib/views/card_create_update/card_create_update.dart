import 'package:delern_flutter/flutter/localization.dart' as localizations;
import 'package:delern_flutter/flutter/styles.dart' as app_styles;
import 'package:delern_flutter/models/card_model.dart';
import 'package:delern_flutter/view_models/card_create_update_bloc.dart';
import 'package:delern_flutter/views/base/screen_bloc_view.dart';
import 'package:delern_flutter/views/helpers/progress_indicator_widget.dart';
import 'package:delern_flutter/views/helpers/save_updates_dialog.dart';
import 'package:delern_flutter/views/helpers/stream_with_value_builder.dart';
import 'package:delern_flutter/views/helpers/text_overflow_ellipsis_widget.dart';
import 'package:flutter/material.dart';

class CardCreateUpdate extends StatefulWidget {
  static const routeNameNew = '/cards/new';
  static const routeNameEdit = '/cards/edit';

  final CardModelBuilder card;

  const CardCreateUpdate({@required this.card}) : assert(card != null);

  @override
  State<StatefulWidget> createState() => _CardCreateUpdateState();
}

class _CardCreateUpdateState extends State<CardCreateUpdate> {
  bool _addReversedCard = false;
  bool _isChanged = false;
  final TextEditingController _frontTextController = TextEditingController();
  final TextEditingController _backTextController = TextEditingController();
  final FocusNode _frontSideFocus = FocusNode();

  @override
  void dispose() {
    _frontSideFocus.dispose();
    _frontTextController.dispose();
    _backTextController.dispose();
    super.dispose();
  }

  Future<void> showCardSaveUpdateDialog(CardCreateUpdateBloc bloc) async {
    if (_isChanged) {
      final locale = localizations.of(context);
      final continueEditingDialog = await showSaveUpdatesDialog(
          context: context,
          changesQuestion: locale.continueEditingQuestion,
          yesAnswer: locale.yes,
          noAnswer: locale.discard);
      if (continueEditingDialog) {
        return false;
      }
    }
    bloc.onDiscardChanges.add(null);
  }

  @override
  Widget build(BuildContext context) => ScreenBlocView<CardCreateUpdateBloc>(
        blocBuilder: (user) {
          final bloc = CardCreateUpdateBloc(card: widget.card, user: user);
          bloc.doFrontSideTextController
              .listen((text) => _frontTextController.text = text);
          bloc.doBackSideTextController
              .listen((text) => _backTextController.text = text);
          bloc.doClearInputFields.listen((_) => _clearInputFields(bloc));
          bloc.doShowConfirmationDialog
              .listen((_) => showCardSaveUpdateDialog(bloc));
          return bloc;
        },
        appBarBuilder: _buildAppBar,
        bodyBuilder: _buildUserInput,
      );

  AppBar _buildAppBar(CardCreateUpdateBloc bloc) {
    void saveCard() => bloc.onSaveCard.add(null);
    return AppBar(
      title: buildStreamBuilderWithValue(
        streamWithValue: bloc.deck,
        builder: (_, snapshot) => snapshot.hasData
            ? TextOverflowEllipsisWidget(
                textDetails: snapshot.data.name,
              )
            : ProgressIndicatorWidget(),
      ),
      actions: <Widget>[
        StreamBuilder<bool>(
          initialData: false,
          stream: bloc.isOperationEnabled,
          builder: (context, snapshot) => bloc.isAddOperation
              ? IconButton(
                  tooltip: localizations.of(context).addCardTooltip,
                  icon: const Icon(Icons.check),
                  onPressed: snapshot.data ? saveCard : null,
                )
              : FlatButton(
                  onPressed: _isChanged && snapshot.data ? saveCard : null,
                  child: Text(
                    localizations.of(context).save.toUpperCase(),
                    style: _isChanged && snapshot.data
                        ? const TextStyle(color: Colors.white)
                        : null,
                  ),
                ),
        )
      ],
    );
  }

  Widget _buildUserInput(CardCreateUpdateBloc bloc) {
    final widgetsList = <Widget>[
      // TODO(ksheremet): limit lines in TextField
      TextField(
        key: const Key('frontCardInput'),
        autofocus: true,
        focusNode: _frontSideFocus,
        maxLines: null,
        keyboardType: TextInputType.multiline,
        controller: _frontTextController,
        onChanged: (text) {
          setState(() {
            bloc.onFrontSideText.add(text);
            _isChanged = true;
          });
        },
        style: app_styles.primaryText,
        decoration: InputDecoration(
          hintText: localizations.of(context).frontSideHint,
        ),
      ),
      TextField(
        key: const Key('backCardInput'),
        maxLines: null,
        keyboardType: TextInputType.multiline,
        controller: _backTextController,
        onChanged: (text) {
          setState(() {
            bloc.onBackSideText.add(text);
            _isChanged = true;
          });
        },
        style: app_styles.primaryText,
        decoration: InputDecoration(
          hintText: localizations.of(context).backSideHint,
        ),
      ),
    ];

    // Add reversed card widget if it is adding cards
    if (bloc.isAddOperation) {
      // https://github.com/flutter/flutter/issues/254 suggests using
      // CheckboxListTile to have a clickable checkbox label.
      widgetsList.add(CheckboxListTile(
        title: Text(
          localizations.of(context).reversedCardLabel,
          style: app_styles.secondaryText,
        ),
        value: _addReversedCard,
        onChanged: (newValue) {
          bloc.onAddReversedCard.add(newValue);
          setState(() {
            _addReversedCard = newValue;
          });
        },
        // Position checkbox before the text.
        controlAffinity: ListTileControlAffinity.leading,
      ));
    }

    return ListView(
      padding: const EdgeInsets.only(left: 8, right: 8),
      children: widgetsList,
    );
  }

  void _clearInputFields(CardCreateUpdateBloc bloc) {
    setState(() {
      _isChanged = false;
      _frontTextController.clear();
      _backTextController.clear();
      bloc.onFrontSideText.add('');
      bloc.onBackSideText.add('');
      FocusScope.of(context).requestFocus(_frontSideFocus);
    });
  }
}
