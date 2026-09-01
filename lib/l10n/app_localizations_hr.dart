// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Croatian (`hr`).
class AppLocalizationsHr extends AppLocalizations {
  AppLocalizationsHr([String locale = 'hr']) : super(locale);

  @override
  String get appName => 'TeReT';

  @override
  String get welcomeToTeret => 'Dobro došli u TeReT';

  @override
  String get loginPlatformDescription => 'Platforma za jednostavno povezivanje naručitelja i prijevoznika.';

  @override
  String get login => 'Prijava';

  @override
  String get email => 'Email';

  @override
  String get password => 'Lozinka';

  @override
  String get signIn => 'Prijavi se';

  @override
  String get noAccountRegister => 'Nemaš račun? Registriraj se';

  @override
  String get enterEmail => 'Unesite email';

  @override
  String get enterValidEmail => 'Unesite ispravnu email adresu';

  @override
  String get enterPassword => 'Unesite lozinku';

  @override
  String get enterValidEmailFirst => 'Prvo unesite ispravnu email adresu.';

  @override
  String get showPassword => 'Prikaži lozinku';

  @override
  String get hidePassword => 'Sakrij lozinku';

  @override
  String get forgotPasswordQuestion => 'Zaboravili ste lozinku?';

  @override
  String get forgotPasswordTitle => 'Zaboravljena lozinka';

  @override
  String get forgotPasswordDescription => 'Unesite email adresu povezanu s vašim računom. Poslat ćemo vam poveznicu za postavljanje nove lozinke.';

  @override
  String get sendResetLink => 'Pošalji poveznicu';

  @override
  String get passwordResetLinkSent => 'Ako račun s tim emailom postoji, poslana je poveznica za promjenu lozinke.';

  @override
  String get passwordResetLinkSendError => 'Slanje poveznice nije uspjelo.';

  @override
  String get accountNotVerified => 'Račun nije potvrđen. Molimo potvrdite email adresu prije prijave.';

  @override
  String get resendVerificationEmail => 'Pošalji ponovno email za potvrdu';

  @override
  String get verificationEmailResent => 'Email za potvrdu je ponovno poslan.';

  @override
  String get verificationEmailSendError => 'Greška prilikom slanja emaila za potvrdu.';

  @override
  String get loginError => 'Greška pri prijavi.';

  @override
  String get invalidUserRole => 'Korisnička uloga nije ispravna.';

  @override
  String get emailAndPasswordRequired => 'Email i lozinka su obavezni.';

  @override
  String get invalidEmailOrPassword => 'Email ili lozinka nisu ispravni.';

  @override
  String get serverError => 'Došlo je do greške na serveru. Pokušajte ponovno.';

  @override
  String get serverConnectionError => 'Greška povezivanja sa serverom.';

  @override
  String get close => 'Zatvori';

  @override
  String get cancel => 'Odustani';

  @override
  String get confirm => 'Potvrdi';

  @override
  String get carrier => 'Prijevoznik';

  @override
  String get sender => 'Naručitelj';

  @override
  String get register => 'Registracija';

  @override
  String get logout => 'Odjava';

  @override
  String get roleSelection => 'Odabir uloge';

  @override
  String get howDoYouWantToUseApp => 'Kako želite koristiti aplikaciju?';

  @override
  String get transportCustomer => 'Naručitelj prijevoza';

  @override
  String get termsAcceptanceRequired => 'Za registraciju morate prihvatiti Uvjete korištenja.';

  @override
  String get registrationSuccessfulVerifyEmail => 'Registracija uspješna. Potvrdite email adresu prije prijave.';

  @override
  String get registrationError => 'Greška pri registraciji.';

  @override
  String get registrationConnectionError => 'Greška konekcije sa serverom. Provjerite internetsku vezu i pokušajte ponovno.';

  @override
  String get enterFullName => 'Unesite ime i prezime';

  @override
  String get enterPhoneNumber => 'Unesite broj mobitela';

  @override
  String get enterValidPhoneNumber => 'Unesite ispravan broj mobitela';

  @override
  String get passwordMinimumFourCharacters => 'Lozinka mora imati barem 4 znaka';

  @override
  String get r1InvoiceNotice => 'Ako trebate R1 račun, prilikom plaćanja putem Stripe Checkouta unesite točne podatke za račun kako bismo vam mogli izdati i dostaviti R1 račun.';

  @override
  String get fullName => 'Ime i prezime';

  @override
  String get companyNameOptional => 'Naziv tvrtke / obrta (nije obavezno)';

  @override
  String get cityOrHeadquarters => 'Grad / sjedište';

  @override
  String get country => 'Država';

  @override
  String get mobilePhoneNumber => 'Broj mobitela';

  @override
  String get selectCountry => 'Odaberite državu';

  @override
  String get searchCountryOrDialCode => 'Pretraži državu ili pozivni broj';

  @override
  String get noCountriesFound => 'Nema pronađenih država.';

  @override
  String get iAccept => 'Prihvaćam ';

  @override
  String get termsOfUse => 'Uvjete korištenja';

  @override
  String get teretPlatformSuffix => ' platforme TeReT.';

  @override
  String get registrationSuccessful => 'Registracija je uspješna.';

  @override
  String get copyVerificationLinkForTesting => 'Za testiranje kopirajte ovu poveznicu i otvorite je u pregledniku:';

  @override
  String get afterEmailVerificationLogin => 'Nakon potvrde email adrese možete se prijaviti.';

  @override
  String get goToLogin => 'Idi na prijavu';

  @override
  String get registerButton => 'Registriraj se';

  @override
  String get alreadyHaveAccountLogin => 'Već imaš račun? Prijavi se';

  @override
  String get exitAppTitle => 'Izlaz iz aplikacije';

  @override
  String get exitAppQuestion => 'Jeste li sigurni da želite izaći iz aplikacije?';

  @override
  String get exit => 'Izađi';

  @override
  String get info => 'Info';

  @override
  String get shipmentList => 'Lista tereta';

  @override
  String get myOffers => 'Moje ponude';

  @override
  String get notifications => 'Obavijesti';

  @override
  String get notificationsDisabled => 'Obavijesti su isključene';

  @override
  String get notificationsWarningDescription => 'Uključite obavijesti kako biste na vrijeme primali nove terete, informacije o ponudi i ostale važne obavijesti o licitacijama.';

  @override
  String get enableNotifications => 'Omogućite obavijesti';

  @override
  String get splashTagline => 'Radar prijevoza';

  @override
  String get senderRoleDescription => 'Objavi teret i primaj ponude prijevoznika';

  @override
  String get carrierRoleDescription => 'Pregledaj terete i pošalji svoju ponudu';

  @override
  String get selectRoleInfo => 'Odaberi ulogu i nastavi na prijavu ili registraciju.';

  @override
  String get newBadge => 'NOVO';

  @override
  String get myShipments => 'Moje objave';

  @override
  String get publishShipment => 'Objavi teret';

  @override
  String get shipmentPublishDescription => 'Ispunite podatke o teretu kako bi prijevoznici mogli slati ponude.';

  @override
  String get basicInformation => 'Osnovno';

  @override
  String get route => 'Ruta';

  @override
  String get timeAndQuantity => 'Vrijeme i količina';

  @override
  String get contact => 'Kontakt';

  @override
  String get shipmentImages => 'Slike tereta';

  @override
  String get additionalDetails => 'Dodatni detalji (opcionalno)';

  @override
  String get shipmentName => 'Naziv tereta';

  @override
  String get shortShipmentDescription => 'Kratki opis tereta';

  @override
  String get enterShipmentDescription => 'Unesite opis tereta.';

  @override
  String get shipmentDescriptionNoContactInfo => 'Opis ne smije sadržavati kontakt podatke.';

  @override
  String get loadingCountry => 'Država utovara';

  @override
  String get loadingCity => 'Mjesto utovara';

  @override
  String get loadingAddress => 'Adresa utovara';

  @override
  String get unloadingCountry => 'Država istovara';

  @override
  String get unloadingCity => 'Mjesto istovara';

  @override
  String get unloadingAddress => 'Adresa istovara';

  @override
  String get auctionDuration => 'Trajanje licitacije';

  @override
  String get contactHiddenUntilAccepted => 'Kontakt podaci neće biti vidljivi prijevozniku dok ne prihvatite ponudu.';

  @override
  String get loadingDeadlineAfterAuction => 'Rok utovara nakon isteka licitacije';

  @override
  String get approxWeight => 'Težina cca (kg/lb)';

  @override
  String get palletCount => 'Broj paleta';

  @override
  String get phoneNumber => 'Broj telefona';

  @override
  String get oneHour => '1 sat';

  @override
  String get twoHours => '2 sata';

  @override
  String get sixHours => '6 sati';

  @override
  String get twelveHours => '12 sati';

  @override
  String get twentyFourHours => '24 sata';

  @override
  String get fortyEightHours => '48 sati';

  @override
  String get seventyTwoHours => '72 sata';

  @override
  String get byAgreement => 'Po dogovoru';

  @override
  String get loadingLocationType => 'Tip lokacije utovara';

  @override
  String get building => 'Zgrada';

  @override
  String get productionFacility => 'Proizvodni pogon';

  @override
  String get warehouse => 'Skladište';

  @override
  String get house => 'Kuća';

  @override
  String get constructionSite => 'Gradilište';

  @override
  String get businessPremises => 'Poslovni prostor';

  @override
  String get unloadingLocationType => 'Tip lokacije istovara';

  @override
  String get loadingMethod => 'Način utovara';

  @override
  String get manualLoading => 'Ručno';

  @override
  String get machineLoading => 'Strojno';

  @override
  String get length => 'Dužina';

  @override
  String get width => 'Širina';

  @override
  String get height => 'Visina';

  @override
  String get truckAccess => 'Prilaz za tegljač';

  @override
  String get driverHelp => 'Treba pomoć vozača';

  @override
  String get gallery => 'Galerija';

  @override
  String get camera => 'Kamera';

  @override
  String selectedImages(int count, int max) {
    return 'Odabrano slika: $count/$max';
  }

  @override
  String get noImagesSelected => 'Nema odabranih slika.';

  @override
  String get noShipmentsYet => 'Trenutno nemaš nijednu objavu.';

  @override
  String get active => 'Aktivan';

  @override
  String get transportAgreed => 'Prijevoz dogovoren';

  @override
  String get completed => 'Završeno';

  @override
  String get auctionFinished => 'Licitacija završena';

  @override
  String get unknown => 'Nepoznato';

  @override
  String get auction => 'Licitacija';

  @override
  String get offers => 'Ponude';

  @override
  String get views => 'Pregledi';

  @override
  String get lowestOffer => 'Najniža ponuda';

  @override
  String get details => 'Detalji';

  @override
  String get auctionProgress => 'Tijek licitacije';

  @override
  String get removeFromHistory => 'Ukloni iz povijesti';

  @override
  String get repost => 'Ponovno objavi';

  @override
  String get paymentSuccessfulContactUnlocked => 'Plaćanje je uspješno. Kontakt je otključan.';

  @override
  String get errorFetchingShipmentDetails => 'Greška pri dohvaćanju detalja tereta.';

  @override
  String get cannotOpenStripePayment => 'Nije moguće otvoriti Stripe plaćanje.';

  @override
  String get commissionRecorded => 'Provizija je evidentirana.';

  @override
  String get areYouSure => 'Jesi li siguran?';

  @override
  String get confirmDeliveryExplanation => 'Potvrdom označavaš da je prijevoz obavljen.';

  @override
  String get transportCompleted => 'Prijevoz obavljen';

  @override
  String get transportMarkedCompleted => 'Prijevoz je označen kao obavljen.';

  @override
  String get carrierAccusative => 'prijevoznika';

  @override
  String get cannotOpenPhoneApp => 'Nije moguće otvoriti aplikaciju za poziv.';

  @override
  String get acceptedOffer => 'Prihvaćena ponuda';

  @override
  String get senderUppercase => 'NARUČITELJ';

  @override
  String get noRatings => 'Nema ocjena';

  @override
  String get confirming => 'Potvrđujem...';

  @override
  String get carrierSelected => 'Odabrali ste prijevoznika.';

  @override
  String get offerAccepted => 'Ponuda je prihvaćena.';

  @override
  String get carrierWillContactSoon => 'Prijevoznik će vas uskoro kontaktirati.';

  @override
  String get waitingForCarrierConfirmation => 'Čeka se potvrda prijevoznika.';

  @override
  String get offerAcceptedShort => 'Ponuda prihvaćena.';

  @override
  String get platformFeeExplanation => 'Posao je Vaš.\n\nZa otključavanje kontakt podataka potrebno je platiti naknadu platforme putem Stripe Checkouta.\n\nNaknada iznosi 7% od dogovorene cijene prijevoza, a za prijevoze u vrijednosti do 100,00 € naknada iznosi 5,00 €.';

  @override
  String get continueToStripeCheckout => 'Nastavi na Stripe Checkout';

  @override
  String get otherCarrierWonMessage => 'Nažalost, drugi prijevoznik je dobio ovaj posao. Hvala na sudjelovanju u licitaciji.';

  @override
  String get shipmentNotFound => 'Teret nije pronađen.';

  @override
  String get senderAccusative => 'naručitelja';

  @override
  String get statusOtherCarrierSelected => 'Status: Odabran drugi prijevoznik';

  @override
  String get otherCarrierSelectedMessage => 'Nažalost, drugi prijevoznik je odabran za ovaj prijevoz. Hvala na sudjelovanju u licitaciji.';

  @override
  String get statusAuctionFinished => 'Status: Licitacija završena';

  @override
  String get statusOfferAcceptedByYou => 'Status: Prihvatili ste ponudu';

  @override
  String get loadingPlace => 'Mjesto utovara';

  @override
  String get unloadingPlace => 'Mjesto istovara';

  @override
  String get weight => 'Težina';

  @override
  String get numberOfPallets => 'Broj paleta';

  @override
  String get loadingFloor => 'Kat utovara';

  @override
  String get unloadingFloor => 'Kat istovara';

  @override
  String get loadingLift => 'Lift na utovaru';

  @override
  String get unloadingLift => 'Lift na istovaru';

  @override
  String get yes => 'Da';

  @override
  String get no => 'Ne';

  @override
  String get driverHelpNeeded => 'Treba pomoć vozača';

  @override
  String get acceptedPrice => 'Prihvaćena cijena';

  @override
  String get commission => 'Provizija';

  @override
  String get numberOfOffers => 'Broj ponuda';

  @override
  String get listingViews => 'Pregledi objave';

  @override
  String get contactPhone => 'Kontakt telefon';

  @override
  String get callSender => 'Nazovi naručitelja';

  @override
  String get sendOffer => 'Pošalji ponudu';

  @override
  String get teretDelivered => 'TeReT isporučen';

  @override
  String get thankYouForRating => 'Hvala na vašoj ocjeni.';

  @override
  String get ratingBuildsTrust => 'Ocjena doprinosi pouzdanosti platforme.';

  @override
  String get otherCarrierSelectedForShipment => 'Odabran je drugi prijevoznik za ovaj teret.';

  @override
  String get offersNoLongerAllowed => 'Na ovaj teret više nije moguće slati ponude.';

  @override
  String get shipmentDetails => 'Detalji tereta';

  @override
  String get refresh => 'Osvježi';

  @override
  String ratingSummary(String rating, String count) {
    return '⭐ $rating ($count ocjena)';
  }

  @override
  String alreadyRated(String user) {
    return 'Već ste ocijenili $user.';
  }

  @override
  String rateUser(String user) {
    return 'Ocijeni $user';
  }

  @override
  String agreedTransportPrice(String amount) {
    return 'Dogovorena cijena prijevoza: $amount';
  }

  @override
  String feeAmount(String amount) {
    return 'Iznos naknade: $amount';
  }

  @override
  String timeRemaining(int hours, int minutes) {
    return 'Još ${hours}h ${minutes}min';
  }

  @override
  String statusLabel(String status) {
    return 'Status: $status';
  }

  @override
  String get sessionExpiredLoginAgain => 'Sesija je istekla. Prijavite se ponovno.';

  @override
  String get errorLoadingOffers => 'Greška kod učitavanja ponuda.';

  @override
  String get acceptOfferConfirmationText => 'Prihvatom ove ponude zaključuješ dogovor i odabireš ovog prijevoznika.';

  @override
  String get acceptOffer => 'Prihvati ponudu';

  @override
  String get invalidOfferId => 'Neispravan ID ponude.';

  @override
  String get offerAcceptedSuccessfully => 'Ponuda je uspješno prihvaćena.';

  @override
  String get acceptOfferFailed => 'Prihvat ponude nije uspio.';

  @override
  String get accepted => 'Prihvaćena';

  @override
  String get outbid => 'Nadmašena';

  @override
  String get rejected => 'Odbijena';

  @override
  String get pending => 'Na čekanju';

  @override
  String get activeFeminine => 'Aktivna';

  @override
  String get carrierUppercase => 'PRIJEVOZNIK';

  @override
  String get carrierIdNotFound => 'Nije pronađen ID prijevoznika za ovu ponudu.';

  @override
  String offerWithPrice(String price) {
    return 'Ponuda: $price';
  }

  @override
  String get thisOfferAccepted => 'Ova ponuda je prihvaćena';

  @override
  String get thisOfferOutbid => 'Ova ponuda je nadmašena';

  @override
  String get shipmentOffers => 'Ponude za teret';

  @override
  String get noOffersForShipment => 'Za ovaj teret još nema ponuda.';

  @override
  String get offerAlreadyAcceptedShipmentClosed => 'Jedna ponuda je već prihvaćena i teret je zaključen.';

  @override
  String get bidHistoryNotLoggedIn => 'Niste prijavljeni. Prijavite se ponovno.';

  @override
  String get bidHistorySessionExpired => 'Sesija je istekla. Prijavite se ponovno.';

  @override
  String get bidHistoryFetchError => 'Došlo je do pogreške pri dohvaćanju tijeka licitacije.';

  @override
  String get bidHistoryConnectionError => 'Došlo je do pogreške. Provjerite vezu s backendom.';

  @override
  String get bidHistoryStatusActive => 'Aktivan';

  @override
  String get bidHistoryStatusAccepted => 'Prihvaćena ponuda';

  @override
  String get bidHistoryStatusCompleted => 'Završeno';

  @override
  String get bidHistoryYourOffer => 'Vaša ponuda';

  @override
  String get bidHistoryCarrier => 'Prijevoznik';

  @override
  String bidHistoryRatings(String averageRating, String ratingsCount) {
    return '⭐ $averageRating ($ratingsCount ocjena)';
  }

  @override
  String get bidHistorySummary => 'Sažetak licitacije';

  @override
  String get bidHistoryCurrentLowestOffer => 'Trenutna najniža ponuda';

  @override
  String get bidHistoryOffersCount => 'Broj ponuda';

  @override
  String get bidHistoryShipmentStatus => 'Status tereta';

  @override
  String get bidHistoryBadgeAccepted => 'PRIHVAĆENO';

  @override
  String get bidHistoryBadgeRejected => 'ODBIJENO';

  @override
  String get bidHistoryBadgeLowest => 'NAJNIŽA';

  @override
  String get bidHistoryBadgeYours => 'VAŠA';

  @override
  String get bidHistoryNoOffers => 'Još nema ponuda za ovaj teret.';

  @override
  String get bidHistoryAuctionProgress => 'Tijek licitacije';

  @override
  String get bidHistoryRefresh => 'Osvježi';

  @override
  String get bidHistoryStatusAuctionFinished => 'Licitacija završena';

  @override
  String get acceptOfferConfirmation => 'Jeste li sigurni da želite prihvatiti ovu ponudu?';

  @override
  String get acceptOfferButton => 'PRIHVATI PONUDU';

  @override
  String get acceptOfferWarning => 'Nakon prihvaćanja ponude teret će biti dodijeljen ovom prijevozniku i ostale ponude će biti zatvorene.';

  @override
  String get offer => 'Ponuda';

  @override
  String get offerTime => 'Vrijeme ponude';

  @override
  String get note => 'Napomena';

  @override
  String get notSpecified => 'Nije navedeno';

  @override
  String get offerAcceptError => 'Greška kod prihvaćanja ponude';

  @override
  String generalError(String error) {
    return 'Greška: $error';
  }

  @override
  String offerDateTime(String day, String month, String year, String hour, String minute) {
    return '$day.$month.$year u $hour:$minute';
  }

  @override
  String get hoursShort => 'sata';

  @override
  String get assignedShipmentTitle => 'Dodijeljeni teret';

  @override
  String get assignedSessionExpired => 'Sesija je istekla. Prijavite se ponovno.';

  @override
  String get assignedShipmentLoadError => 'Greška kod učitavanja tereta.';

  @override
  String get assignedErrorPrefix => 'Greška';

  @override
  String get assignedAreYouSure => 'Jesi li siguran?';

  @override
  String get assignedDeliveryConfirmationText => 'Potvrdom označavaš da je prijevoz obavljen.';

  @override
  String get assignedCancel => 'Odustani';

  @override
  String get assignedTransportCompleted => 'Prijevoz obavljen';

  @override
  String get assignedMarkedAsCompleted => 'Prijevoz je označen kao obavljen.';

  @override
  String get assignedServerConnectionError => 'Greška konekcije sa serverom.';

  @override
  String get assignedNotSpecified => 'Nije navedeno';

  @override
  String get assignedYes => 'Da';

  @override
  String get assignedNo => 'Ne';

  @override
  String get assignedCarrier => 'Dodijeljeni prijevoznik';

  @override
  String get assignedManual => 'Ručno';

  @override
  String get assignedMachine => 'Strojno';

  @override
  String get assignedHouse => 'Kuća';

  @override
  String get assignedBuilding => 'Zgrada';

  @override
  String get assignedWarehouse => 'Skladište';

  @override
  String get assignedProductionFacility => 'Proizvodni pogon';

  @override
  String get assignedConstructionSite => 'Gradilište';

  @override
  String get assignedBusinessPremises => 'Poslovni prostor';

  @override
  String get assignedConfirming => 'Potvrđujem...';

  @override
  String get assignedTryAgain => 'Pokušaj ponovno';

  @override
  String get assignedGoToLogin => 'Idi na prijavu';

  @override
  String get assignedShipmentNotFound => 'Teret nije pronađen.';

  @override
  String get assignedShipmentAssigned => 'Teret je dodijeljen';

  @override
  String get assignedCarrierDetails => 'Podaci o prijevozniku';

  @override
  String get assignedEmail => 'Email';

  @override
  String get assignedPhone => 'Telefon';

  @override
  String get assignedAcceptedPrice => 'Prihvaćena cijena';

  @override
  String get assignedStatus => 'Status';

  @override
  String get assignedPhoneNotAvailable => 'Telefon još nije dostupan';

  @override
  String get assignedCarrierDetailsUnavailable => 'Ponuda je prihvaćena, ali detalji prijevoznika trenutno nisu dostupni.';

  @override
  String get assignedBasicShipmentDetails => 'Osnovni podaci o teretu';

  @override
  String get assignedShipmentName => 'Naziv tereta';

  @override
  String get assignedDescription => 'Opis';

  @override
  String get assignedLoadingDate => 'Datum utovara';

  @override
  String get assignedLoadingPlace => 'Mjesto utovara';

  @override
  String get assignedLoadingAddress => 'Adresa utovara';

  @override
  String get assignedUnloadingPlace => 'Mjesto istovara';

  @override
  String get assignedUnloadingAddress => 'Adresa istovara';

  @override
  String get assignedDimensionsAndLogistics => 'Dimenzije i logistika';

  @override
  String get assignedWeight => 'Težina (kg/lb)';

  @override
  String get assignedLength => 'Dužina (cm/in)';

  @override
  String get assignedWidth => 'Širina (cm/in)';

  @override
  String get assignedHeight => 'Visina (cm/in)';

  @override
  String get assignedLoadingMethod => 'Način utovara';

  @override
  String get assignedTruckAccess => 'Prilaz za tegljač';

  @override
  String get assignedLoadingLocationType => 'Tip lokacije utovara';

  @override
  String get assignedLoadingFloor => 'Kat utovara';

  @override
  String get assignedLoadingElevator => 'Lift na utovaru';

  @override
  String get assignedDriverHelp => 'Treba li pomoć vozača';

  @override
  String get assignedCustoms => 'Carina';

  @override
  String get assignedShipmentImages => 'Slike tereta';

  @override
  String get availableNotLoggedIn => 'Niste prijavljeni. Prijavite se ponovno.';

  @override
  String get availableFetchError => 'Greška kod dohvaćanja tereta.';

  @override
  String get availableServerConnectionError => 'Greška veze sa serverom';

  @override
  String get availableShipmentFallback => 'Teret';

  @override
  String get availableNew => 'Novo';

  @override
  String get availableClosed => 'Zatvoreno';

  @override
  String get availableWeight => 'Težina';

  @override
  String get availablePallets => 'Palete';

  @override
  String get availableLoadingDeadline => 'Rok utovara';

  @override
  String get availableOpenDetails => 'Otvori detalje';

  @override
  String get availableNoShipments => 'Trenutno nema dostupnih tereta.';

  @override
  String get availableNewShipmentsAppearHere => 'Kad se objave novi tereti, prikazat će se ovdje.';

  @override
  String get availableShipmentsTitle => 'Dostupni tereti';

  @override
  String availableActiveListings(int count) {
    return '$count aktivnih objava';
  }

  @override
  String get availableOpenAndSendOffer => 'Otvorite teret i pošaljite svoju ponudu.';

  @override
  String get availableMyOffers => 'Moje ponude';

  @override
  String get availableLogout => 'Odjava';

  @override
  String get shipmentListTitle => 'Lista tereta';

  @override
  String get shipmentFetchError => 'Greška pri dohvaćanju tereta.';

  @override
  String auctionEndsInHours(int hours, int minutes) {
    return 'Još ${hours}h ${minutes}min do isteka licitacije';
  }

  @override
  String auctionEndsInMinutes(int minutes) {
    return 'Još ${minutes}min do isteka licitacije';
  }

  @override
  String auctionDurationHours(int hours) {
    String _temp0 = intl.Intl.pluralLogic(
      hours,
      locale: localeName,
      other: '$hours sata',
      one: '1 sat',
    );
    return '$_temp0';
  }

  @override
  String get machineLoadingUppercase => 'STROJNO';

  @override
  String get manualLoadingUppercase => 'RUČNO';

  @override
  String get newUppercase => 'NOVO';

  @override
  String get acceptedUppercase => 'PRIHVAĆENO';

  @override
  String get finishedUppercase => 'ZAVRŠENA';

  @override
  String get activeUppercase => 'AKTIVAN';

  @override
  String auctionDurationBadge(String duration) {
    return 'Licitacija $duration';
  }

  @override
  String offersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ponuda',
      one: '1 ponuda',
      zero: '0 ponuda',
    );
    return '$_temp0';
  }

  @override
  String get cargo => 'Teret';

  @override
  String approximateWeight(String weight) {
    return 'cca $weight kg';
  }

  @override
  String publishedDate(String date) {
    return 'Objavljeno $date';
  }

  @override
  String acceptedOfferPrice(String price) {
    return 'Prihvaćena ponuda: $price';
  }

  @override
  String currentLowestOfferPrice(String price) {
    return 'Trenutna najniža ponuda: $price';
  }

  @override
  String get viewDetails => 'Pogledaj detalje';

  @override
  String get noShipmentsAvailable => 'Trenutno nema dostupnih tereta.';

  @override
  String get newShipmentsWillAppear => 'Novi tereti pojavit će se ovdje čim ih naručitelji objave.';

  @override
  String get notificationsTitle => 'Obavijesti';

  @override
  String get manageNotifications => 'Upravljanje obavijestima';

  @override
  String get notificationsFetchError => 'Greška pri dohvaćanju obavijesti.';

  @override
  String get deleteReadNotificationsTitle => 'Obrisati pročitane obavijesti?';

  @override
  String get deleteReadNotificationsMessage => 'Sve pročitane obavijesti bit će uklonjene iz prikaza.';

  @override
  String get deleteAllNotificationsTitle => 'Obrisati sve obavijesti?';

  @override
  String get deleteAllNotificationsMessage => 'Sve obavijesti bit će uklonjene iz prikaza.';

  @override
  String get readNotificationsDeleted => 'Pročitane obavijesti su obrisane.';

  @override
  String get allNotificationsDeleted => 'Sve obavijesti su obrisane.';

  @override
  String get deletionFailed => 'Brisanje nije uspjelo.';

  @override
  String get delete => 'Obriši';

  @override
  String get notificationNewShipment => 'Novi teret';

  @override
  String get notificationNewOffer => 'Nova ponuda';

  @override
  String get notificationUpdatedOffer => 'Ažurirana ponuda';

  @override
  String get notificationOfferOutbid => 'Ponuda više nije najniža';

  @override
  String get notificationJobWon => '🏆 Dobili ste posao';

  @override
  String get notificationAuctionFinished => 'Licitacija je završena';

  @override
  String get notificationJobWonCelebration => '🎉 Dobili ste posao';

  @override
  String get notificationConnected => '🤝 TeReT vas je povezao';

  @override
  String get notificationDeliveryConfirmed => '✅ Prijevoz potvrđen';

  @override
  String get notification => 'Obavijest';

  @override
  String get justNow => 'Upravo sada';

  @override
  String minutesAgo(int minutes) {
    return 'Prije $minutes min';
  }

  @override
  String hoursAgo(int hours) {
    return 'Prije $hours h';
  }

  @override
  String get notificationDeletionFailed => 'Brisanje obavijesti nije uspjelo.';

  @override
  String get notificationDeleted => 'Obavijest je obrisana.';

  @override
  String get noNotifications => 'Nema obavijesti';

  @override
  String get notificationsEmptyDescription => 'Nove ponude, prihvati i promjene prikazat će se ovdje.';

  @override
  String get deleteReadNotifications => 'Obriši pročitane';

  @override
  String get deleteAllNotifications => 'Obriši sve obavijesti';

  @override
  String notificationNewShipmentMessage(String route) {
    return 'Objavljen je novi teret: $route';
  }

  @override
  String get notificationNewShipmentMessageWithoutRoute => 'Objavljen je novi teret.';

  @override
  String get notificationNewOfferMessage => 'Primili ste novu ponudu za svoj teret.';

  @override
  String get notificationUpdatedOfferMessage => 'Prijevoznik je ažurirao svoju ponudu.';

  @override
  String get notificationOfferOutbidMessage => 'Vaša ponuda više nije najniža. Pošaljite novu ponudu kako biste ostali konkurentni.';

  @override
  String get notificationOfferAcceptedMessage => 'Vaša ponuda je prihvaćena. Otvorite detalje tereta za nastavak.';

  @override
  String get notificationOfferRejectedMessage => 'Drugi prijevoznik je odabran za ovaj prijevoz.';

  @override
  String get notificationContactUnlockedMessage => 'Kontakt podaci su otključani. Otvorite detalje tereta.';

  @override
  String get notificationCarrierConnectedMessage => 'TeReT vas je povezao s odabranim prijevoznikom.';

  @override
  String get notificationDeliveryConfirmedMessage => 'Naručitelj je potvrdio završetak prijevoza.';

  @override
  String get deliveryConfirmationTitle => 'Potvrda dostave';

  @override
  String get shipmentLoadingError => 'Greška kod učitavanja tereta.';

  @override
  String get deliveryConfirmedSuccessfully => 'Dostava je uspješno potvrđena.';

  @override
  String get deliveryConfirmationError => 'Greška kod potvrde dostave.';

  @override
  String get confirmDeliveryDialogTitle => 'Potvrda dostave';

  @override
  String get confirmDeliveryDialogMessage => 'Jeste li sigurni da je teret uspješno dostavljen na odredište?';

  @override
  String get shipmentData => 'Podaci o teretu';

  @override
  String get loadingDate => 'Datum utovara';

  @override
  String get phone => 'Telefon';

  @override
  String get phoneNotAvailable => 'Telefon nije dostupan';

  @override
  String get agreedPrice => 'Dogovorena cijena';

  @override
  String get transportStatus => 'Status prijevoza';

  @override
  String get deliveryConfirmed => 'Dostava je potvrđena';

  @override
  String get shipmentInTransit => 'Teret u prijevozu';

  @override
  String get waitingDeliveryConfirmation => 'Čeka se potvrda dostave od naručitelja';

  @override
  String get transportCompletedMessage => 'Prijevoz je završen i potvrđen. Sljedeći korak može biti ocjenjivanje prijevoznika.';

  @override
  String get confirmDeliveryInfo => 'Ako je teret stigao na odredište, kliknite na potvrdu dostave. Time se posao označava kao završen.';

  @override
  String get confirmDeliveryButton => 'POTVRDI DOSTAVU';

  @override
  String get goToMyShipments => 'IDI NA MOJE TERETE';

  @override
  String get tryAgain => 'Pokušaj ponovno';

  @override
  String get myOffersTitle => 'Moje ponude';

  @override
  String get myOffersRefresh => 'Osvježi';

  @override
  String get myOffersNotLoggedIn => 'Niste prijavljeni. Prijavite se ponovno.';

  @override
  String get myOffersSessionExpired => 'Sesija je istekla. Prijavite se ponovno.';

  @override
  String get myOffersFetchError => 'Greška pri dohvaćanju mojih ponuda.';

  @override
  String get myOffersConnectionError => 'Greška konekcije sa serverom.';

  @override
  String get myOffersRemoveFromHistoryTitle => 'Ukloniti iz povijesti?';

  @override
  String get myOffersRemoveFromHistoryMessage => 'Ponuda će nestati iz vašeg popisa, ali neće biti trajno obrisana iz sustava.';

  @override
  String get myOffersCancel => 'Odustani';

  @override
  String get myOffersRemove => 'Ukloni';

  @override
  String get myOffersRemovedFromHistory => 'Ponuda je uklonjena iz povijesti.';

  @override
  String get myOffersRemoveFailed => 'Uklanjanje nije uspjelo.';

  @override
  String get myOffersStatusFinished => 'Završeno';

  @override
  String get myOffersStatusAccepted => 'Prihvaćena';

  @override
  String get myOffersStatusLowest => 'Najniža';

  @override
  String get myOffersStatusOutbid => 'Nadmašena';

  @override
  String get myOffersShipmentPrefix => 'Teret';

  @override
  String get myOffersShipmentActive => 'Aktivan';

  @override
  String get myOffersShipmentOfferAccepted => 'Ponuda prihvaćena';

  @override
  String get myOffersShipmentUsersConnected => 'Korisnici povezani';

  @override
  String get myOffersShipmentAuctionEnded => 'Licitacija završena';

  @override
  String get myOffersDefaultShipmentName => 'Teret';

  @override
  String get myOffersMyOffer => 'Moja ponuda';

  @override
  String get myOffersOffersCount => 'Broj ponuda';

  @override
  String get myOffersLoading => 'Utovar';

  @override
  String get myOffersByAgreement => 'Po dogovoru';

  @override
  String get myOffersWeight => 'Težina';

  @override
  String get myOffersMyMessage => 'Moja poruka';

  @override
  String get myOffersAcceptedUnlockContact => '🔒 Ponuda je prihvaćena. Otvori detalje tereta i otključaj kontakt.';

  @override
  String get myOffersContactUnlocked => 'Kontakt otključan — možete započeti dogovor.';

  @override
  String get myOffersSendNewOffer => 'Pošalji novu ponudu';

  @override
  String get myOffersOtherCarrierSelected => 'Drugi prijevoznik je odabran za ovaj prijevoz.';

  @override
  String get myOffersRemoveFromHistory => 'Ukloni iz povijesti';

  @override
  String get myOffersTryAgain => 'Pokušaj ponovno';

  @override
  String get myOffersEmptyTitle => 'Još niste poslali nijednu ponudu.';

  @override
  String get myOffersEmptyDescription => 'Kad pošaljete ponudu za neki teret, ovdje će biti prikazane sve vaše ponude.';

  @override
  String get ratingScreenTitle => 'Ocijeni prijevoz';

  @override
  String get ratingSelectBetweenOneAndFive => 'Molimo odaberite ocjenu od 1 do 5.';

  @override
  String get ratingSubmittedSuccessfully => 'Ocjena je uspješno poslana.';

  @override
  String get ratingSubmissionError => 'Došlo je do greške kod slanja ocjene.';

  @override
  String get ratingServerConnectionError => 'Greška spajanja na server.';

  @override
  String get ratingVeryPoor => 'Vrlo loše';

  @override
  String get ratingPoor => 'Loše';

  @override
  String get ratingGood => 'Dobro';

  @override
  String get ratingVeryGood => 'Vrlo dobro';

  @override
  String get ratingExcellent => 'Odlično';

  @override
  String get ratingSelectRating => 'Odaberite ocjenu';

  @override
  String get ratingDefaultUserLabel => 'korisnika';

  @override
  String get ratingRateUserPrefix => 'Ocijenite';

  @override
  String get ratingFeedbackHelpsOthers => 'Vaša povratna informacija pomaže drugim korisnicima.';

  @override
  String get ratingCommentOptional => 'Komentar (opcionalno)';

  @override
  String get ratingCommentHint => 'Npr. sve uredno i na vrijeme...';

  @override
  String get ratingSubmitButton => 'Pošalji ocjenu';

  @override
  String get aboutAppTitle => 'Info';

  @override
  String get aboutAppDescription => 'Digitalna platforma za objavu tereta, slanje ponuda i jednostavniji dogovor prijevoza.';

  @override
  String get aboutAppPurposeTitle => 'Svrha aplikacije';

  @override
  String get aboutAppPurposeText => 'TeReT povezuje naručitelje prijevoza i prijevoznike na jednom mjestu. Naručitelj objavljuje teret, a prijevoznici šalju svoje ponude.';

  @override
  String get aboutAppAuctionTitle => 'Licitacija prijevoza';

  @override
  String get aboutAppAuctionText => 'Prijevoznici mogu dati ponudu za objavljeni teret, a naručitelj bira ponudu koja mu najviše odgovara.';

  @override
  String get aboutAppContactProtectionTitle => 'Zaštita kontakta';

  @override
  String get aboutAppContactProtectionText => 'Kontakt podaci nisu javno dostupni. Broj telefona i puni podaci prikazuju se tek nakon prihvaćanja ponude i otključavanja kontakta.';

  @override
  String get aboutAppPrivacyTitle => 'Sigurnost i privatnost';

  @override
  String get aboutAppPrivacyText => 'Aplikacija je napravljena tako da štiti podatke korisnika i prikazuje samo informacije potrebne za dogovor prijevoza.';

  @override
  String get aboutAppSupportTitle => 'Korisnička podrška';

  @override
  String get aboutAppSupportText => 'Za pomoć, prijavu problema ili pitanja možete kontaktirati podršku na: teretmegs@gmail.com';

  @override
  String get aboutAppVersionTitle => 'Verzija aplikacije';

  @override
  String get aboutAppVersionText => 'MVP verzija 1.0.0';

  @override
  String get legalSettingsTitle => 'Postavke i informacije';

  @override
  String get legalSettingsTermsTitle => 'Uvjeti korištenja';

  @override
  String get legalSettingsTermsSubtitle => 'Pravila korištenja platforme TeReT';

  @override
  String get legalSettingsPrivacyTitle => 'Pravila privatnosti';

  @override
  String get legalSettingsPrivacySubtitle => 'Zaštita i obrada podataka korisnika';

  @override
  String get legalSettingsContactTitle => 'Kontakt';

  @override
  String get legalSettingsContactSubtitle => 'Kontakt informacije i podrška';

  @override
  String get legalSettingsAboutTitle => 'O aplikaciji';

  @override
  String get legalSettingsAboutSubtitle => 'Informacije o TeReT aplikaciji';

  @override
  String get termsTitle => 'Uvjeti korištenja';

  @override
  String get termsGeneralTitle => '1. Opće odredbe';

  @override
  String get termsGeneralText => 'TeReT je digitalna platforma koja povezuje naručitelje prijevoza i prijevoznike. TeReT ne sudjeluje u organizaciji niti izvršenju prijevoza, već omogućuje korisnicima međusobno povezivanje i dogovor.';

  @override
  String get termsPlatformRoleTitle => '2. Uloga platforme';

  @override
  String get termsPlatformRoleText => 'TeReT nije prijevoznik niti špediter. TeReT ne djeluje kao ugovorna strana u prijevozu te ne preuzima odgovornost za izvršenje prijevoza, kašnjenja, otkazivanja, štetu na robi ili netočne podatke korisnika niti sporove između korisnika. Svi dogovori o prijevozu sklapaju se isključivo između naručitelja i prijevoznika.';

  @override
  String get termsFeeTitle => '3. Naknada za korištenje platforme';

  @override
  String get termsFeeText => 'Platforma TeReT potpuno je besplatna za korištenje i nema nikakve članarine ni kotizacije. Naknada se plaća isključivo po zaključenom poslu, odnosno kada naručitelj prihvati ponudu prijevoznika. Iznosi 7% od dogovorene cijene prijevoza i plaća je samo prijevoznik, a za dogovorene prijevoze u vrijednosti do 100,00 € naknada iznosi 5,00 €.';

  @override
  String get termsUnlockContactTitle => '4. Otključavanje kontakt podataka';

  @override
  String get termsUnlockContactText => 'Kontakt podaci naručitelja i prijevoznika dostupni su tek nakon uspješne naplate naknade putem Stripe sustava. Nakon otključavanja kontakt podataka smatra se da je usluga platforme izvršena.';

  @override
  String get termsRefundTitle => '5. Povrat naknade';

  @override
  String get termsRefundText => 'Nakon otključavanja kontakt podataka plaćena naknada se ne vraća. Naknada se odnosi na uslugu povezivanja korisnika putem platforme TeReT, neovisno o tome je li prijevoz kasnije realiziran.';

  @override
  String get termsCancellationTitle => '6. Otkazivanje prijevoza';

  @override
  String get termsCancellationText => 'U slučaju otkazivanja prijevoza od strane naručitelja ili prijevoznika, TeReT ne snosi nikakvu odgovornost za posljedice otkazivanja. Korisnici su sami odgovorni za međusobne dogovore, troškove, štetu, kašnjenja ili druge posljedice koje mogu nastati zbog otkazivanja. Ako je naknada za korištenje platforme već plaćena i kontakt podaci su otključani, naknada se ne vraća jer se smatra da je usluga povezivanja putem platforme izvršena.';

  @override
  String get termsTransportResponsibilityTitle => '7. Odgovornost za prijevoz';

  @override
  String get termsTransportResponsibilityText => 'Za izvršenje prijevoza, stanje robe, vrijeme isporuke i sve ostale detalje odgovorni su isključivo naručitelj i prijevoznik. TeReT ne sudjeluje u prijevozu niti preuzima odgovornost za eventualnu štetu.';

  @override
  String get privacyTitle => 'Pravila privatnosti';

  @override
  String get privacySection1Title => '1. Prikupljanje podataka';

  @override
  String get privacySection1Text => 'TeReT prikuplja osnovne podatke korisnika potrebne za korištenje platforme, uključujući ime i prezime, broj telefona, email adresu te podatke o prijevozu i objavljenim teretima.';

  @override
  String get privacySection2Title => '2. Korištenje podataka';

  @override
  String get privacySection2Text => 'Prikupljeni podaci koriste se isključivo za omogućavanje komunikacije između naručitelja prijevoza i prijevoznika te za funkcioniranje platforme.';

  @override
  String get privacySection3Title => '3. Dijeljenje podataka';

  @override
  String get privacySection3Text => 'Kontakt podaci korisnika nisu javno dostupni. Podaci se otključavaju tek nakon prihvaćanja ponude i uspješne naplate platforme.';

  @override
  String get privacySection4Title => '4. Sigurnost podataka';

  @override
  String get privacySection4Text => 'TeReT poduzima razumne tehničke i organizacijske mjere kako bi zaštitio korisničke podatke od neovlaštenog pristupa, gubitka ili zlouporabe.';

  @override
  String get privacySection5Title => '5. Email verifikacija';

  @override
  String get privacySection5Text => 'Radi sigurnosti i zaštite korisnika, TeReT koristi verifikaciju email adrese prilikom registracije računa.';

  @override
  String get privacySection6Title => '6. Kolačići i tehnički podaci';

  @override
  String get privacySection6Text => 'Aplikacija može prikupljati tehničke podatke potrebne za rad sustava, sigurnost i poboljšanje korisničkog iskustva.';

  @override
  String get privacySection7Title => '7. Prava korisnika';

  @override
  String get privacySection7Text => 'Korisnici imaju pravo zatražiti izmjenu ili brisanje svojih podataka u skladu s važećim zakonima i pravilima zaštite privatnosti.';

  @override
  String get privacySection8Title => '8. Kontakt';

  @override
  String get privacySection8Text => 'Za sva pitanja vezana uz privatnost i zaštitu podataka korisnici se mogu obratiti putem kontakt opcije unutar aplikacije.';

  @override
  String get contactSupportTitle => 'Korisnička podrška';

  @override
  String get contactSupportHeading => 'Kontakt i podrška';

  @override
  String get contactSupportDescription => 'Za pitanja, probleme s računom ili prijavu poteškoća u radu aplikacije možete se obratiti podršci.';

  @override
  String get contactSupportEmailTitle => 'Email podrška';

  @override
  String get contactSupportResponseTimeTitle => 'Vrijeme odgovora';

  @override
  String get contactSupportResponseTimeText => 'Na upite odgovaramo u najkraćem mogućem roku.';

  @override
  String get contactSupportMessageInfoTitle => 'Što navesti u poruci';

  @override
  String get contactSupportMessageInfoText => 'Kod prijave problema navedite email računa, opis problema i po mogućnosti screenshot greške.';

  @override
  String get contactSupportEmailSubject => 'Podrška - TeReT';

  @override
  String get newOffer => 'Nova ponuda';

  @override
  String get enterRequestedTransportPrice => 'Unesite cijenu koju tražite za prijevoz.';

  @override
  String get noCurrentOfferForAutomaticReduction => 'Nema trenutne ponude za automatsko sniženje.';

  @override
  String get offerAmountMustBeGreaterThanZero => 'Iznos ponude mora biti veći od 0.';

  @override
  String get noLowestOfferForShipment => 'Još nema najniže ponude za ovaj teret.';

  @override
  String get notLoggedInLoginAgain => 'Niste prijavljeni. Prijavite se ponovno.';

  @override
  String get enterValidOfferAmount => 'Unesite ispravan iznos ponude.';

  @override
  String get offerSuccessfullySent => 'Ponuda je uspješno poslana.';

  @override
  String get errorSendingOffer => 'Greška pri slanju ponude.';

  @override
  String get loadingCurrentLowestOffer => 'Učitavam trenutnu najnižu ponudu...';

  @override
  String get noOffersForShipmentYet => 'Još nema ponuda za ovaj teret.';

  @override
  String get currentLowestOfferUnavailable => 'Trenutna najniža ponuda: -';

  @override
  String currentLowestOffer(String amount) {
    return 'Trenutna najniža ponuda: $amount';
  }

  @override
  String get yourOfferNotSubmitted => 'Vaša ponuda: još niste poslali ponudu';

  @override
  String yourOffer(String amount) {
    return 'Vaša ponuda: $amount';
  }

  @override
  String get yourOfferIsCurrentlyLowest => 'Vaša ponuda je trenutno najniža.';

  @override
  String newOfferMinimumLower(String currency) {
    return 'Nova ponuda mora biti niža barem 5 $currency od trenutne najniže ponude.';
  }

  @override
  String get offerBindingNotice => 'Napomena: slanjem ponude obvezujete se na izvršenje prijevoza ako naručitelj prihvati vašu ponudu.';

  @override
  String get currency => 'Valuta';

  @override
  String get euroCurrency => 'Euro (€)';

  @override
  String get usDollarCurrency => 'Američki dolar (\$)';

  @override
  String get britishPoundCurrency => 'Britanska funta (£)';

  @override
  String get canadianDollarCurrency => 'Kanadski dolar (C\$)';

  @override
  String get australianDollarCurrency => 'Australski dolar (A\$)';

  @override
  String offerAmount(String currency) {
    return 'Iznos ponude ($currency)';
  }

  @override
  String get enterAmount => 'Unesite iznos';

  @override
  String get enterOfferAmount => 'Unesite iznos ponude';

  @override
  String get enterValidNumber => 'Unesite ispravan broj';

  @override
  String get amountMustBeGreaterThanZero => 'Iznos mora biti veći od 0';

  @override
  String get offerMustBeLowerThanCurrentLowest => 'Ponuda mora biti niža od trenutne najniže ponude';

  @override
  String minimumOfferReduction(String currency) {
    return 'Minimalno sniženje ponude je 5 $currency';
  }

  @override
  String get setAsLowestOffer => 'Postavi kao najnižu';

  @override
  String get messageToCustomerOptional => 'Poruka naručitelju (nije obavezno)';

  @override
  String get enterShortMessage => 'Upišite kratku poruku...';

  @override
  String get nearLoadingLocationNotice => 'Ako ste blizu mjesta utovara i teret možete preuzeti odmah, navedite to u poruci uz ponudu. Brz dolazak može biti presudan pri odabiru prijevoznika.';

  @override
  String get checkShipmentData => 'Provjera podataka';

  @override
  String get checkShipmentDataMessage => 'Molimo da prije objave tereta još jednom provjerite sve unesene podatke.\n\nNakon objave teret će biti vidljiv prijevoznicima i neće ga biti moguće uređivati.';

  @override
  String get shipmentPublishedSuccessMessage => '✅ Teret je uspješno objavljen.\n\nNe morate čekati završetak licitacije. Ponudu možete prihvatiti u bilo kojem trenutku čim pronađete prijevoznika koji vam odgovara.';

  @override
  String get notificationPermissionMainMessage => '🔔 Kako bi TeReT ispravno funkcionirao, obavezno omogućite obavijesti u postavkama svog mobitela.';

  @override
  String get notificationPermissionDetails => 'Tako ćete na vrijeme primati nove ponude, obavijesti o licitacijama i druge važne informacije.';

  @override
  String get notificationPermissionStillDisabled => 'Obavijesti još nisu omogućene. Pritisnite gumb ponovno kako biste otvorili postavke.';

  @override
  String get notificationSettingsCouldNotOpen => 'Postavke nije bilo moguće otvoriti. Otvorite postavke mobitela i omogućite obavijesti za TeReT.';

  @override
  String get enableNotificationsInSettings => 'Uključite obavijesti u postavkama';

  @override
  String get checkingNotifications => 'Provjera obavijesti...';

  @override
  String get enableNotificationsButton => 'Omogući obavijesti';

  @override
  String get returnAfterEnablingNotifications => 'Nakon uključivanja obavijesti vratite se u TeReT. Aplikacija će automatski nastaviti.';

  @override
  String get sevenDays => '7 dana';

  @override
  String get auctionFinishedChooseCarrier => 'Licitacija je završena — odaberite prijevoznika';

  @override
  String get chooseCarrier => 'Odaberi prijevoznika';

  @override
  String get reliability => 'Pouzdanost';

  @override
  String get noReliabilityMisses => 'Bez zabilježenih propusta';

  @override
  String senderNoSelectionInTime(Object count) {
    return 'Nije odabrao prijevoznika u roku: $count';
  }

  @override
  String carrierNoPaymentInTime(Object count) {
    return 'Nije platio naknadu u roku: $count';
  }

  @override
  String get userProfile => 'Profil korisnika';

  @override
  String get userComments => 'Komentari korisnika';

  @override
  String reliabilityMissesCount(int count) {
    return '$count zabilježenih propusta';
  }
}
