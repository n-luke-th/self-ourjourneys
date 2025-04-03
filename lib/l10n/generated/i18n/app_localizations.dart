import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_th.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'i18n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('th')
  ];

  /// The conventional newborn programmer greeting
  ///
  /// In en, this message translates to:
  /// **'Hello World!'**
  String get helloWorld;

  /// System Default
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get systemDefault;

  /// Home
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// Memories
  ///
  /// In en, this message translates to:
  /// **'Memories'**
  String get memories;

  /// Settings
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Albums
  ///
  /// In en, this message translates to:
  /// **'Albums'**
  String get albums;

  /// A tooltips for the floating btn
  ///
  /// In en, this message translates to:
  /// **'Add new memory'**
  String get addNewMemory;

  /// Theme mode: light or dark
  ///
  /// In en, this message translates to:
  /// **'Theme mode'**
  String get themeMode;

  /// Capitalize
  ///
  /// In en, this message translates to:
  /// **'Capitalize'**
  String get capitalize;

  /// Language
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Logout confirm text
  ///
  /// In en, this message translates to:
  /// **'LOGOUT'**
  String get logout;

  /// Confirmation title text to the dialog for logout
  ///
  /// In en, this message translates to:
  /// **'Are you sure to logout?'**
  String get logoutConfirmationTitle;

  /// Confirmation details text to the dialog for logout
  ///
  /// In en, this message translates to:
  /// **'You may have to login to the system again.'**
  String get logoutConfirmationMessage;

  /// inform user that new change is now applied.
  ///
  /// In en, this message translates to:
  /// **'New change is applied!'**
  String get newChangeApplied;

  /// inform user that something went wrong.
  ///
  /// In en, this message translates to:
  /// **'Unexpected error occurred.'**
  String get errorOccurred;

  /// indicates that this is under development
  ///
  /// In en, this message translates to:
  /// **'Under development'**
  String get underDevelopment;

  /// Login
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// Reset Password
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPassword;

  /// Email
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// Password
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// New Password
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// Confirm Password
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// A pop up notification to user that he/she is now logged in to the system
  ///
  /// In en, this message translates to:
  /// **'Logged in!'**
  String get loggedIn;

  /// A welcoming pop up notification to user that he/she is now logged in to the system
  ///
  /// In en, this message translates to:
  /// **'Welcome back, '**
  String get welcomeBackWithDisplayNameNext;

  /// A sentence to asking user that his/her email is required to perform the requested operation such as reset accound password.
  ///
  /// In en, this message translates to:
  /// **'Please submit your email in order to process the operation.'**
  String get askForUserEmail;

  /// A sentence inform user that his/her acc password is updated.
  ///
  /// In en, this message translates to:
  /// **'Your account password has been updated!'**
  String get accPasswordIsUpdated;

  /// A sentence inform user that his/her acc email is updated.
  ///
  /// In en, this message translates to:
  /// **'Your account email has been updated!'**
  String get accEmailIsUpdated;

  /// Success!
  ///
  /// In en, this message translates to:
  /// **'Success!'**
  String get success;

  /// Warning!
  ///
  /// In en, this message translates to:
  /// **'Warning!'**
  String get warning;

  /// Failed!
  ///
  /// In en, this message translates to:
  /// **'Failed!'**
  String get failed;

  /// Appearance
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// Reauthenticated!
  ///
  /// In en, this message translates to:
  /// **'Reauthenticated!'**
  String get reauthenticated;

  /// Reauthenticate
  ///
  /// In en, this message translates to:
  /// **'Reauthenticate'**
  String get reauthenticate;

  /// You need to reauthenticate in order to proceed
  ///
  /// In en, this message translates to:
  /// **'You need to reauthenticate in order to proceed'**
  String get youNeedToReauth;

  /// Save
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Version
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// Change password
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// Password reset email has been sent to your mailbox!
  ///
  /// In en, this message translates to:
  /// **'Password reset email has been sent to your mailbox!'**
  String get passwordResentEmailHasBeenSent;

  /// Please checkout the email we have sent you.
  ///
  /// In en, this message translates to:
  /// **'Please checkout the email we have sent you.'**
  String get pleaseCheckoutEmailWeSentYou;

  /// A sentence inform user that his/her acc profile picture is updated.
  ///
  /// In en, this message translates to:
  /// **'Your account profile picture has been updated!'**
  String get accProfilePicIsUpdated;

  /// A sentence inform user that his/her acc profile is updated.
  ///
  /// In en, this message translates to:
  /// **'Your account profile has been updated!'**
  String get accProfileIsUpdated;

  /// A question asking what option user would like to update it.
  ///
  /// In en, this message translates to:
  /// **'What would you like to updated?'**
  String get whatToBeUpdated;

  /// Update email or password
  ///
  /// In en, this message translates to:
  /// **'Update email or password'**
  String get updateEmailOrPassword;

  /// Update email
  ///
  /// In en, this message translates to:
  /// **'Update email'**
  String get updateEmail;

  /// Update password
  ///
  /// In en, this message translates to:
  /// **'Update password'**
  String get updatePassword;

  /// Change email
  ///
  /// In en, this message translates to:
  /// **'Change email'**
  String get changeEmail;

  /// Update profile
  ///
  /// In en, this message translates to:
  /// **'Update profile'**
  String get updateProfile;

  /// Display name
  ///
  /// In en, this message translates to:
  /// **'Display name'**
  String get displayName;

  /// Permission
  ///
  /// In en, this message translates to:
  /// **'Permission'**
  String get permission;

  /// Current Permissions
  ///
  /// In en, this message translates to:
  /// **'Current Permissions'**
  String get currentPermission;

  /// The page you have requested requires you to be an authenticated user.
  ///
  /// In en, this message translates to:
  /// **'The page you have requested requires you to be an authenticated user.'**
  String get requestedPageMustBeAuthenticatedUser;

  /// Go Login now!
  ///
  /// In en, this message translates to:
  /// **'Go Login now!'**
  String get goLoginNow;

  /// Account
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// Accessibility
  ///
  /// In en, this message translates to:
  /// **'Accessibility'**
  String get accessibility;

  /// About
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// Passwords do not match!
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match!'**
  String get passwordNotMatch;

  /// Biometric Protection
  ///
  /// In en, this message translates to:
  /// **'Biometric Protection'**
  String get biometricProtection;

  /// Confirmation title text to the dialog for delete profile pic
  ///
  /// In en, this message translates to:
  /// **'Delete this profile picture?'**
  String get deleteThisProfilePicConfirmationTitle;

  /// Confirmation details text to the dialog for delete profile pic
  ///
  /// In en, this message translates to:
  /// **'This will delete current profile picture immediately'**
  String get deleteThisProfilePicConfirmationMessage;

  /// There is no profile picture to delete.
  ///
  /// In en, this message translates to:
  /// **'There is no profile picture to delete.'**
  String get noProfilePicToDelete;

  /// Continue
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueTxt;

  /// Collections
  ///
  /// In en, this message translates to:
  /// **'Collections'**
  String get collections;

  /// Trip Collections
  ///
  /// In en, this message translates to:
  /// **'Trip Collections'**
  String get tripCollections;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'th'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'th': return AppLocalizationsTh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
