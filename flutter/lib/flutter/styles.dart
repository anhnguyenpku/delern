import 'package:delern_flutter/views/helpers/card_background_specifier.dart';
import 'package:flutter/material.dart';

const kPrimarySwatch = Colors.green;
const kLightPrimaryColor = Color(0xFFC8E6C9);
const kAccentColor = Colors.redAccent;
const kScaffoldBackgroundColor = Colors.white;
final kIconColor = Colors.grey[600];
const kSecondaryTextDeckItemColor = Color(0xff757575);
const kEditDismissibleColor = Color(0xFF2196F3);
const kDeleteDismissibleColor = Color(0xFFFF5252);
const kHyperlinkColor = Colors.blueAccent;
// "Facebook brand blue" color per instructions at
// https://developers.facebook.com/docs/facebook-login/for-devices
const kFacebookBlueColor = Color(0xFF1877F2);
const kDeckItemColor = Colors.white;
const kCurrentDeckTypeColor = Colors.grey;
final kGeneralDeckTypeColor = Colors.grey[200];

const double kMinItemHeight = 48;
const double kMinIconHeight = 24;
const double kMinPrimaryTextSize = 19;
const double kMinSecondaryTextSize = 16;
const double kIconDeckPadding = 15;
const double kItemElevation = 4;
const double kItemListHeightRatio = 0.1;
const double kItemListPaddingRatio = kItemListHeightRatio * 0.08;
const double kCardElevation = 6;

class CardColor {
  final Color frontSideBackground;
  final Color backSideBackground;
  Color get defaultBackground => frontSideBackground;
  const CardColor({
    @required this.frontSideBackground,
    @required this.backSideBackground,
  })  : assert(frontSideBackground != null),
        assert(backSideBackground != null);
}

final Map<Gender, CardColor> cardBackgroundColors = {
  Gender.noGender: const CardColor(
      frontSideBackground: Color(0xFFF5F5F5), backSideBackground: Colors.white),
  Gender.masculine: CardColor(
      frontSideBackground: Colors.blueAccent[100],
      backSideBackground: Colors.blue[200]),
  Gender.feminine: CardColor(
      frontSideBackground: Colors.pinkAccent[100],
      backSideBackground: Colors.pink[200]),
  Gender.neuter: CardColor(
      frontSideBackground: Colors.amberAccent[100],
      backSideBackground: Colors.amber[200]),
};

final Color signInBackgroundColor = Colors.grey[50];

final TextStyle primaryText = TextStyle(
  fontSize: 19,
  fontWeight: FontWeight.w400,
  color: Colors.grey[900],
);

const TextStyle secondaryText = TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.w400,
  color: Color(0xff757575),
);

final TextStyle navigationDrawerGroupText = TextStyle(
  fontWeight: FontWeight.w600,
  color: Colors.grey[600],
);

const TextStyle searchBarText = TextStyle(
  color: Colors.white,
  fontSize: 19,
);

const Color menuItemBackgroundColor = Colors.redAccent;

const TextStyle menuItemText = TextStyle(
  color: Colors.white,
);

const TextStyle editCardPrimaryText = TextStyle(
  fontSize: 19,
  fontWeight: FontWeight.w400,
  color: Colors.black,
);

const TextStyle editCardSecondaryText = TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.w400,
  color: Colors.black,
);

final TextStyle editDeckText = TextStyle(
  fontSize: 24,
  fontWeight: FontWeight.w400,
  color: Colors.grey[900],
);
