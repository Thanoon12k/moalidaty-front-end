class GlobalConstants {
  static const String baseAddress = "https://moalidty.pythonanywhere.com";

  static double globalScreenWidth = 0; //set from main.dart
  static double globalScreenHeight = 0; //set from main.dart

  static double scaleTo(double wantedValue) =>
      globalScreenWidth / scaleRatios[wantedValue]!;

  static int limits_edges = 16;
  static double get unit => globalScreenHeight / 100;
  static double get padding => 12;
  static double get borderRadious => 12;
  static double get fontSmall => unit * 2;
  static double get fontMedian => unit * 3;
  static double get fontLarge => unit * 4;
  static double get iconSize => unit * 5;
  static double get buttonHeight => unit * 12;
  static double get borderRadius => unit * 2;
  static double get fontInsideCirclesSize => unit * 3;
  static double get paddingListSize => unit * 2;
  static double get indexescircleRadious => unit * 3.6;
  static double get sizedBoxWidth => unit * 2.32;
  static double get sizedBoxHeight => unit * 1.03;
  static get fontSizeName => unit * 3.6;
  static get fontSizePhone => unit * 2.835;
  static get buttomNavigationBarHeight => unit * 7.73;
  static get ButtomNavigationBarTextSize => unit * 3.09;

  static double get ScreenWidth => globalScreenWidth - limits_edges;

  static double get ScreenHeight => globalScreenHeight - limits_edges;

  static double get screenRatio => globalScreenHeight / globalScreenWidth;
  static Map<double, double> scaleRatios = {
    1: 776.0,
    2: 388.0,
    3: 258.0,
    4: 194.0,
    5: 155.0,
    6: 129.5,
    7: 111.0,
    8: 97.0,
    9: 86.2,
    10: 77.6,
    11: 70.5,
    12: 64.6,
    13: 59.6,
    14: 55.0,
    15: 50.8,
    16: 48.5, // original
    17: 45.7,
    18: 43.0,
    19: 40.8,
    20: 38.5, // original
    21: 36.6,
    22: 34.8,
    23: 33.5,
    24: 32.33, // original
    25: 31.0,
    26: 29.6,
    27: 28.4,
    28: 27.3,
    29: 26.3,
    30: 25.3,
    31: 24.7,
    32: 24.25, // original
    33: 23.7,
    34: 23.2,
    35: 22.7,
    36: 22.3,
  };
}
