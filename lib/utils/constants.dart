import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:intl/intl.dart';


// Just for demo
const productDemoImg1 = "https://i.imgur.com/CGCyp1d.png";
const productDemoImg2 = "https://i.imgur.com/AkzWQuJ.png";
const productDemoImg3 = "https://i.imgur.com/J7mGZ12.png";
const productDemoImg4 = "https://i.imgur.com/q9oF9Yq.png";
const productDemoImg5 = "https://i.imgur.com/MsppAcx.png";
const productDemoImg6 = "https://i.imgur.com/JfyZlnO.png";

// End For demo

const grandisExtendedFont = "Grandis Extended";


// On color 80, 60.... those means opacity

const Color primaryColor = Colors.grey;

const MaterialColor primaryMaterialColor =
    MaterialColor(0xFF9581FF, <int, Color>{
  50: Color(0xFFEFECFF),
  100: Color(0xFFD7D0FF),
  200: Color(0xFFBDB0FF),
  300: Color(0xFFA390FF),
  400: Color(0xFF8F79FF),
  500: Color(0xFF7B61FF),
  600: Color(0xFF7359FF),
  700: Color(0xFF684FFF),
  800: Color(0xFF5E45FF),
  900: Color(0xFF6C56DD),
});

const Color blackColor = Color(0xFF16161E);
const Color blackColor80 = Color(0xFF45454B);
const Color blackColor60 = Color(0xFF737378);
const Color blackColor40 = Color(0xFFA2A2A5);
const Color blackColor20 = Color(0xFFD0D0D2);
const Color blackColor10 = Color(0xFFE8E8E9);
const Color blackColor5 = Color(0xFFF3F3F4);

const Color whiteColor = Colors.white;
const Color whileColor80 = Color(0xFFCCCCCC);
const Color whileColor60 = Color(0xFF999999);
const Color whileColor40 = Color(0xFF666666);
const Color whileColor20 = Color(0xFF333333);
const Color whileColor10 = Color(0xFF191919);
const Color whileColor5 = Color(0xFF0D0D0D);

const Color greyColor = Color(0xFFB8B5C3);
const Color lightGreyColor = Color(0xFFF8F8F9);
const Color darkGreyColor = Color(0xFF1C1C25);
// const Color greyColor80 = Color(0xFFC6C4CF);
// const Color greyColor60 = Color(0xFFD4D3DB);
// const Color greyColor40 = Color(0xFFE3E1E7);
// const Color greyColor20 = Color(0xFFF1F0F3);
// const Color greyColor10 = Color(0xFFF8F8F9);
// const Color greyColor5 = Color(0xFFFBFBFC);

const Color purpleColor = Color(0xFF7B61FF);
const Color successColor = Color(0xFF2ED573);
const Color warningColor = Color(0xFFFFBE21);
const Color errorColor = Color(0xFFEA5B5B);

const double defaultPadding = 16.0;
const double defaultBorderRadious = 12.0;
const Duration defaultDuration = Duration(milliseconds: 300);

final passwordValidator = MultiValidator([
  RequiredValidator(errorText: 'Password is required'),
  MinLengthValidator(8, errorText: 'password must be at least 8 digits long'),
  PatternValidator(r'(?=.*?[#?!@$%^&*-])',
      errorText: 'passwords must have at least one special character')
]);

final emaildValidator = MultiValidator([
  RequiredValidator(errorText: 'Email is required'),
  EmailValidator(errorText: "Enter a valid email address"),
]);

final firstNameValidator = RequiredValidator(errorText: "First name is Required");
final lastNameValidator = RequiredValidator(errorText: "Last name is Required");
final phoneValidator= RequiredValidator(errorText: "Phone is Required");

const pasNotMatchErrorText = "passwords do not match";
const TextStyle loginTiltle = TextStyle(
    fontSize: 35,
    color: primaryMaterialColor,
    fontWeight: FontWeight.w900);

class AnimationConstants {
  // static String loading = "assets/animations/loading_animation.json";
  static String loading = "assets/animations/unloaking_animation.json";
  static String loading2 = "assets/animations/loading_animation.json";
}


class ColorConstants {
  static Color primaryWhiteColor = Colors.white;
  static Color secondaryWhiteColor = const Color(0xFFF7F8FB);
  static Color secondaryWhiteColor2 = const Color(0xFFCBCDD5);
  static Color primaryBlackColor = Colors.black;
  static Color primaryColor = const Color(0xff114F5A);
  static Color secondaryColor1 = const Color(0xffafddec);
  static Color secondaryColor2 = const Color(0xff5f6f76);
  static Color secondaryColor3 = const Color(0xffA0B9BD);
  static Color secondaryColor4 = const Color(0x8034536d);
  static Color secondaryColor5 = const Color(0xf083A3AA);
  static Color colorRed = const Color(0xFFFF7676);
  static Color colorGrey = const Color(0xFFA4A4A4);
  static Color roomsCircleAvatarColor = const Color(0x80002661);
  static Color bedCircleAvtarColor = const Color(0xFFD9D9D9);
  static Color roomsBlackColor = const Color(0xFF222222);
  static Color colorGreen = const Color(0xFF2F573D);
}

class ImageConstants {
  static String appLogo = "assets/images/milverton.png";
  static String googleLogo = "assets/images/google log.png";
  static String appleLogo = "assets/images/apple logo.png";

  //onboarding screen images
  static String onBoardingImage1 = "assets/images/onboarding_image1.png";
  static String onBoardingImage2 = "assets/images/onboarding_image2.png";
  static String onBoardingImage3 = "assets/images/onboarding_image3.png";

  static String ownerHomeProfilePhoto2 = "assets/images/profile photo 2.png";
  static String ownerHomeProfilePhoto3 = "assets/images/profile photo 3.png";
  static String calenderIcon = "assets/images/calender Icon.png";

  static String moneyIcon = "assets/images/money icon.png";
  static String upRightArrowIcon = "assets/images/arrow-up icon.png";

  static String roomsIcon2 = "assets/images/rooms icon 3.png";
  static String bedIcon2 = "assets/images/bed Icon 2.png";
  static String washingMachineIcon = "assets/images/washing_machine.png";
  static String acIcon = "assets/images/air onditioner icon.png";
  static String bathroomIcon = "assets/images/bathroom icon.png";
  static String wifiIcon = "assets/images/wi-fi icon.png";

  static String hidePasswordIcon = "assets/images/invisibleIcon.png";
  static String passwordIcon = "assets/images/visibleicon.png";
  static String profileImage = "assets/images/profile_image.png";
  static String emptyListImage = "assets/images/emptyListImage.png";
}

class TextStyleConstants {
  //on boarding screen styles
  static TextStyle onboardText1 = TextStyle(
      fontSize: 25,
      color: ColorConstants.primaryColor,
      fontWeight: FontWeight.w700);

  static TextStyle onboardText2 = TextStyle(
      fontSize: 14,
      color: ColorConstants.primaryBlackColor,
      fontWeight: FontWeight.w400);

  static TextStyle onBoardButtonText = TextStyle(
      fontSize: 15,
      color: ColorConstants.primaryWhiteColor,
      fontWeight: FontWeight.w500);

  //login

  static TextStyle loginTiltle = TextStyle(
      fontSize: 35,
      color: ColorConstants.primaryBlackColor,
      fontWeight: FontWeight.w900);

  static TextStyle loginSubtitle1 = TextStyle(
      fontSize: 14,
      color: ColorConstants.colorGrey,
      fontWeight: FontWeight.w500);

  //owner dashboard styles

  static TextStyle homeMainTitle1 = TextStyle(
      fontSize: 19.6,
      color: ColorConstants.primaryColor,
      fontWeight: FontWeight.w400);

  static TextStyle homeMainTitle2 = TextStyle(
      fontSize: 23.5,
      color: ColorConstants.primaryColor,
      fontWeight: FontWeight.w600);

  static TextStyle dashboardVacentRoom1 = TextStyle(
      fontSize: 25,
      color: ColorConstants.primaryColor,
      fontWeight: FontWeight.w900);

  static TextStyle dashboardVacentRoom2 = TextStyle(
      fontSize: 15,
      color: ColorConstants.primaryWhiteColor,
      fontWeight: FontWeight.w600);

  static TextStyle dashboardSubtitle1 = TextStyle(
      fontSize: 20,
      color: ColorConstants.primaryColor,
      fontWeight: FontWeight.w700);

  static TextStyle upComingVaccencyText1 = TextStyle(
      fontSize: 15,
      color: ColorConstants.primaryWhiteColor,
      fontWeight: FontWeight.w500);

  static TextStyle upComingVaccencyText2 = TextStyle(
      fontSize: 20,
      color: ColorConstants.primaryBlackColor,
      fontWeight: FontWeight.w800);

  static TextStyle dashboardSubtitle2 = TextStyle(
      fontSize: 14,
      color: ColorConstants.primaryBlackColor,
      fontWeight: FontWeight.w400);

  static TextStyle dashboardBookingName = TextStyle(
      fontSize: 17,
      color: ColorConstants.primaryBlackColor,
      fontWeight: FontWeight.w600);

  static TextStyle dashboardDate = TextStyle(
      fontSize: 15,
      color: ColorConstants.primaryBlackColor,
      fontWeight: FontWeight.w500);

  static TextStyle dashboardBookinRoomNo = TextStyle(
      fontSize: 17,
      color: ColorConstants.primaryColor,
      fontWeight: FontWeight.w700);

  static TextStyle dashboardPendingDue = TextStyle(
      fontSize: 12,
      color: ColorConstants.colorRed,
      fontWeight: FontWeight.w500);

  static TextStyle dashboardPendingMoney = TextStyle(
      fontSize: 22,
      color: ColorConstants.primaryBlackColor,
      fontWeight: FontWeight.w400);

  static TextStyle buttonText = TextStyle(
      fontSize: 14,
      color: ColorConstants.primaryWhiteColor,
      fontWeight: FontWeight.w500);

  static TextStyle complaintText = TextStyle(
      fontSize: 15,
      color: ColorConstants.primaryColor,
      fontWeight: FontWeight.w500);

  static TextStyle complaintText2 = TextStyle(
      fontSize: 12,
      color: ColorConstants.colorGrey,
      fontWeight: FontWeight.w400);

  //owner rooms
  static TextStyle ownerRoomsCircleAvtarText = TextStyle(
      fontSize: 15,
      color: ColorConstants.primaryWhiteColor,
      fontWeight: FontWeight.w500);

  static TextStyle ownerRoomsText2 = TextStyle(
      fontSize: 13,
      color: ColorConstants.primaryBlackColor,
      fontWeight: FontWeight.w500);

  static TextStyle ownerRoomNumber = TextStyle(
      fontSize: 30,
      color: ColorConstants.primaryBlackColor,
      fontWeight: FontWeight.w800);

  static TextStyle ownerRoomNumber2 = TextStyle(
      fontSize: 20,
      color: ColorConstants.primaryWhiteColor,
      fontWeight: FontWeight.w600);

  static TextStyle ownerRoomNumber3 = TextStyle(
      fontSize: 35,
      color: ColorConstants.primaryWhiteColor,
      fontWeight: FontWeight.w800);

  static TextStyle bookingsJoiningDate = TextStyle(
      fontSize: 13,
      color: ColorConstants.colorGreen,
      fontWeight: FontWeight.w500);

  static TextStyle bookingsRoomNumber = TextStyle(
      fontSize: 18,
      color: ColorConstants.primaryWhiteColor,
      fontWeight: FontWeight.w500);




}
