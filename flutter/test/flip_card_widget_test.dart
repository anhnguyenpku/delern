import 'package:delern_flutter/flutter/localization.dart';
import 'package:delern_flutter/flutter/styles.dart' as app_styles;
import 'package:delern_flutter/views/helpers/card_background_specifier.dart';
import 'package:delern_flutter/views/helpers/flip_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Flip card', (tester) async {
    const frontSide = 'der Vater';
    const backSide = 'father';
    var _isBackShowed = false;

    // Widget must be wrapped in MaterialApp widget because it uses material
    // related classes.
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: [
        AppLocalizationsDelegate(),
      ],
      home: FlipCardWidget(
        front: frontSide,
        back: backSide,
        backgroundColor: app_styles.cardBackgroundColors[Gender.masculine],
        isMarkdown: false,
        onFlipCallback: (flipped) {
          _isBackShowed = flipped;
        },
      ),
    ));
    await tester.pumpAndSettle();
    final frontFinder = find.text(frontSide);
    expect(frontFinder, findsOneWidget);
    // Back side wasn't showed
    assert(!_isBackShowed);
    await tester.tap(find.byType(Card));
    await tester.pumpAndSettle();
    final backFinder = find.text(backSide);
    expect(backFinder, findsOneWidget);
    // Back side was showed
    assert(_isBackShowed);
  });
}
