import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class TextStyles {
  static final titleBig = GoogleFonts.notoSans(
    fontSize: 80,
    fontWeight: FontWeight.w200,
    color: Colors.white,
  );
  static final subtitleLogin = GoogleFonts.notoSans(
    fontSize: 22,
    fontWeight: FontWeight.w400,
    color: AppColors.primary,
  );
  static final welcome = GoogleFonts.notoSans(
    fontSize: 18,
    fontWeight: FontWeight.w400,
    color: Colors.white,
  );
  static final input = GoogleFonts.notoSans(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.primary,
  );
  static final inputFocus = GoogleFonts.notoSans(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.primary,
  );
  static final whiteLabel = GoogleFonts.notoSans(
      fontSize: 15, fontWeight: FontWeight.w400, color: Colors.white);

  static final primaryLabel = GoogleFonts.notoSans(
      fontSize: 15, fontWeight: FontWeight.w400, color: AppColors.primary);
}
