import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
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
    Locale('hr')
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'TeReT'**
  String get appName;

  /// No description provided for @welcomeToTeret.
  ///
  /// In en, this message translates to:
  /// **'Welcome to TeReT'**
  String get welcomeToTeret;

  /// No description provided for @loginPlatformDescription.
  ///
  /// In en, this message translates to:
  /// **'A platform that easily connects shippers and carriers.'**
  String get loginPlatformDescription;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get signIn;

  /// No description provided for @noAccountRegister.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? Register'**
  String get noAccountRegister;

  /// No description provided for @enterEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get enterEmail;

  /// No description provided for @enterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address'**
  String get enterValidEmail;

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get enterPassword;

  /// No description provided for @enterValidEmailFirst.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address first.'**
  String get enterValidEmailFirst;

  /// No description provided for @showPassword.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get showPassword;

  /// No description provided for @hidePassword.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get hidePassword;

  /// No description provided for @forgotPasswordQuestion.
  ///
  /// In en, this message translates to:
  /// **'Forgot your password?'**
  String get forgotPasswordQuestion;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Forgotten password'**
  String get forgotPasswordTitle;

  /// No description provided for @forgotPasswordDescription.
  ///
  /// In en, this message translates to:
  /// **'Enter the email address associated with your account. We will send you a link to set a new password.'**
  String get forgotPasswordDescription;

  /// No description provided for @sendResetLink.
  ///
  /// In en, this message translates to:
  /// **'Send link'**
  String get sendResetLink;

  /// No description provided for @passwordResetLinkSent.
  ///
  /// In en, this message translates to:
  /// **'If an account with that email exists, a password reset link has been sent.'**
  String get passwordResetLinkSent;

  /// No description provided for @passwordResetLinkSendError.
  ///
  /// In en, this message translates to:
  /// **'The reset link could not be sent.'**
  String get passwordResetLinkSendError;

  /// No description provided for @accountNotVerified.
  ///
  /// In en, this message translates to:
  /// **'Your account has not been verified. Please verify your email address before logging in.'**
  String get accountNotVerified;

  /// No description provided for @resendVerificationEmail.
  ///
  /// In en, this message translates to:
  /// **'Resend verification email'**
  String get resendVerificationEmail;

  /// No description provided for @verificationEmailResent.
  ///
  /// In en, this message translates to:
  /// **'The verification email has been sent again.'**
  String get verificationEmailResent;

  /// No description provided for @verificationEmailSendError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while sending the verification email.'**
  String get verificationEmailSendError;

  /// No description provided for @loginError.
  ///
  /// In en, this message translates to:
  /// **'Login failed.'**
  String get loginError;

  /// No description provided for @invalidUserRole.
  ///
  /// In en, this message translates to:
  /// **'Invalid user role.'**
  String get invalidUserRole;

  /// No description provided for @emailAndPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Email and password are required.'**
  String get emailAndPasswordRequired;

  /// No description provided for @invalidEmailOrPassword.
  ///
  /// In en, this message translates to:
  /// **'Incorrect email or password.'**
  String get invalidEmailOrPassword;

  /// No description provided for @serverError.
  ///
  /// In en, this message translates to:
  /// **'A server error occurred. Please try again.'**
  String get serverError;

  /// No description provided for @serverConnectionError.
  ///
  /// In en, this message translates to:
  /// **'Server connection error.'**
  String get serverConnectionError;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @carrier.
  ///
  /// In en, this message translates to:
  /// **'Carrier'**
  String get carrier;

  /// No description provided for @sender.
  ///
  /// In en, this message translates to:
  /// **'Sender'**
  String get sender;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Registration'**
  String get register;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logout;

  /// No description provided for @roleSelection.
  ///
  /// In en, this message translates to:
  /// **'Select role'**
  String get roleSelection;

  /// No description provided for @howDoYouWantToUseApp.
  ///
  /// In en, this message translates to:
  /// **'How would you like to use the app?'**
  String get howDoYouWantToUseApp;

  /// No description provided for @transportCustomer.
  ///
  /// In en, this message translates to:
  /// **'Transport customer'**
  String get transportCustomer;

  /// No description provided for @termsAcceptanceRequired.
  ///
  /// In en, this message translates to:
  /// **'You must accept the Terms of Use to register.'**
  String get termsAcceptanceRequired;

  /// No description provided for @registrationSuccessfulVerifyEmail.
  ///
  /// In en, this message translates to:
  /// **'Registration successful. Verify your email address before logging in.'**
  String get registrationSuccessfulVerifyEmail;

  /// No description provided for @registrationError.
  ///
  /// In en, this message translates to:
  /// **'Registration failed.'**
  String get registrationError;

  /// No description provided for @registrationConnectionError.
  ///
  /// In en, this message translates to:
  /// **'Could not connect to the server. Check your internet connection and try again.'**
  String get registrationConnectionError;

  /// No description provided for @enterFullName.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get enterFullName;

  /// No description provided for @enterPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter your mobile phone number'**
  String get enterPhoneNumber;

  /// No description provided for @enterValidPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid mobile phone number'**
  String get enterValidPhoneNumber;

  /// No description provided for @passwordMinimumFourCharacters.
  ///
  /// In en, this message translates to:
  /// **'The password must contain at least 4 characters'**
  String get passwordMinimumFourCharacters;

  /// No description provided for @r1InvoiceNotice.
  ///
  /// In en, this message translates to:
  /// **'If you require an R1 invoice, enter the correct billing information during Stripe Checkout so that we can issue and deliver the invoice.'**
  String get r1InvoiceNotice;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fullName;

  /// No description provided for @companyNameOptional.
  ///
  /// In en, this message translates to:
  /// **'Company / business name (optional)'**
  String get companyNameOptional;

  /// No description provided for @cityOrHeadquarters.
  ///
  /// In en, this message translates to:
  /// **'City / headquarters'**
  String get cityOrHeadquarters;

  /// No description provided for @country.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get country;

  /// No description provided for @mobilePhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get mobilePhoneNumber;

  /// No description provided for @selectCountry.
  ///
  /// In en, this message translates to:
  /// **'Select country'**
  String get selectCountry;

  /// No description provided for @searchCountryOrDialCode.
  ///
  /// In en, this message translates to:
  /// **'Search country or dial code'**
  String get searchCountryOrDialCode;

  /// No description provided for @noCountriesFound.
  ///
  /// In en, this message translates to:
  /// **'No countries found.'**
  String get noCountriesFound;

  /// No description provided for @iAccept.
  ///
  /// In en, this message translates to:
  /// **'I accept the '**
  String get iAccept;

  /// No description provided for @termsOfUse.
  ///
  /// In en, this message translates to:
  /// **'Terms of Use'**
  String get termsOfUse;

  /// No description provided for @teretPlatformSuffix.
  ///
  /// In en, this message translates to:
  /// **' of the TeReT platform.'**
  String get teretPlatformSuffix;

  /// No description provided for @registrationSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Registration successful.'**
  String get registrationSuccessful;

  /// No description provided for @copyVerificationLinkForTesting.
  ///
  /// In en, this message translates to:
  /// **'For testing, copy this link and open it in your browser.'**
  String get copyVerificationLinkForTesting;

  /// No description provided for @afterEmailVerificationLogin.
  ///
  /// In en, this message translates to:
  /// **'You can log in after verifying your email address.'**
  String get afterEmailVerificationLogin;

  /// No description provided for @goToLogin.
  ///
  /// In en, this message translates to:
  /// **'Go to login'**
  String get goToLogin;

  /// No description provided for @registerButton.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get registerButton;

  /// No description provided for @alreadyHaveAccountLogin.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Log in'**
  String get alreadyHaveAccountLogin;

  /// No description provided for @exitAppTitle.
  ///
  /// In en, this message translates to:
  /// **'Exit application'**
  String get exitAppTitle;

  /// No description provided for @exitAppQuestion.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to exit the application?'**
  String get exitAppQuestion;

  /// No description provided for @exit.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get exit;

  /// No description provided for @info.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get info;

  /// No description provided for @shipmentList.
  ///
  /// In en, this message translates to:
  /// **'Shipment list'**
  String get shipmentList;

  /// No description provided for @myOffers.
  ///
  /// In en, this message translates to:
  /// **'My offers'**
  String get myOffers;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @notificationsDisabled.
  ///
  /// In en, this message translates to:
  /// **'Notifications are disabled'**
  String get notificationsDisabled;

  /// No description provided for @notificationsWarningDescription.
  ///
  /// In en, this message translates to:
  /// **'Enable notifications to receive new shipments, offer updates, and other important auction notifications on time.'**
  String get notificationsWarningDescription;

  /// No description provided for @enableNotifications.
  ///
  /// In en, this message translates to:
  /// **'Enable notifications'**
  String get enableNotifications;

  /// No description provided for @splashTagline.
  ///
  /// In en, this message translates to:
  /// **'Load Radar'**
  String get splashTagline;

  /// No description provided for @senderRoleDescription.
  ///
  /// In en, this message translates to:
  /// **'Publish a shipment and receive offers from carriers'**
  String get senderRoleDescription;

  /// No description provided for @carrierRoleDescription.
  ///
  /// In en, this message translates to:
  /// **'Browse shipments and submit your offer'**
  String get carrierRoleDescription;

  /// No description provided for @selectRoleInfo.
  ///
  /// In en, this message translates to:
  /// **'Choose a role and continue to login or registration.'**
  String get selectRoleInfo;

  /// No description provided for @newBadge.
  ///
  /// In en, this message translates to:
  /// **'NEW'**
  String get newBadge;

  /// No description provided for @myShipments.
  ///
  /// In en, this message translates to:
  /// **'My shipments'**
  String get myShipments;

  /// No description provided for @publishShipment.
  ///
  /// In en, this message translates to:
  /// **'Publish shipment'**
  String get publishShipment;

  /// No description provided for @shipmentPublishDescription.
  ///
  /// In en, this message translates to:
  /// **'Enter shipment details so carriers can submit offers.'**
  String get shipmentPublishDescription;

  /// No description provided for @basicInformation.
  ///
  /// In en, this message translates to:
  /// **'Basic information'**
  String get basicInformation;

  /// No description provided for @route.
  ///
  /// In en, this message translates to:
  /// **'Route'**
  String get route;

  /// No description provided for @timeAndQuantity.
  ///
  /// In en, this message translates to:
  /// **'Time and quantity'**
  String get timeAndQuantity;

  /// No description provided for @contact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get contact;

  /// No description provided for @shipmentImages.
  ///
  /// In en, this message translates to:
  /// **'Shipment images'**
  String get shipmentImages;

  /// No description provided for @additionalDetails.
  ///
  /// In en, this message translates to:
  /// **'Additional details (optional)'**
  String get additionalDetails;

  /// No description provided for @shipmentName.
  ///
  /// In en, this message translates to:
  /// **'Shipment name'**
  String get shipmentName;

  /// No description provided for @shortShipmentDescription.
  ///
  /// In en, this message translates to:
  /// **'Short shipment description'**
  String get shortShipmentDescription;

  /// No description provided for @enterShipmentDescription.
  ///
  /// In en, this message translates to:
  /// **'Enter the shipment description.'**
  String get enterShipmentDescription;

  /// No description provided for @shipmentDescriptionNoContactInfo.
  ///
  /// In en, this message translates to:
  /// **'The shipment description must not contain contact information.'**
  String get shipmentDescriptionNoContactInfo;

  /// No description provided for @loadingCountry.
  ///
  /// In en, this message translates to:
  /// **'Loading country'**
  String get loadingCountry;

  /// No description provided for @loadingCity.
  ///
  /// In en, this message translates to:
  /// **'Loading place'**
  String get loadingCity;

  /// No description provided for @loadingAddress.
  ///
  /// In en, this message translates to:
  /// **'Loading address'**
  String get loadingAddress;

  /// No description provided for @unloadingCountry.
  ///
  /// In en, this message translates to:
  /// **'Unloading country'**
  String get unloadingCountry;

  /// No description provided for @unloadingCity.
  ///
  /// In en, this message translates to:
  /// **'Unloading place'**
  String get unloadingCity;

  /// No description provided for @unloadingAddress.
  ///
  /// In en, this message translates to:
  /// **'Unloading address'**
  String get unloadingAddress;

  /// No description provided for @auctionDuration.
  ///
  /// In en, this message translates to:
  /// **'Auction duration'**
  String get auctionDuration;

  /// No description provided for @contactHiddenUntilAccepted.
  ///
  /// In en, this message translates to:
  /// **'Contact details will not be visible to the carrier until you accept the offer.'**
  String get contactHiddenUntilAccepted;

  /// No description provided for @loadingDeadlineAfterAuction.
  ///
  /// In en, this message translates to:
  /// **'Loading deadline after the auction ends'**
  String get loadingDeadlineAfterAuction;

  /// No description provided for @approxWeight.
  ///
  /// In en, this message translates to:
  /// **'Approx. weight (kg/lb)'**
  String get approxWeight;

  /// No description provided for @palletCount.
  ///
  /// In en, this message translates to:
  /// **'Number of pallets'**
  String get palletCount;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get phoneNumber;

  /// No description provided for @oneHour.
  ///
  /// In en, this message translates to:
  /// **'1 hour'**
  String get oneHour;

  /// No description provided for @twoHours.
  ///
  /// In en, this message translates to:
  /// **'2 hours'**
  String get twoHours;

  /// No description provided for @sixHours.
  ///
  /// In en, this message translates to:
  /// **'6 hours'**
  String get sixHours;

  /// No description provided for @twelveHours.
  ///
  /// In en, this message translates to:
  /// **'12 hours'**
  String get twelveHours;

  /// No description provided for @twentyFourHours.
  ///
  /// In en, this message translates to:
  /// **'24 hours'**
  String get twentyFourHours;

  /// No description provided for @fortyEightHours.
  ///
  /// In en, this message translates to:
  /// **'48 hours'**
  String get fortyEightHours;

  /// No description provided for @seventyTwoHours.
  ///
  /// In en, this message translates to:
  /// **'72 hours'**
  String get seventyTwoHours;

  /// No description provided for @byAgreement.
  ///
  /// In en, this message translates to:
  /// **'By agreement'**
  String get byAgreement;

  /// No description provided for @loadingLocationType.
  ///
  /// In en, this message translates to:
  /// **'Loading location type'**
  String get loadingLocationType;

  /// No description provided for @building.
  ///
  /// In en, this message translates to:
  /// **'Building'**
  String get building;

  /// No description provided for @productionFacility.
  ///
  /// In en, this message translates to:
  /// **'Production facility'**
  String get productionFacility;

  /// No description provided for @warehouse.
  ///
  /// In en, this message translates to:
  /// **'Warehouse'**
  String get warehouse;

  /// No description provided for @house.
  ///
  /// In en, this message translates to:
  /// **'House'**
  String get house;

  /// No description provided for @constructionSite.
  ///
  /// In en, this message translates to:
  /// **'Construction site'**
  String get constructionSite;

  /// No description provided for @businessPremises.
  ///
  /// In en, this message translates to:
  /// **'Business premises'**
  String get businessPremises;

  /// No description provided for @unloadingLocationType.
  ///
  /// In en, this message translates to:
  /// **'Unloading location type'**
  String get unloadingLocationType;

  /// No description provided for @loadingMethod.
  ///
  /// In en, this message translates to:
  /// **'Loading method'**
  String get loadingMethod;

  /// No description provided for @manualLoading.
  ///
  /// In en, this message translates to:
  /// **'Manual loading'**
  String get manualLoading;

  /// No description provided for @machineLoading.
  ///
  /// In en, this message translates to:
  /// **'Machine loading'**
  String get machineLoading;

  /// No description provided for @length.
  ///
  /// In en, this message translates to:
  /// **'Length'**
  String get length;

  /// No description provided for @width.
  ///
  /// In en, this message translates to:
  /// **'Width'**
  String get width;

  /// No description provided for @height.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get height;

  /// No description provided for @truckAccess.
  ///
  /// In en, this message translates to:
  /// **'Truck access'**
  String get truckAccess;

  /// No description provided for @driverHelp.
  ///
  /// In en, this message translates to:
  /// **'Driver assistance'**
  String get driverHelp;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @selectedImages.
  ///
  /// In en, this message translates to:
  /// **'Selected images: {count}/{max}'**
  String selectedImages(int count, int max);

  /// No description provided for @noImagesSelected.
  ///
  /// In en, this message translates to:
  /// **'No images selected.'**
  String get noImagesSelected;

  /// No description provided for @noShipmentsYet.
  ///
  /// In en, this message translates to:
  /// **'You currently have no shipments.'**
  String get noShipmentsYet;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @transportAgreed.
  ///
  /// In en, this message translates to:
  /// **'Transport agreed'**
  String get transportAgreed;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @auctionFinished.
  ///
  /// In en, this message translates to:
  /// **'Auction finished'**
  String get auctionFinished;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @auction.
  ///
  /// In en, this message translates to:
  /// **'Auction'**
  String get auction;

  /// No description provided for @offers.
  ///
  /// In en, this message translates to:
  /// **'Offers'**
  String get offers;

  /// No description provided for @views.
  ///
  /// In en, this message translates to:
  /// **'Views'**
  String get views;

  /// No description provided for @lowestOffer.
  ///
  /// In en, this message translates to:
  /// **'Lowest offer'**
  String get lowestOffer;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @auctionProgress.
  ///
  /// In en, this message translates to:
  /// **'Auction progress'**
  String get auctionProgress;

  /// No description provided for @removeFromHistory.
  ///
  /// In en, this message translates to:
  /// **'Remove from history'**
  String get removeFromHistory;

  /// No description provided for @repost.
  ///
  /// In en, this message translates to:
  /// **'Repost'**
  String get repost;

  /// No description provided for @paymentSuccessfulContactUnlocked.
  ///
  /// In en, this message translates to:
  /// **'Payment successful. Contact details are now unlocked.'**
  String get paymentSuccessfulContactUnlocked;

  /// No description provided for @errorFetchingShipmentDetails.
  ///
  /// In en, this message translates to:
  /// **'Error loading shipment details.'**
  String get errorFetchingShipmentDetails;

  /// No description provided for @cannotOpenStripePayment.
  ///
  /// In en, this message translates to:
  /// **'Unable to open Stripe Checkout.'**
  String get cannotOpenStripePayment;

  /// No description provided for @commissionRecorded.
  ///
  /// In en, this message translates to:
  /// **'The commission has been recorded.'**
  String get commissionRecorded;

  /// No description provided for @areYouSure.
  ///
  /// In en, this message translates to:
  /// **'Are you sure?'**
  String get areYouSure;

  /// No description provided for @confirmDeliveryExplanation.
  ///
  /// In en, this message translates to:
  /// **'By confirming, you mark the transport as completed.'**
  String get confirmDeliveryExplanation;

  /// No description provided for @transportCompleted.
  ///
  /// In en, this message translates to:
  /// **'Transport completed'**
  String get transportCompleted;

  /// No description provided for @transportMarkedCompleted.
  ///
  /// In en, this message translates to:
  /// **'The transport has been marked as completed.'**
  String get transportMarkedCompleted;

  /// No description provided for @carrierAccusative.
  ///
  /// In en, this message translates to:
  /// **'carrier'**
  String get carrierAccusative;

  /// No description provided for @cannotOpenPhoneApp.
  ///
  /// In en, this message translates to:
  /// **'Unable to open the phone app.'**
  String get cannotOpenPhoneApp;

  /// No description provided for @acceptedOffer.
  ///
  /// In en, this message translates to:
  /// **'Accepted offer'**
  String get acceptedOffer;

  /// No description provided for @senderUppercase.
  ///
  /// In en, this message translates to:
  /// **'SENDER'**
  String get senderUppercase;

  /// No description provided for @noRatings.
  ///
  /// In en, this message translates to:
  /// **'No ratings'**
  String get noRatings;

  /// No description provided for @confirming.
  ///
  /// In en, this message translates to:
  /// **'Confirming...'**
  String get confirming;

  /// No description provided for @carrierSelected.
  ///
  /// In en, this message translates to:
  /// **'You selected a carrier.'**
  String get carrierSelected;

  /// No description provided for @offerAccepted.
  ///
  /// In en, this message translates to:
  /// **'The offer has been accepted.'**
  String get offerAccepted;

  /// No description provided for @carrierWillContactSoon.
  ///
  /// In en, this message translates to:
  /// **'The carrier will contact you soon.'**
  String get carrierWillContactSoon;

  /// No description provided for @waitingForCarrierConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Waiting for the carrier\'s confirmation.'**
  String get waitingForCarrierConfirmation;

  /// No description provided for @offerAcceptedShort.
  ///
  /// In en, this message translates to:
  /// **'Offer accepted.'**
  String get offerAcceptedShort;

  /// No description provided for @platformFeeExplanation.
  ///
  /// In en, this message translates to:
  /// **'The job is yours.\n\nTo unlock the contact details, you need to pay the platform fee through Stripe Checkout.\n\nThe fee is 7% of the agreed transport price. For transports worth up to €100.00, fee is €5.00.'**
  String get platformFeeExplanation;

  /// No description provided for @continueToStripeCheckout.
  ///
  /// In en, this message translates to:
  /// **'Continue to Stripe Checkout'**
  String get continueToStripeCheckout;

  /// No description provided for @otherCarrierWonMessage.
  ///
  /// In en, this message translates to:
  /// **'Unfortunately, another carrier got this job. Thank you for taking part in the auction.'**
  String get otherCarrierWonMessage;

  /// No description provided for @shipmentNotFound.
  ///
  /// In en, this message translates to:
  /// **'Shipment not found.'**
  String get shipmentNotFound;

  /// No description provided for @senderAccusative.
  ///
  /// In en, this message translates to:
  /// **'sender'**
  String get senderAccusative;

  /// No description provided for @statusOtherCarrierSelected.
  ///
  /// In en, this message translates to:
  /// **'Status: Another carrier selected'**
  String get statusOtherCarrierSelected;

  /// No description provided for @otherCarrierSelectedMessage.
  ///
  /// In en, this message translates to:
  /// **'Unfortunately, another carrier was selected for this transport. Thank you for taking part in the auction.'**
  String get otherCarrierSelectedMessage;

  /// No description provided for @statusAuctionFinished.
  ///
  /// In en, this message translates to:
  /// **'Status: Auction finished'**
  String get statusAuctionFinished;

  /// No description provided for @statusOfferAcceptedByYou.
  ///
  /// In en, this message translates to:
  /// **'Status: You accepted an offer'**
  String get statusOfferAcceptedByYou;

  /// No description provided for @loadingPlace.
  ///
  /// In en, this message translates to:
  /// **'Loading place'**
  String get loadingPlace;

  /// No description provided for @unloadingPlace.
  ///
  /// In en, this message translates to:
  /// **'Unloading place'**
  String get unloadingPlace;

  /// No description provided for @weight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weight;

  /// No description provided for @numberOfPallets.
  ///
  /// In en, this message translates to:
  /// **'Number of pallets'**
  String get numberOfPallets;

  /// No description provided for @loadingFloor.
  ///
  /// In en, this message translates to:
  /// **'Loading floor'**
  String get loadingFloor;

  /// No description provided for @unloadingFloor.
  ///
  /// In en, this message translates to:
  /// **'Unloading floor'**
  String get unloadingFloor;

  /// No description provided for @loadingLift.
  ///
  /// In en, this message translates to:
  /// **'Lift at loading'**
  String get loadingLift;

  /// No description provided for @unloadingLift.
  ///
  /// In en, this message translates to:
  /// **'Lift at unloading'**
  String get unloadingLift;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @driverHelpNeeded.
  ///
  /// In en, this message translates to:
  /// **'Driver assistance needed'**
  String get driverHelpNeeded;

  /// No description provided for @acceptedPrice.
  ///
  /// In en, this message translates to:
  /// **'Accepted price'**
  String get acceptedPrice;

  /// No description provided for @commission.
  ///
  /// In en, this message translates to:
  /// **'Commission'**
  String get commission;

  /// No description provided for @numberOfOffers.
  ///
  /// In en, this message translates to:
  /// **'Number of offers'**
  String get numberOfOffers;

  /// No description provided for @listingViews.
  ///
  /// In en, this message translates to:
  /// **'Listing views'**
  String get listingViews;

  /// No description provided for @contactPhone.
  ///
  /// In en, this message translates to:
  /// **'Contact phone'**
  String get contactPhone;

  /// No description provided for @callSender.
  ///
  /// In en, this message translates to:
  /// **'Call sender'**
  String get callSender;

  /// No description provided for @sendOffer.
  ///
  /// In en, this message translates to:
  /// **'Send offer'**
  String get sendOffer;

  /// No description provided for @teretDelivered.
  ///
  /// In en, this message translates to:
  /// **'TeReT delivered'**
  String get teretDelivered;

  /// No description provided for @thankYouForRating.
  ///
  /// In en, this message translates to:
  /// **'Thank you for your rating.'**
  String get thankYouForRating;

  /// No description provided for @ratingBuildsTrust.
  ///
  /// In en, this message translates to:
  /// **'Your rating helps build trust on the platform.'**
  String get ratingBuildsTrust;

  /// No description provided for @otherCarrierSelectedForShipment.
  ///
  /// In en, this message translates to:
  /// **'Another carrier was selected for this shipment.'**
  String get otherCarrierSelectedForShipment;

  /// No description provided for @offersNoLongerAllowed.
  ///
  /// In en, this message translates to:
  /// **'Offers can no longer be submitted for this shipment.'**
  String get offersNoLongerAllowed;

  /// No description provided for @shipmentDetails.
  ///
  /// In en, this message translates to:
  /// **'Shipment details'**
  String get shipmentDetails;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @ratingSummary.
  ///
  /// In en, this message translates to:
  /// **'⭐ {rating} ({count} ratings)'**
  String ratingSummary(String rating, String count);

  /// No description provided for @alreadyRated.
  ///
  /// In en, this message translates to:
  /// **'You have already rated the {user}.'**
  String alreadyRated(String user);

  /// No description provided for @rateUser.
  ///
  /// In en, this message translates to:
  /// **'Rate {user}'**
  String rateUser(String user);

  /// No description provided for @agreedTransportPrice.
  ///
  /// In en, this message translates to:
  /// **'Agreed transport price: {amount}'**
  String agreedTransportPrice(String amount);

  /// No description provided for @feeAmount.
  ///
  /// In en, this message translates to:
  /// **'Fee amount: {amount}'**
  String feeAmount(String amount);

  /// No description provided for @timeRemaining.
  ///
  /// In en, this message translates to:
  /// **'{hours}h {minutes}min remaining'**
  String timeRemaining(int hours, int minutes);

  /// No description provided for @statusLabel.
  ///
  /// In en, this message translates to:
  /// **'Status: {status}'**
  String statusLabel(String status);

  /// No description provided for @sessionExpiredLoginAgain.
  ///
  /// In en, this message translates to:
  /// **'Your session has expired. Please log in again.'**
  String get sessionExpiredLoginAgain;

  /// No description provided for @errorLoadingOffers.
  ///
  /// In en, this message translates to:
  /// **'Error loading offers.'**
  String get errorLoadingOffers;

  /// No description provided for @acceptOfferConfirmationText.
  ///
  /// In en, this message translates to:
  /// **'By accepting this offer, you finalize the agreement and select this carrier.'**
  String get acceptOfferConfirmationText;

  /// No description provided for @acceptOffer.
  ///
  /// In en, this message translates to:
  /// **'Accept offer'**
  String get acceptOffer;

  /// No description provided for @invalidOfferId.
  ///
  /// In en, this message translates to:
  /// **'Invalid offer ID.'**
  String get invalidOfferId;

  /// No description provided for @offerAcceptedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'The offer was accepted successfully.'**
  String get offerAcceptedSuccessfully;

  /// No description provided for @acceptOfferFailed.
  ///
  /// In en, this message translates to:
  /// **'The offer could not be accepted.'**
  String get acceptOfferFailed;

  /// No description provided for @accepted.
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get accepted;

  /// No description provided for @outbid.
  ///
  /// In en, this message translates to:
  /// **'Outbid'**
  String get outbid;

  /// No description provided for @rejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get rejected;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @activeFeminine.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get activeFeminine;

  /// No description provided for @carrierUppercase.
  ///
  /// In en, this message translates to:
  /// **'CARRIER'**
  String get carrierUppercase;

  /// No description provided for @carrierIdNotFound.
  ///
  /// In en, this message translates to:
  /// **'The carrier ID for this offer could not be found.'**
  String get carrierIdNotFound;

  /// No description provided for @offerWithPrice.
  ///
  /// In en, this message translates to:
  /// **'Offer: {price}'**
  String offerWithPrice(String price);

  /// No description provided for @thisOfferAccepted.
  ///
  /// In en, this message translates to:
  /// **'This offer has been accepted'**
  String get thisOfferAccepted;

  /// No description provided for @thisOfferOutbid.
  ///
  /// In en, this message translates to:
  /// **'This offer was outbid'**
  String get thisOfferOutbid;

  /// No description provided for @shipmentOffers.
  ///
  /// In en, this message translates to:
  /// **'Shipment offers'**
  String get shipmentOffers;

  /// No description provided for @noOffersForShipment.
  ///
  /// In en, this message translates to:
  /// **'There are no offers for this shipment yet.'**
  String get noOffersForShipment;

  /// No description provided for @offerAlreadyAcceptedShipmentClosed.
  ///
  /// In en, this message translates to:
  /// **'An offer has already been accepted and the shipment is closed.'**
  String get offerAlreadyAcceptedShipmentClosed;

  /// No description provided for @bidHistoryNotLoggedIn.
  ///
  /// In en, this message translates to:
  /// **'You are not signed in. Please sign in again.'**
  String get bidHistoryNotLoggedIn;

  /// No description provided for @bidHistorySessionExpired.
  ///
  /// In en, this message translates to:
  /// **'Your session has expired. Please sign in again.'**
  String get bidHistorySessionExpired;

  /// No description provided for @bidHistoryFetchError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while loading the auction progress.'**
  String get bidHistoryFetchError;

  /// No description provided for @bidHistoryConnectionError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred. Check the connection to the backend.'**
  String get bidHistoryConnectionError;

  /// No description provided for @bidHistoryStatusActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get bidHistoryStatusActive;

  /// No description provided for @bidHistoryStatusAccepted.
  ///
  /// In en, this message translates to:
  /// **'Accepted offer'**
  String get bidHistoryStatusAccepted;

  /// No description provided for @bidHistoryStatusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get bidHistoryStatusCompleted;

  /// No description provided for @bidHistoryYourOffer.
  ///
  /// In en, this message translates to:
  /// **'Your offer'**
  String get bidHistoryYourOffer;

  /// No description provided for @bidHistoryCarrier.
  ///
  /// In en, this message translates to:
  /// **'Carrier'**
  String get bidHistoryCarrier;

  /// No description provided for @bidHistoryRatings.
  ///
  /// In en, this message translates to:
  /// **'⭐ {averageRating} ({ratingsCount} ratings)'**
  String bidHistoryRatings(String averageRating, String ratingsCount);

  /// No description provided for @bidHistorySummary.
  ///
  /// In en, this message translates to:
  /// **'Auction summary'**
  String get bidHistorySummary;

  /// No description provided for @bidHistoryCurrentLowestOffer.
  ///
  /// In en, this message translates to:
  /// **'Current lowest offer'**
  String get bidHistoryCurrentLowestOffer;

  /// No description provided for @bidHistoryOffersCount.
  ///
  /// In en, this message translates to:
  /// **'Number of offers'**
  String get bidHistoryOffersCount;

  /// No description provided for @bidHistoryShipmentStatus.
  ///
  /// In en, this message translates to:
  /// **'Shipment status'**
  String get bidHistoryShipmentStatus;

  /// No description provided for @bidHistoryBadgeAccepted.
  ///
  /// In en, this message translates to:
  /// **'ACCEPTED'**
  String get bidHistoryBadgeAccepted;

  /// No description provided for @bidHistoryBadgeRejected.
  ///
  /// In en, this message translates to:
  /// **'REJECTED'**
  String get bidHistoryBadgeRejected;

  /// No description provided for @bidHistoryBadgeLowest.
  ///
  /// In en, this message translates to:
  /// **'LOWEST'**
  String get bidHistoryBadgeLowest;

  /// No description provided for @bidHistoryBadgeYours.
  ///
  /// In en, this message translates to:
  /// **'YOURS'**
  String get bidHistoryBadgeYours;

  /// No description provided for @bidHistoryNoOffers.
  ///
  /// In en, this message translates to:
  /// **'There are no offers for this shipment yet.'**
  String get bidHistoryNoOffers;

  /// No description provided for @bidHistoryAuctionProgress.
  ///
  /// In en, this message translates to:
  /// **'Auction progress'**
  String get bidHistoryAuctionProgress;

  /// No description provided for @bidHistoryRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get bidHistoryRefresh;

  /// No description provided for @bidHistoryStatusAuctionFinished.
  ///
  /// In en, this message translates to:
  /// **'Auction finished'**
  String get bidHistoryStatusAuctionFinished;

  /// No description provided for @acceptOfferConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to accept this offer?'**
  String get acceptOfferConfirmation;

  /// No description provided for @acceptOfferButton.
  ///
  /// In en, this message translates to:
  /// **'ACCEPT OFFER'**
  String get acceptOfferButton;

  /// No description provided for @acceptOfferWarning.
  ///
  /// In en, this message translates to:
  /// **'After accepting the offer, the shipment will be assigned to this carrier and all other offers will be closed.'**
  String get acceptOfferWarning;

  /// No description provided for @offer.
  ///
  /// In en, this message translates to:
  /// **'Offer'**
  String get offer;

  /// No description provided for @offerTime.
  ///
  /// In en, this message translates to:
  /// **'Offer time'**
  String get offerTime;

  /// No description provided for @note.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get note;

  /// No description provided for @notSpecified.
  ///
  /// In en, this message translates to:
  /// **'Not specified'**
  String get notSpecified;

  /// No description provided for @offerAcceptError.
  ///
  /// In en, this message translates to:
  /// **'Error accepting the offer'**
  String get offerAcceptError;

  /// No description provided for @generalError.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String generalError(String error);

  /// No description provided for @offerDateTime.
  ///
  /// In en, this message translates to:
  /// **'{day}.{month}.{year} at {hour}:{minute}'**
  String offerDateTime(String day, String month, String year, String hour, String minute);

  /// No description provided for @hoursShort.
  ///
  /// In en, this message translates to:
  /// **'hours'**
  String get hoursShort;

  /// No description provided for @assignedShipmentTitle.
  ///
  /// In en, this message translates to:
  /// **'Assigned shipment'**
  String get assignedShipmentTitle;

  /// No description provided for @assignedSessionExpired.
  ///
  /// In en, this message translates to:
  /// **'Your session has expired. Please sign in again.'**
  String get assignedSessionExpired;

  /// No description provided for @assignedShipmentLoadError.
  ///
  /// In en, this message translates to:
  /// **'Error loading the shipment.'**
  String get assignedShipmentLoadError;

  /// No description provided for @assignedErrorPrefix.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get assignedErrorPrefix;

  /// No description provided for @assignedAreYouSure.
  ///
  /// In en, this message translates to:
  /// **'Are you sure?'**
  String get assignedAreYouSure;

  /// No description provided for @assignedDeliveryConfirmationText.
  ///
  /// In en, this message translates to:
  /// **'By confirming, you mark the transport as completed.'**
  String get assignedDeliveryConfirmationText;

  /// No description provided for @assignedCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get assignedCancel;

  /// No description provided for @assignedTransportCompleted.
  ///
  /// In en, this message translates to:
  /// **'Transport completed'**
  String get assignedTransportCompleted;

  /// No description provided for @assignedMarkedAsCompleted.
  ///
  /// In en, this message translates to:
  /// **'The transport has been marked as completed.'**
  String get assignedMarkedAsCompleted;

  /// No description provided for @assignedServerConnectionError.
  ///
  /// In en, this message translates to:
  /// **'Server connection error.'**
  String get assignedServerConnectionError;

  /// No description provided for @assignedNotSpecified.
  ///
  /// In en, this message translates to:
  /// **'Not specified'**
  String get assignedNotSpecified;

  /// No description provided for @assignedYes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get assignedYes;

  /// No description provided for @assignedNo.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get assignedNo;

  /// No description provided for @assignedCarrier.
  ///
  /// In en, this message translates to:
  /// **'Assigned carrier'**
  String get assignedCarrier;

  /// No description provided for @assignedManual.
  ///
  /// In en, this message translates to:
  /// **'Manual'**
  String get assignedManual;

  /// No description provided for @assignedMachine.
  ///
  /// In en, this message translates to:
  /// **'Machine'**
  String get assignedMachine;

  /// No description provided for @assignedHouse.
  ///
  /// In en, this message translates to:
  /// **'House'**
  String get assignedHouse;

  /// No description provided for @assignedBuilding.
  ///
  /// In en, this message translates to:
  /// **'Building'**
  String get assignedBuilding;

  /// No description provided for @assignedWarehouse.
  ///
  /// In en, this message translates to:
  /// **'Warehouse'**
  String get assignedWarehouse;

  /// No description provided for @assignedProductionFacility.
  ///
  /// In en, this message translates to:
  /// **'Production facility'**
  String get assignedProductionFacility;

  /// No description provided for @assignedConstructionSite.
  ///
  /// In en, this message translates to:
  /// **'Construction site'**
  String get assignedConstructionSite;

  /// No description provided for @assignedBusinessPremises.
  ///
  /// In en, this message translates to:
  /// **'Business premises'**
  String get assignedBusinessPremises;

  /// No description provided for @assignedConfirming.
  ///
  /// In en, this message translates to:
  /// **'Confirming...'**
  String get assignedConfirming;

  /// No description provided for @assignedTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get assignedTryAgain;

  /// No description provided for @assignedGoToLogin.
  ///
  /// In en, this message translates to:
  /// **'Go to login'**
  String get assignedGoToLogin;

  /// No description provided for @assignedShipmentNotFound.
  ///
  /// In en, this message translates to:
  /// **'Shipment not found.'**
  String get assignedShipmentNotFound;

  /// No description provided for @assignedShipmentAssigned.
  ///
  /// In en, this message translates to:
  /// **'Shipment assigned'**
  String get assignedShipmentAssigned;

  /// No description provided for @assignedCarrierDetails.
  ///
  /// In en, this message translates to:
  /// **'Carrier details'**
  String get assignedCarrierDetails;

  /// No description provided for @assignedEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get assignedEmail;

  /// No description provided for @assignedPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get assignedPhone;

  /// No description provided for @assignedAcceptedPrice.
  ///
  /// In en, this message translates to:
  /// **'Accepted price'**
  String get assignedAcceptedPrice;

  /// No description provided for @assignedStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get assignedStatus;

  /// No description provided for @assignedPhoneNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Phone number is not available yet'**
  String get assignedPhoneNotAvailable;

  /// No description provided for @assignedCarrierDetailsUnavailable.
  ///
  /// In en, this message translates to:
  /// **'The offer has been accepted, but the carrier details are currently unavailable.'**
  String get assignedCarrierDetailsUnavailable;

  /// No description provided for @assignedBasicShipmentDetails.
  ///
  /// In en, this message translates to:
  /// **'Basic shipment details'**
  String get assignedBasicShipmentDetails;

  /// No description provided for @assignedShipmentName.
  ///
  /// In en, this message translates to:
  /// **'Shipment name'**
  String get assignedShipmentName;

  /// No description provided for @assignedDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get assignedDescription;

  /// No description provided for @assignedLoadingDate.
  ///
  /// In en, this message translates to:
  /// **'Loading date'**
  String get assignedLoadingDate;

  /// No description provided for @assignedLoadingPlace.
  ///
  /// In en, this message translates to:
  /// **'Loading place'**
  String get assignedLoadingPlace;

  /// No description provided for @assignedLoadingAddress.
  ///
  /// In en, this message translates to:
  /// **'Loading address'**
  String get assignedLoadingAddress;

  /// No description provided for @assignedUnloadingPlace.
  ///
  /// In en, this message translates to:
  /// **'Unloading place'**
  String get assignedUnloadingPlace;

  /// No description provided for @assignedUnloadingAddress.
  ///
  /// In en, this message translates to:
  /// **'Unloading address'**
  String get assignedUnloadingAddress;

  /// No description provided for @assignedDimensionsAndLogistics.
  ///
  /// In en, this message translates to:
  /// **'Dimensions and logistics'**
  String get assignedDimensionsAndLogistics;

  /// No description provided for @assignedWeight.
  ///
  /// In en, this message translates to:
  /// **'Weight (kg/lb)'**
  String get assignedWeight;

  /// No description provided for @assignedLength.
  ///
  /// In en, this message translates to:
  /// **'Length (cm/in)'**
  String get assignedLength;

  /// No description provided for @assignedWidth.
  ///
  /// In en, this message translates to:
  /// **'Width (cm/in)'**
  String get assignedWidth;

  /// No description provided for @assignedHeight.
  ///
  /// In en, this message translates to:
  /// **'Height (cm/in)'**
  String get assignedHeight;

  /// No description provided for @assignedLoadingMethod.
  ///
  /// In en, this message translates to:
  /// **'Loading method'**
  String get assignedLoadingMethod;

  /// No description provided for @assignedTruckAccess.
  ///
  /// In en, this message translates to:
  /// **'Truck access'**
  String get assignedTruckAccess;

  /// No description provided for @assignedLoadingLocationType.
  ///
  /// In en, this message translates to:
  /// **'Loading location type'**
  String get assignedLoadingLocationType;

  /// No description provided for @assignedLoadingFloor.
  ///
  /// In en, this message translates to:
  /// **'Loading floor'**
  String get assignedLoadingFloor;

  /// No description provided for @assignedLoadingElevator.
  ///
  /// In en, this message translates to:
  /// **'Elevator at loading'**
  String get assignedLoadingElevator;

  /// No description provided for @assignedDriverHelp.
  ///
  /// In en, this message translates to:
  /// **'Driver assistance required'**
  String get assignedDriverHelp;

  /// No description provided for @assignedCustoms.
  ///
  /// In en, this message translates to:
  /// **'Customs'**
  String get assignedCustoms;

  /// No description provided for @assignedShipmentImages.
  ///
  /// In en, this message translates to:
  /// **'Shipment images'**
  String get assignedShipmentImages;

  /// No description provided for @availableNotLoggedIn.
  ///
  /// In en, this message translates to:
  /// **'You are not signed in. Please sign in again.'**
  String get availableNotLoggedIn;

  /// No description provided for @availableFetchError.
  ///
  /// In en, this message translates to:
  /// **'Error fetching shipments.'**
  String get availableFetchError;

  /// No description provided for @availableServerConnectionError.
  ///
  /// In en, this message translates to:
  /// **'Server connection error'**
  String get availableServerConnectionError;

  /// No description provided for @availableShipmentFallback.
  ///
  /// In en, this message translates to:
  /// **'Shipment'**
  String get availableShipmentFallback;

  /// No description provided for @availableNew.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get availableNew;

  /// No description provided for @availableClosed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get availableClosed;

  /// No description provided for @availableWeight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get availableWeight;

  /// No description provided for @availablePallets.
  ///
  /// In en, this message translates to:
  /// **'Pallets'**
  String get availablePallets;

  /// No description provided for @availableLoadingDeadline.
  ///
  /// In en, this message translates to:
  /// **'Loading deadline'**
  String get availableLoadingDeadline;

  /// No description provided for @availableOpenDetails.
  ///
  /// In en, this message translates to:
  /// **'Open details'**
  String get availableOpenDetails;

  /// No description provided for @availableNoShipments.
  ///
  /// In en, this message translates to:
  /// **'There are currently no available shipments.'**
  String get availableNoShipments;

  /// No description provided for @availableNewShipmentsAppearHere.
  ///
  /// In en, this message translates to:
  /// **'New shipments will appear here when they are posted.'**
  String get availableNewShipmentsAppearHere;

  /// No description provided for @availableShipmentsTitle.
  ///
  /// In en, this message translates to:
  /// **'Available shipments'**
  String get availableShipmentsTitle;

  /// No description provided for @availableActiveListings.
  ///
  /// In en, this message translates to:
  /// **'{count} active listings'**
  String availableActiveListings(int count);

  /// No description provided for @availableOpenAndSendOffer.
  ///
  /// In en, this message translates to:
  /// **'Open a shipment and submit your offer.'**
  String get availableOpenAndSendOffer;

  /// No description provided for @availableMyOffers.
  ///
  /// In en, this message translates to:
  /// **'My offers'**
  String get availableMyOffers;

  /// No description provided for @availableLogout.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get availableLogout;

  /// No description provided for @shipmentListTitle.
  ///
  /// In en, this message translates to:
  /// **'Shipment list'**
  String get shipmentListTitle;

  /// No description provided for @shipmentFetchError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load shipments.'**
  String get shipmentFetchError;

  /// No description provided for @auctionEndsInHours.
  ///
  /// In en, this message translates to:
  /// **'{hours}h {minutes}min remaining until the auction ends'**
  String auctionEndsInHours(int hours, int minutes);

  /// No description provided for @auctionEndsInMinutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes}min remaining until the auction ends'**
  String auctionEndsInMinutes(int minutes);

  /// No description provided for @auctionDurationHours.
  ///
  /// In en, this message translates to:
  /// **'{hours, plural, =1{1 hour} other{{hours} hours}}'**
  String auctionDurationHours(int hours);

  /// No description provided for @machineLoadingUppercase.
  ///
  /// In en, this message translates to:
  /// **'MACHINE'**
  String get machineLoadingUppercase;

  /// No description provided for @manualLoadingUppercase.
  ///
  /// In en, this message translates to:
  /// **'MANUAL'**
  String get manualLoadingUppercase;

  /// No description provided for @newUppercase.
  ///
  /// In en, this message translates to:
  /// **'NEW'**
  String get newUppercase;

  /// No description provided for @acceptedUppercase.
  ///
  /// In en, this message translates to:
  /// **'ACCEPTED'**
  String get acceptedUppercase;

  /// No description provided for @finishedUppercase.
  ///
  /// In en, this message translates to:
  /// **'FINISHED'**
  String get finishedUppercase;

  /// No description provided for @activeUppercase.
  ///
  /// In en, this message translates to:
  /// **'ACTIVE'**
  String get activeUppercase;

  /// No description provided for @auctionDurationBadge.
  ///
  /// In en, this message translates to:
  /// **'Auction {duration}'**
  String auctionDurationBadge(String duration);

  /// No description provided for @offersCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{0 offers} =1{1 offer} other{{count} offers}}'**
  String offersCount(int count);

  /// No description provided for @cargo.
  ///
  /// In en, this message translates to:
  /// **'Cargo'**
  String get cargo;

  /// No description provided for @approximateWeight.
  ///
  /// In en, this message translates to:
  /// **'approx. {weight} kg'**
  String approximateWeight(String weight);

  /// No description provided for @publishedDate.
  ///
  /// In en, this message translates to:
  /// **'Published {date}'**
  String publishedDate(String date);

  /// No description provided for @acceptedOfferPrice.
  ///
  /// In en, this message translates to:
  /// **'Accepted offer: {price}'**
  String acceptedOfferPrice(String price);

  /// No description provided for @currentLowestOfferPrice.
  ///
  /// In en, this message translates to:
  /// **'Current lowest offer: {price}'**
  String currentLowestOfferPrice(String price);

  /// No description provided for @viewDetails.
  ///
  /// In en, this message translates to:
  /// **'View details'**
  String get viewDetails;

  /// No description provided for @noShipmentsAvailable.
  ///
  /// In en, this message translates to:
  /// **'There are currently no available shipments.'**
  String get noShipmentsAvailable;

  /// No description provided for @newShipmentsWillAppear.
  ///
  /// In en, this message translates to:
  /// **'New shipments will appear here as soon as senders publish them.'**
  String get newShipmentsWillAppear;

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @manageNotifications.
  ///
  /// In en, this message translates to:
  /// **'Manage notifications'**
  String get manageNotifications;

  /// No description provided for @notificationsFetchError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load notifications.'**
  String get notificationsFetchError;

  /// No description provided for @deleteReadNotificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete read notifications?'**
  String get deleteReadNotificationsTitle;

  /// No description provided for @deleteReadNotificationsMessage.
  ///
  /// In en, this message translates to:
  /// **'All read notifications will be removed from the list.'**
  String get deleteReadNotificationsMessage;

  /// No description provided for @deleteAllNotificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete all notifications?'**
  String get deleteAllNotificationsTitle;

  /// No description provided for @deleteAllNotificationsMessage.
  ///
  /// In en, this message translates to:
  /// **'All notifications will be removed from the list.'**
  String get deleteAllNotificationsMessage;

  /// No description provided for @readNotificationsDeleted.
  ///
  /// In en, this message translates to:
  /// **'Read notifications have been deleted.'**
  String get readNotificationsDeleted;

  /// No description provided for @allNotificationsDeleted.
  ///
  /// In en, this message translates to:
  /// **'All notifications have been deleted.'**
  String get allNotificationsDeleted;

  /// No description provided for @deletionFailed.
  ///
  /// In en, this message translates to:
  /// **'Deletion failed.'**
  String get deletionFailed;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @notificationNewShipment.
  ///
  /// In en, this message translates to:
  /// **'New shipment'**
  String get notificationNewShipment;

  /// No description provided for @notificationNewOffer.
  ///
  /// In en, this message translates to:
  /// **'New offer'**
  String get notificationNewOffer;

  /// No description provided for @notificationUpdatedOffer.
  ///
  /// In en, this message translates to:
  /// **'Updated offer'**
  String get notificationUpdatedOffer;

  /// No description provided for @notificationOfferOutbid.
  ///
  /// In en, this message translates to:
  /// **'Your offer is no longer the lowest'**
  String get notificationOfferOutbid;

  /// No description provided for @notificationJobWon.
  ///
  /// In en, this message translates to:
  /// **'🏆 You got the job'**
  String get notificationJobWon;

  /// No description provided for @notificationAuctionFinished.
  ///
  /// In en, this message translates to:
  /// **'The auction has ended'**
  String get notificationAuctionFinished;

  /// No description provided for @notificationJobWonCelebration.
  ///
  /// In en, this message translates to:
  /// **'🎉 You got the job'**
  String get notificationJobWonCelebration;

  /// No description provided for @notificationConnected.
  ///
  /// In en, this message translates to:
  /// **'🤝 TeReT connected you'**
  String get notificationConnected;

  /// No description provided for @notificationDeliveryConfirmed.
  ///
  /// In en, this message translates to:
  /// **'✅ Transport confirmed'**
  String get notificationDeliveryConfirmed;

  /// No description provided for @notification.
  ///
  /// In en, this message translates to:
  /// **'Notification'**
  String get notification;

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNow;

  /// No description provided for @minutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min ago'**
  String minutesAgo(int minutes);

  /// No description provided for @hoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{hours} h ago'**
  String hoursAgo(int hours);

  /// No description provided for @notificationDeletionFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete the notification.'**
  String get notificationDeletionFailed;

  /// No description provided for @notificationDeleted.
  ///
  /// In en, this message translates to:
  /// **'Notification deleted.'**
  String get notificationDeleted;

  /// No description provided for @noNotifications.
  ///
  /// In en, this message translates to:
  /// **'No notifications'**
  String get noNotifications;

  /// No description provided for @notificationsEmptyDescription.
  ///
  /// In en, this message translates to:
  /// **'New offers, accepted offers and changes will appear here.'**
  String get notificationsEmptyDescription;

  /// No description provided for @deleteReadNotifications.
  ///
  /// In en, this message translates to:
  /// **'Delete read notifications'**
  String get deleteReadNotifications;

  /// No description provided for @deleteAllNotifications.
  ///
  /// In en, this message translates to:
  /// **'Delete all notifications'**
  String get deleteAllNotifications;

  /// No description provided for @notificationNewShipmentMessage.
  ///
  /// In en, this message translates to:
  /// **'A new shipment has been published: {route}'**
  String notificationNewShipmentMessage(String route);

  /// No description provided for @notificationNewShipmentMessageWithoutRoute.
  ///
  /// In en, this message translates to:
  /// **'A new shipment has been published.'**
  String get notificationNewShipmentMessageWithoutRoute;

  /// No description provided for @notificationNewOfferMessage.
  ///
  /// In en, this message translates to:
  /// **'You received a new offer for your shipment.'**
  String get notificationNewOfferMessage;

  /// No description provided for @notificationUpdatedOfferMessage.
  ///
  /// In en, this message translates to:
  /// **'The carrier updated their offer.'**
  String get notificationUpdatedOfferMessage;

  /// No description provided for @notificationOfferOutbidMessage.
  ///
  /// In en, this message translates to:
  /// **'Your offer is no longer the lowest. Submit a new offer to remain competitive.'**
  String get notificationOfferOutbidMessage;

  /// No description provided for @notificationOfferAcceptedMessage.
  ///
  /// In en, this message translates to:
  /// **'Your offer has been accepted. Open the shipment details to continue.'**
  String get notificationOfferAcceptedMessage;

  /// No description provided for @notificationOfferRejectedMessage.
  ///
  /// In en, this message translates to:
  /// **'Another carrier was selected for this transport.'**
  String get notificationOfferRejectedMessage;

  /// No description provided for @notificationContactUnlockedMessage.
  ///
  /// In en, this message translates to:
  /// **'The contact details have been unlocked. Open the shipment details.'**
  String get notificationContactUnlockedMessage;

  /// No description provided for @notificationCarrierConnectedMessage.
  ///
  /// In en, this message translates to:
  /// **'TeReT connected you with the selected carrier.'**
  String get notificationCarrierConnectedMessage;

  /// No description provided for @notificationDeliveryConfirmedMessage.
  ///
  /// In en, this message translates to:
  /// **'The sender confirmed that the transport was completed.'**
  String get notificationDeliveryConfirmedMessage;

  /// No description provided for @deliveryConfirmationTitle.
  ///
  /// In en, this message translates to:
  /// **'Delivery confirmation'**
  String get deliveryConfirmationTitle;

  /// No description provided for @shipmentLoadingError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load shipment.'**
  String get shipmentLoadingError;

  /// No description provided for @deliveryConfirmedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Delivery has been confirmed successfully.'**
  String get deliveryConfirmedSuccessfully;

  /// No description provided for @deliveryConfirmationError.
  ///
  /// In en, this message translates to:
  /// **'Failed to confirm delivery.'**
  String get deliveryConfirmationError;

  /// No description provided for @confirmDeliveryDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Delivery confirmation'**
  String get confirmDeliveryDialogTitle;

  /// No description provided for @confirmDeliveryDialogMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure the shipment has been successfully delivered to its destination?'**
  String get confirmDeliveryDialogMessage;

  /// No description provided for @shipmentData.
  ///
  /// In en, this message translates to:
  /// **'Shipment information'**
  String get shipmentData;

  /// No description provided for @loadingDate.
  ///
  /// In en, this message translates to:
  /// **'Loading date'**
  String get loadingDate;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @phoneNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Phone number not available'**
  String get phoneNotAvailable;

  /// No description provided for @agreedPrice.
  ///
  /// In en, this message translates to:
  /// **'Agreed price'**
  String get agreedPrice;

  /// No description provided for @transportStatus.
  ///
  /// In en, this message translates to:
  /// **'Transport status'**
  String get transportStatus;

  /// No description provided for @deliveryConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Delivery confirmed'**
  String get deliveryConfirmed;

  /// No description provided for @shipmentInTransit.
  ///
  /// In en, this message translates to:
  /// **'Shipment in transit'**
  String get shipmentInTransit;

  /// No description provided for @waitingDeliveryConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Waiting for delivery confirmation from the sender'**
  String get waitingDeliveryConfirmation;

  /// No description provided for @transportCompletedMessage.
  ///
  /// In en, this message translates to:
  /// **'The transport has been completed and confirmed. The next step may be rating the carrier.'**
  String get transportCompletedMessage;

  /// No description provided for @confirmDeliveryInfo.
  ///
  /// In en, this message translates to:
  /// **'If the shipment has arrived at its destination, confirm the delivery. This will mark the transport as completed.'**
  String get confirmDeliveryInfo;

  /// No description provided for @confirmDeliveryButton.
  ///
  /// In en, this message translates to:
  /// **'CONFIRM DELIVERY'**
  String get confirmDeliveryButton;

  /// No description provided for @goToMyShipments.
  ///
  /// In en, this message translates to:
  /// **'GO TO MY SHIPMENTS'**
  String get goToMyShipments;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// No description provided for @myOffersTitle.
  ///
  /// In en, this message translates to:
  /// **'My offers'**
  String get myOffersTitle;

  /// No description provided for @myOffersRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get myOffersRefresh;

  /// No description provided for @myOffersNotLoggedIn.
  ///
  /// In en, this message translates to:
  /// **'You are not logged in. Please sign in again.'**
  String get myOffersNotLoggedIn;

  /// No description provided for @myOffersSessionExpired.
  ///
  /// In en, this message translates to:
  /// **'Your session has expired. Please sign in again.'**
  String get myOffersSessionExpired;

  /// No description provided for @myOffersFetchError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load your offers.'**
  String get myOffersFetchError;

  /// No description provided for @myOffersConnectionError.
  ///
  /// In en, this message translates to:
  /// **'Connection to the server failed.'**
  String get myOffersConnectionError;

  /// No description provided for @myOffersRemoveFromHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove from history?'**
  String get myOffersRemoveFromHistoryTitle;

  /// No description provided for @myOffersRemoveFromHistoryMessage.
  ///
  /// In en, this message translates to:
  /// **'The offer will disappear from your list but will not be permanently deleted from the system.'**
  String get myOffersRemoveFromHistoryMessage;

  /// No description provided for @myOffersCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get myOffersCancel;

  /// No description provided for @myOffersRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get myOffersRemove;

  /// No description provided for @myOffersRemovedFromHistory.
  ///
  /// In en, this message translates to:
  /// **'The offer has been removed from history.'**
  String get myOffersRemovedFromHistory;

  /// No description provided for @myOffersRemoveFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to remove the offer.'**
  String get myOffersRemoveFailed;

  /// No description provided for @myOffersStatusFinished.
  ///
  /// In en, this message translates to:
  /// **'Finished'**
  String get myOffersStatusFinished;

  /// No description provided for @myOffersStatusAccepted.
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get myOffersStatusAccepted;

  /// No description provided for @myOffersStatusLowest.
  ///
  /// In en, this message translates to:
  /// **'Lowest'**
  String get myOffersStatusLowest;

  /// No description provided for @myOffersStatusOutbid.
  ///
  /// In en, this message translates to:
  /// **'Outbid'**
  String get myOffersStatusOutbid;

  /// No description provided for @myOffersShipmentPrefix.
  ///
  /// In en, this message translates to:
  /// **'Shipment'**
  String get myOffersShipmentPrefix;

  /// No description provided for @myOffersShipmentActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get myOffersShipmentActive;

  /// No description provided for @myOffersShipmentOfferAccepted.
  ///
  /// In en, this message translates to:
  /// **'Offer accepted'**
  String get myOffersShipmentOfferAccepted;

  /// No description provided for @myOffersShipmentUsersConnected.
  ///
  /// In en, this message translates to:
  /// **'Users connected'**
  String get myOffersShipmentUsersConnected;

  /// No description provided for @myOffersShipmentAuctionEnded.
  ///
  /// In en, this message translates to:
  /// **'Auction ended'**
  String get myOffersShipmentAuctionEnded;

  /// No description provided for @myOffersDefaultShipmentName.
  ///
  /// In en, this message translates to:
  /// **'Shipment'**
  String get myOffersDefaultShipmentName;

  /// No description provided for @myOffersMyOffer.
  ///
  /// In en, this message translates to:
  /// **'My offer'**
  String get myOffersMyOffer;

  /// No description provided for @myOffersOffersCount.
  ///
  /// In en, this message translates to:
  /// **'Number of offers'**
  String get myOffersOffersCount;

  /// No description provided for @myOffersLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading'**
  String get myOffersLoading;

  /// No description provided for @myOffersByAgreement.
  ///
  /// In en, this message translates to:
  /// **'By agreement'**
  String get myOffersByAgreement;

  /// No description provided for @myOffersWeight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get myOffersWeight;

  /// No description provided for @myOffersMyMessage.
  ///
  /// In en, this message translates to:
  /// **'My message'**
  String get myOffersMyMessage;

  /// No description provided for @myOffersAcceptedUnlockContact.
  ///
  /// In en, this message translates to:
  /// **'🔒 Your offer has been accepted. Open the shipment details and unlock the contact.'**
  String get myOffersAcceptedUnlockContact;

  /// No description provided for @myOffersContactUnlocked.
  ///
  /// In en, this message translates to:
  /// **'Contact unlocked — you can now start arranging the transport.'**
  String get myOffersContactUnlocked;

  /// No description provided for @myOffersSendNewOffer.
  ///
  /// In en, this message translates to:
  /// **'Send new offer'**
  String get myOffersSendNewOffer;

  /// No description provided for @myOffersOtherCarrierSelected.
  ///
  /// In en, this message translates to:
  /// **'Another carrier has been selected for this transport.'**
  String get myOffersOtherCarrierSelected;

  /// No description provided for @myOffersRemoveFromHistory.
  ///
  /// In en, this message translates to:
  /// **'Remove from history'**
  String get myOffersRemoveFromHistory;

  /// No description provided for @myOffersTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get myOffersTryAgain;

  /// No description provided for @myOffersEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t submitted any offers yet.'**
  String get myOffersEmptyTitle;

  /// No description provided for @myOffersEmptyDescription.
  ///
  /// In en, this message translates to:
  /// **'Once you submit an offer for a shipment, all your offers will appear here.'**
  String get myOffersEmptyDescription;

  /// No description provided for @ratingScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Rate transport'**
  String get ratingScreenTitle;

  /// No description provided for @ratingSelectBetweenOneAndFive.
  ///
  /// In en, this message translates to:
  /// **'Please select a rating from 1 to 5.'**
  String get ratingSelectBetweenOneAndFive;

  /// No description provided for @ratingSubmittedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'The rating was submitted successfully.'**
  String get ratingSubmittedSuccessfully;

  /// No description provided for @ratingSubmissionError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while submitting the rating.'**
  String get ratingSubmissionError;

  /// No description provided for @ratingServerConnectionError.
  ///
  /// In en, this message translates to:
  /// **'Could not connect to the server.'**
  String get ratingServerConnectionError;

  /// No description provided for @ratingVeryPoor.
  ///
  /// In en, this message translates to:
  /// **'Very poor'**
  String get ratingVeryPoor;

  /// No description provided for @ratingPoor.
  ///
  /// In en, this message translates to:
  /// **'Poor'**
  String get ratingPoor;

  /// No description provided for @ratingGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get ratingGood;

  /// No description provided for @ratingVeryGood.
  ///
  /// In en, this message translates to:
  /// **'Very good'**
  String get ratingVeryGood;

  /// No description provided for @ratingExcellent.
  ///
  /// In en, this message translates to:
  /// **'Excellent'**
  String get ratingExcellent;

  /// No description provided for @ratingSelectRating.
  ///
  /// In en, this message translates to:
  /// **'Select a rating'**
  String get ratingSelectRating;

  /// No description provided for @ratingDefaultUserLabel.
  ///
  /// In en, this message translates to:
  /// **'user'**
  String get ratingDefaultUserLabel;

  /// No description provided for @ratingRateUserPrefix.
  ///
  /// In en, this message translates to:
  /// **'Rate'**
  String get ratingRateUserPrefix;

  /// No description provided for @ratingFeedbackHelpsOthers.
  ///
  /// In en, this message translates to:
  /// **'Your feedback helps other users.'**
  String get ratingFeedbackHelpsOthers;

  /// No description provided for @ratingCommentOptional.
  ///
  /// In en, this message translates to:
  /// **'Comment (optional)'**
  String get ratingCommentOptional;

  /// No description provided for @ratingCommentHint.
  ///
  /// In en, this message translates to:
  /// **'For example, everything was correct and on time...'**
  String get ratingCommentHint;

  /// No description provided for @ratingSubmitButton.
  ///
  /// In en, this message translates to:
  /// **'Submit rating'**
  String get ratingSubmitButton;

  /// No description provided for @aboutAppTitle.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get aboutAppTitle;

  /// No description provided for @aboutAppDescription.
  ///
  /// In en, this message translates to:
  /// **'A digital platform for publishing shipments, submitting offers and arranging transport more easily.'**
  String get aboutAppDescription;

  /// No description provided for @aboutAppPurposeTitle.
  ///
  /// In en, this message translates to:
  /// **'Purpose of the app'**
  String get aboutAppPurposeTitle;

  /// No description provided for @aboutAppPurposeText.
  ///
  /// In en, this message translates to:
  /// **'TeReT connects transport customers and carriers in one place. The customer publishes a shipment, and carriers submit their offers.'**
  String get aboutAppPurposeText;

  /// No description provided for @aboutAppAuctionTitle.
  ///
  /// In en, this message translates to:
  /// **'Transport auction'**
  String get aboutAppAuctionTitle;

  /// No description provided for @aboutAppAuctionText.
  ///
  /// In en, this message translates to:
  /// **'Carriers can submit an offer for a published shipment, and the customer selects the offer that suits them best.'**
  String get aboutAppAuctionText;

  /// No description provided for @aboutAppContactProtectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Contact protection'**
  String get aboutAppContactProtectionTitle;

  /// No description provided for @aboutAppContactProtectionText.
  ///
  /// In en, this message translates to:
  /// **'Contact details are not publicly available. The phone number and full details are displayed only after an offer is accepted and the contact is unlocked.'**
  String get aboutAppContactProtectionText;

  /// No description provided for @aboutAppPrivacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Security and privacy'**
  String get aboutAppPrivacyTitle;

  /// No description provided for @aboutAppPrivacyText.
  ///
  /// In en, this message translates to:
  /// **'The app is designed to protect user data and display only the information required to arrange transport.'**
  String get aboutAppPrivacyText;

  /// No description provided for @aboutAppSupportTitle.
  ///
  /// In en, this message translates to:
  /// **'Customer support'**
  String get aboutAppSupportTitle;

  /// No description provided for @aboutAppSupportText.
  ///
  /// In en, this message translates to:
  /// **'For help, problem reports or questions, contact support at: teretmegs@gmail.com'**
  String get aboutAppSupportText;

  /// No description provided for @aboutAppVersionTitle.
  ///
  /// In en, this message translates to:
  /// **'App version'**
  String get aboutAppVersionTitle;

  /// No description provided for @aboutAppVersionText.
  ///
  /// In en, this message translates to:
  /// **'MVP version 1.0.0'**
  String get aboutAppVersionText;

  /// No description provided for @legalSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings and information'**
  String get legalSettingsTitle;

  /// No description provided for @legalSettingsTermsTitle.
  ///
  /// In en, this message translates to:
  /// **'Terms of use'**
  String get legalSettingsTermsTitle;

  /// No description provided for @legalSettingsTermsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Rules for using the TeReT platform'**
  String get legalSettingsTermsSubtitle;

  /// No description provided for @legalSettingsPrivacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get legalSettingsPrivacyTitle;

  /// No description provided for @legalSettingsPrivacySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Protection and processing of user data'**
  String get legalSettingsPrivacySubtitle;

  /// No description provided for @legalSettingsContactTitle.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get legalSettingsContactTitle;

  /// No description provided for @legalSettingsContactSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Contact information and support'**
  String get legalSettingsContactSubtitle;

  /// No description provided for @legalSettingsAboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About the app'**
  String get legalSettingsAboutTitle;

  /// No description provided for @legalSettingsAboutSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Information about the TeReT app'**
  String get legalSettingsAboutSubtitle;

  /// No description provided for @termsTitle.
  ///
  /// In en, this message translates to:
  /// **'Terms of use'**
  String get termsTitle;

  /// No description provided for @termsGeneralTitle.
  ///
  /// In en, this message translates to:
  /// **'1. General provisions'**
  String get termsGeneralTitle;

  /// No description provided for @termsGeneralText.
  ///
  /// In en, this message translates to:
  /// **'TeReT is a digital platform that connects transport customers and carriers. TeReT does not participate in the organisation or execution of transport, but enables users to connect and make arrangements.'**
  String get termsGeneralText;

  /// No description provided for @termsPlatformRoleTitle.
  ///
  /// In en, this message translates to:
  /// **'2. Role of the platform'**
  String get termsPlatformRoleTitle;

  /// No description provided for @termsPlatformRoleText.
  ///
  /// In en, this message translates to:
  /// **'TeReT is neither a carrier nor a freight forwarder. TeReT does not act as a contractual party in transport and accepts no responsibility for the execution of transport, delays, cancellations, damage to goods, inaccurate user information or disputes between users. All transport arrangements are made exclusively between the customer and the carrier.'**
  String get termsPlatformRoleText;

  /// No description provided for @termsFeeTitle.
  ///
  /// In en, this message translates to:
  /// **'3. Platform usage fee'**
  String get termsFeeTitle;

  /// No description provided for @termsFeeText.
  ///
  /// In en, this message translates to:
  /// **'The TeReT platform is completely free to use and has no membership or registration fees. A fee is charged only when a transport deal is concluded, meaning when the customer accepts a carrier\'s offer.The commission is paid exclusively by the carrier and only after the customer accepts the carrier\'s offer. The fee is 7% of the agreed transport price, and for transports worth up to €100.00, the fee is €5.00.'**
  String get termsFeeText;

  /// No description provided for @termsUnlockContactTitle.
  ///
  /// In en, this message translates to:
  /// **'4. Unlocking contact details'**
  String get termsUnlockContactTitle;

  /// No description provided for @termsUnlockContactText.
  ///
  /// In en, this message translates to:
  /// **'The contact details of the customer and carrier become available only after the fee has been successfully paid through Stripe. Once the contact details are unlocked, the platform service is considered completed.'**
  String get termsUnlockContactText;

  /// No description provided for @termsRefundTitle.
  ///
  /// In en, this message translates to:
  /// **'5. Fee refunds'**
  String get termsRefundTitle;

  /// No description provided for @termsRefundText.
  ///
  /// In en, this message translates to:
  /// **'Once the contact details have been unlocked, the paid fee is non-refundable. The fee applies to the service of connecting users through the TeReT platform, regardless of whether the transport is later completed.'**
  String get termsRefundText;

  /// No description provided for @termsCancellationTitle.
  ///
  /// In en, this message translates to:
  /// **'6. Transport cancellation'**
  String get termsCancellationTitle;

  /// No description provided for @termsCancellationText.
  ///
  /// In en, this message translates to:
  /// **'If the transport is cancelled by the customer or the carrier, TeReT accepts no responsibility for the consequences of the cancellation. Users are solely responsible for their mutual arrangements, costs, damages, delays or other consequences that may arise from cancellation. If the platform fee has already been paid and the contact details have been unlocked, the fee is non-refundable because the connection service through the platform is considered completed.'**
  String get termsCancellationText;

  /// No description provided for @termsTransportResponsibilityTitle.
  ///
  /// In en, this message translates to:
  /// **'7. Responsibility for transport'**
  String get termsTransportResponsibilityTitle;

  /// No description provided for @termsTransportResponsibilityText.
  ///
  /// In en, this message translates to:
  /// **'The customer and carrier are solely responsible for the execution of transport, the condition of the goods, delivery time and all other details. TeReT does not participate in transport and accepts no responsibility for any resulting damage.'**
  String get termsTransportResponsibilityText;

  /// No description provided for @privacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get privacyTitle;

  /// No description provided for @privacySection1Title.
  ///
  /// In en, this message translates to:
  /// **'1. Data collection'**
  String get privacySection1Title;

  /// No description provided for @privacySection1Text.
  ///
  /// In en, this message translates to:
  /// **'TeReT collects the basic user information required to use the platform, including full name, phone number, email address, transport information and published shipments.'**
  String get privacySection1Text;

  /// No description provided for @privacySection2Title.
  ///
  /// In en, this message translates to:
  /// **'2. Use of data'**
  String get privacySection2Title;

  /// No description provided for @privacySection2Text.
  ///
  /// In en, this message translates to:
  /// **'The collected data is used solely to enable communication between transport customers and carriers and to ensure the proper functioning of the platform.'**
  String get privacySection2Text;

  /// No description provided for @privacySection3Title.
  ///
  /// In en, this message translates to:
  /// **'3. Data sharing'**
  String get privacySection3Title;

  /// No description provided for @privacySection3Text.
  ///
  /// In en, this message translates to:
  /// **'User contact details are not publicly available. They are unlocked only after an offer has been accepted and the platform fee has been successfully paid.'**
  String get privacySection3Text;

  /// No description provided for @privacySection4Title.
  ///
  /// In en, this message translates to:
  /// **'4. Data security'**
  String get privacySection4Title;

  /// No description provided for @privacySection4Text.
  ///
  /// In en, this message translates to:
  /// **'TeReT takes reasonable technical and organisational measures to protect user data against unauthorised access, loss or misuse.'**
  String get privacySection4Text;

  /// No description provided for @privacySection5Title.
  ///
  /// In en, this message translates to:
  /// **'5. Email verification'**
  String get privacySection5Title;

  /// No description provided for @privacySection5Text.
  ///
  /// In en, this message translates to:
  /// **'For the security and protection of users, TeReT uses email verification during account registration.'**
  String get privacySection5Text;

  /// No description provided for @privacySection6Title.
  ///
  /// In en, this message translates to:
  /// **'6. Cookies and technical data'**
  String get privacySection6Title;

  /// No description provided for @privacySection6Text.
  ///
  /// In en, this message translates to:
  /// **'The app may collect technical data necessary for system operation, security and improving the user experience.'**
  String get privacySection6Text;

  /// No description provided for @privacySection7Title.
  ///
  /// In en, this message translates to:
  /// **'7. User rights'**
  String get privacySection7Title;

  /// No description provided for @privacySection7Text.
  ///
  /// In en, this message translates to:
  /// **'Users have the right to request correction or deletion of their personal data in accordance with applicable laws and privacy regulations.'**
  String get privacySection7Text;

  /// No description provided for @privacySection8Title.
  ///
  /// In en, this message translates to:
  /// **'8. Contact'**
  String get privacySection8Title;

  /// No description provided for @privacySection8Text.
  ///
  /// In en, this message translates to:
  /// **'For any questions regarding privacy and data protection, users can contact us through the contact option within the app.'**
  String get privacySection8Text;

  /// No description provided for @contactSupportTitle.
  ///
  /// In en, this message translates to:
  /// **'Customer support'**
  String get contactSupportTitle;

  /// No description provided for @contactSupportHeading.
  ///
  /// In en, this message translates to:
  /// **'Contact and support'**
  String get contactSupportHeading;

  /// No description provided for @contactSupportDescription.
  ///
  /// In en, this message translates to:
  /// **'For questions, account issues or problems using the app, you can contact our support team.'**
  String get contactSupportDescription;

  /// No description provided for @contactSupportEmailTitle.
  ///
  /// In en, this message translates to:
  /// **'Email support'**
  String get contactSupportEmailTitle;

  /// No description provided for @contactSupportResponseTimeTitle.
  ///
  /// In en, this message translates to:
  /// **'Response time'**
  String get contactSupportResponseTimeTitle;

  /// No description provided for @contactSupportResponseTimeText.
  ///
  /// In en, this message translates to:
  /// **'We respond to enquiries as quickly as possible.'**
  String get contactSupportResponseTimeText;

  /// No description provided for @contactSupportMessageInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'What to include in your message'**
  String get contactSupportMessageInfoTitle;

  /// No description provided for @contactSupportMessageInfoText.
  ///
  /// In en, this message translates to:
  /// **'When reporting a problem, include the account email address, a description of the issue and, if possible, a screenshot of the error.'**
  String get contactSupportMessageInfoText;

  /// No description provided for @contactSupportEmailSubject.
  ///
  /// In en, this message translates to:
  /// **'Support - TeReT'**
  String get contactSupportEmailSubject;

  /// No description provided for @newOffer.
  ///
  /// In en, this message translates to:
  /// **'New offer'**
  String get newOffer;

  /// No description provided for @enterRequestedTransportPrice.
  ///
  /// In en, this message translates to:
  /// **'Enter the price you require for the transport.'**
  String get enterRequestedTransportPrice;

  /// No description provided for @noCurrentOfferForAutomaticReduction.
  ///
  /// In en, this message translates to:
  /// **'There is no current offer available for automatic reduction.'**
  String get noCurrentOfferForAutomaticReduction;

  /// No description provided for @offerAmountMustBeGreaterThanZero.
  ///
  /// In en, this message translates to:
  /// **'The offer amount must be greater than 0.'**
  String get offerAmountMustBeGreaterThanZero;

  /// No description provided for @noLowestOfferForShipment.
  ///
  /// In en, this message translates to:
  /// **'There is no lowest offer for this shipment yet.'**
  String get noLowestOfferForShipment;

  /// No description provided for @notLoggedInLoginAgain.
  ///
  /// In en, this message translates to:
  /// **'You are not logged in. Please log in again.'**
  String get notLoggedInLoginAgain;

  /// No description provided for @enterValidOfferAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid offer amount.'**
  String get enterValidOfferAmount;

  /// No description provided for @offerSuccessfullySent.
  ///
  /// In en, this message translates to:
  /// **'The offer was sent successfully.'**
  String get offerSuccessfullySent;

  /// No description provided for @errorSendingOffer.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while sending the offer.'**
  String get errorSendingOffer;

  /// No description provided for @loadingCurrentLowestOffer.
  ///
  /// In en, this message translates to:
  /// **'Loading the current lowest offer...'**
  String get loadingCurrentLowestOffer;

  /// No description provided for @noOffersForShipmentYet.
  ///
  /// In en, this message translates to:
  /// **'There are no offers for this shipment yet.'**
  String get noOffersForShipmentYet;

  /// No description provided for @currentLowestOfferUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Current lowest offer: -'**
  String get currentLowestOfferUnavailable;

  /// No description provided for @currentLowestOffer.
  ///
  /// In en, this message translates to:
  /// **'Current lowest offer: {amount}'**
  String currentLowestOffer(String amount);

  /// No description provided for @yourOfferNotSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Your offer: you have not submitted an offer yet'**
  String get yourOfferNotSubmitted;

  /// No description provided for @yourOffer.
  ///
  /// In en, this message translates to:
  /// **'Your offer: {amount}'**
  String yourOffer(String amount);

  /// No description provided for @yourOfferIsCurrentlyLowest.
  ///
  /// In en, this message translates to:
  /// **'Your offer is currently the lowest.'**
  String get yourOfferIsCurrentlyLowest;

  /// No description provided for @newOfferMinimumLower.
  ///
  /// In en, this message translates to:
  /// **'The new offer must be at least 5 {currency} lower than the current lowest offer.'**
  String newOfferMinimumLower(String currency);

  /// No description provided for @offerBindingNotice.
  ///
  /// In en, this message translates to:
  /// **'Note: by submitting an offer, you agree to complete the transport if the customer accepts your offer.'**
  String get offerBindingNotice;

  /// No description provided for @currency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currency;

  /// No description provided for @euroCurrency.
  ///
  /// In en, this message translates to:
  /// **'Euro (€)'**
  String get euroCurrency;

  /// No description provided for @usDollarCurrency.
  ///
  /// In en, this message translates to:
  /// **'US dollar (\$)'**
  String get usDollarCurrency;

  /// No description provided for @britishPoundCurrency.
  ///
  /// In en, this message translates to:
  /// **'British pound (£)'**
  String get britishPoundCurrency;

  /// No description provided for @canadianDollarCurrency.
  ///
  /// In en, this message translates to:
  /// **'Canadian dollar (C\$)'**
  String get canadianDollarCurrency;

  /// No description provided for @australianDollarCurrency.
  ///
  /// In en, this message translates to:
  /// **'Australian dollar (A\$)'**
  String get australianDollarCurrency;

  /// No description provided for @offerAmount.
  ///
  /// In en, this message translates to:
  /// **'Offer amount ({currency})'**
  String offerAmount(String currency);

  /// No description provided for @enterAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter amount'**
  String get enterAmount;

  /// No description provided for @enterOfferAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter the offer amount'**
  String get enterOfferAmount;

  /// No description provided for @enterValidNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid number'**
  String get enterValidNumber;

  /// No description provided for @amountMustBeGreaterThanZero.
  ///
  /// In en, this message translates to:
  /// **'The amount must be greater than 0'**
  String get amountMustBeGreaterThanZero;

  /// No description provided for @offerMustBeLowerThanCurrentLowest.
  ///
  /// In en, this message translates to:
  /// **'The offer must be lower than the current lowest offer'**
  String get offerMustBeLowerThanCurrentLowest;

  /// No description provided for @minimumOfferReduction.
  ///
  /// In en, this message translates to:
  /// **'The minimum offer reduction is 5 {currency}'**
  String minimumOfferReduction(String currency);

  /// No description provided for @setAsLowestOffer.
  ///
  /// In en, this message translates to:
  /// **'Set as the lowest offer'**
  String get setAsLowestOffer;

  /// No description provided for @messageToCustomerOptional.
  ///
  /// In en, this message translates to:
  /// **'Message to the customer (optional)'**
  String get messageToCustomerOptional;

  /// No description provided for @enterShortMessage.
  ///
  /// In en, this message translates to:
  /// **'Enter a short message...'**
  String get enterShortMessage;

  /// No description provided for @nearLoadingLocationNotice.
  ///
  /// In en, this message translates to:
  /// **'If you are near the loading location and can collect the shipment immediately, mention this in your offer message. A quick arrival may be decisive when the customer selects a carrier.'**
  String get nearLoadingLocationNotice;

  /// No description provided for @checkShipmentData.
  ///
  /// In en, this message translates to:
  /// **'Check shipment data'**
  String get checkShipmentData;

  /// No description provided for @checkShipmentDataMessage.
  ///
  /// In en, this message translates to:
  /// **'Please review all entered shipment data before publishing.\n\nAfter publishing, the shipment will become visible to carriers and can no longer be edited.'**
  String get checkShipmentDataMessage;

  /// No description provided for @shipmentPublishedSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'✅ Shipment published successfully.\n\nYou do not need to wait for the auction to end. You can accept an offer at any time as soon as you find a carrier that suits you.'**
  String get shipmentPublishedSuccessMessage;

  /// No description provided for @notificationPermissionMainMessage.
  ///
  /// In en, this message translates to:
  /// **'🔔 To ensure that TeReT works properly, you must enable notifications in your phone settings.'**
  String get notificationPermissionMainMessage;

  /// No description provided for @notificationPermissionDetails.
  ///
  /// In en, this message translates to:
  /// **'This will allow you to receive new offers, auction updates and other important information on time.'**
  String get notificationPermissionDetails;

  /// No description provided for @notificationPermissionStillDisabled.
  ///
  /// In en, this message translates to:
  /// **'Notifications are still disabled. Press the button again to open the settings.'**
  String get notificationPermissionStillDisabled;

  /// No description provided for @notificationSettingsCouldNotOpen.
  ///
  /// In en, this message translates to:
  /// **'The settings could not be opened. Open your phone settings and enable notifications for TeReT.'**
  String get notificationSettingsCouldNotOpen;

  /// No description provided for @enableNotificationsInSettings.
  ///
  /// In en, this message translates to:
  /// **'Enable notifications in settings'**
  String get enableNotificationsInSettings;

  /// No description provided for @checkingNotifications.
  ///
  /// In en, this message translates to:
  /// **'Checking notifications...'**
  String get checkingNotifications;

  /// No description provided for @enableNotificationsButton.
  ///
  /// In en, this message translates to:
  /// **'Enable notifications'**
  String get enableNotificationsButton;

  /// No description provided for @returnAfterEnablingNotifications.
  ///
  /// In en, this message translates to:
  /// **'After enabling notifications, return to TeReT. The app will continue automatically.'**
  String get returnAfterEnablingNotifications;

  /// No description provided for @sevenDays.
  ///
  /// In en, this message translates to:
  /// **'7 days'**
  String get sevenDays;

  /// No description provided for @auctionFinishedChooseCarrier.
  ///
  /// In en, this message translates to:
  /// **'The auction has ended — choose a carrier'**
  String get auctionFinishedChooseCarrier;

  /// No description provided for @chooseCarrier.
  ///
  /// In en, this message translates to:
  /// **'Choose a carrier'**
  String get chooseCarrier;

  /// No description provided for @reliability.
  ///
  /// In en, this message translates to:
  /// **'Reliability'**
  String get reliability;

  /// No description provided for @noReliabilityMisses.
  ///
  /// In en, this message translates to:
  /// **'No recorded reliability issues'**
  String get noReliabilityMisses;

  /// No description provided for @senderNoSelectionInTime.
  ///
  /// In en, this message translates to:
  /// **'Did not choose a carrier in time: {count}'**
  String senderNoSelectionInTime(Object count);

  /// No description provided for @carrierNoPaymentInTime.
  ///
  /// In en, this message translates to:
  /// **'Did not pay the service fee in time: {count}'**
  String carrierNoPaymentInTime(Object count);

  /// No description provided for @userProfile.
  ///
  /// In en, this message translates to:
  /// **'User profile'**
  String get userProfile;

  /// No description provided for @userComments.
  ///
  /// In en, this message translates to:
  /// **'User comments'**
  String get userComments;

  /// No description provided for @reliabilityMissesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} recorded reliability issues'**
  String reliabilityMissesCount(int count);
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'hr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'hr': return AppLocalizationsHr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
