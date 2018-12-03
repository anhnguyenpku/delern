import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:package_info/package_info.dart';

import '../../flutter/localization.dart';
import '../../flutter/styles.dart';
import '../../remote/analytics.dart';
import '../../remote/sign_in.dart';
import '../../views/helpers/launch_email.dart';
import '../../views/support_dev/support_development.dart';
import '../helpers/save_updates_dialog.dart';
import '../helpers/send_invite.dart';
import '../helpers/sign_in_widget.dart';

class NavigationDrawer extends StatefulWidget {
  @override
  _NavigationDrawerState createState() => _NavigationDrawerState();
}

class _NavigationDrawerState extends State<NavigationDrawer> {
  String versionCode;

  // TODO(dotdoom): remove when CurrentUserWidget supplies realtime data.
  FirebaseUser _overrideUserForProfile;

  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((packageInfo) => setState(() {
          versionCode = packageInfo.version;
        }));
  }

  @override
  Widget build(BuildContext context) {
    var user = CurrentUserWidget.of(context).user;
    if (_overrideUserForProfile != null &&
        user != null &&
        _overrideUserForProfile.uid == user.uid) {
      // Take override only if it's exactly matching the current user, otherwise
      // switching user / signing out will make UI stale!
      user = _overrideUserForProfile;
    }

    var accountName = user.displayName;
    if (accountName == null || accountName.isEmpty) {
      accountName = AppLocalizations.of(context).anonymous;
    }

    return Drawer(
        child: ListView(
      // Remove any padding from the ListView.
      // https://flutter.io/docs/cookbook/design/drawer
      padding: EdgeInsets.zero,
      children: <Widget>[
        UserAccountsDrawerHeader(
          accountName: Text(accountName),
          accountEmail: user.email == null ? null : Text(user.email),
          currentAccountPicture: CircleAvatar(
            backgroundImage: user.photoUrl == null
                ? const AssetImage('images/anonymous.jpg')
                : NetworkImage(user.photoUrl),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.perm_identity),
          title: Text(user.isAnonymous
              ? AppLocalizations.of(context).navigationDrawerSignIn
              : AppLocalizations.of(context).navigationDrawerSignOut),
          onTap: () async {
            if (user.isAnonymous) {
              _promoteAnonymous(context);
            } else {
              signOut();
              Navigator.pop(context);
            }
          },
        ),
        const Divider(height: 1.0),
        ListTile(
          title: Text(
            AppLocalizations.of(context).navigationDrawerCommunicateGroup,
            style: AppStyles.navigationDrawerGroupText,
          ),
        ),
        ListTile(
          leading: const Icon(Icons.contact_mail),
          title:
              Text(AppLocalizations.of(context).navigationDrawerInviteFriends),
          onTap: () {
            sendInvite(context);
            Navigator.pop(context);
          },
        ),
        ListTile(
          leading: const Icon(Icons.live_help),
          title: Text(AppLocalizations.of(context).navigationDrawerContactUs),
          onTap: () async {
            Navigator.pop(context);
            await launchEmail(context);
          },
        ),
        ListTile(
          leading: const Icon(Icons.developer_board),
          title: Text(
              AppLocalizations.of(context).navigationDrawerSupportDevelopment),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
                context,
                MaterialPageRoute(
                    settings: const RouteSettings(name: '/support'),
                    builder: (context) => SupportDevelopment()));
          },
        ),
        const Divider(
          height: 1.0,
        ),
        AboutListTile(
          icon: const Icon(Icons.perm_device_information),
          child: Text(AppLocalizations.of(context).navigationDrawerAbout),
          applicationIcon: Image.asset('images/ic_launcher.png'),
          applicationVersion: versionCode,
          applicationLegalese: 'GNU General Public License v3.0',
        ),
      ],
    ));
  }

  Future<void> _promoteAnonymous(BuildContext context) async {
    logPromoteAnonymous();
    try {
      await signIn(SignInProvider.google);
    } on PlatformException catch (_) {
      // TODO(ksheremet): Merge data
      logPromoteAnonymousFail();
      var signIn = await showSaveUpdatesDialog(
          context: context,
          changesQuestion: AppLocalizations.of(context).accountExistUserWarning,
          yesAnswer: AppLocalizations.of(context).navigationDrawerSignIn,
          noAnswer: MaterialLocalizations.of(context).cancelButtonLabel);
      if (signIn) {
        signOut();
      } else {
        Navigator.of(context).pop();
      }
      return;
    }

    // TODO(dotdoom): remove once we automatically call AuthStateChanged.
    await CurrentUserWidget.of(context).user.reload();
    // reload() does not change existing instance. We have to get new user again
    // https://github.com/flutter/plugins/pull/533
    _overrideUserForProfile = await FirebaseAuth.instance.currentUser();
    setState(() {});
  }
}
