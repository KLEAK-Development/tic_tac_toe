import 'dart:io';
import 'package:image/image.dart';

void main() {
  // Create a 512x512 image
  final image = Image(width: 512, height: 512);

  // Colors
  final bgColor = ColorRgba8(33, 37, 41, 255); // Dark background
  final gridColor = ColorRgba8(73, 80, 87, 255);
  final xColor = ColorRgba8(255, 107, 107, 255); // Red/Pink
  final oColor = ColorRgba8(51, 154, 240, 255); // Blue

  // Fill background
  fill(image, color: bgColor);

  // Draw Grid
  const width = 16;
  const padding = 100;

  // Vertical lines
  drawLine(
    image,
    x1: 190,
    y1: padding,
    x2: 190,
    y2: 512 - padding,
    color: gridColor,
    thickness: width,
  );
  drawLine(
    image,
    x1: 322,
    y1: padding,
    x2: 322,
    y2: 512 - padding,
    color: gridColor,
    thickness: width,
  );

  // Horizontal lines
  drawLine(
    image,
    x1: padding,
    y1: 190,
    x2: 512 - padding,
    y2: 190,
    color: gridColor,
    thickness: width,
  );
  drawLine(
    image,
    x1: padding,
    y1: 322,
    x2: 512 - padding,
    y2: 322,
    color: gridColor,
    thickness: width,
  );

  // Draw X (Center)
  const xCenter = 256;
  const xSize = 50;
  drawLine(
    image,
    x1: xCenter - xSize,
    y1: xCenter - xSize,
    x2: xCenter + xSize,
    y2: xCenter + xSize,
    color: xColor,
    thickness: width,
  );
  drawLine(
    image,
    x1: xCenter + xSize,
    y1: xCenter - xSize,
    x2: xCenter - xSize,
    y2: xCenter + xSize,
    color: xColor,
    thickness: width,
  );

  // Draw O (Top Right)
  const oCenterX = 380;
  const oCenterY = 130;
  const oRadius = 35;
  drawCircle(image, x: oCenterX, y: oCenterY, radius: oRadius, color: oColor);
  // Fill inner circle to make it look like a ring (simple way since drawCircle is filled or 1px)
  // Actually drawCircle in 'image' package might be 1px outline.
  // Let's use fillCircle and then fill a smaller circle with bg color.
  fillCircle(
    image,
    x: oCenterX,
    y: oCenterY,
    radius: oRadius + (width ~/ 2),
    color: oColor,
  );
  fillCircle(
    image,
    x: oCenterX,
    y: oCenterY,
    radius: oRadius - (width ~/ 2),
    color: bgColor,
  );

  // Draw O (Bottom Left)
  const oCenterX2 = 130;
  const oCenterY2 = 380;
  fillCircle(
    image,
    x: oCenterX2,
    y: oCenterY2,
    radius: oRadius + (width ~/ 2),
    color: oColor,
  );
  fillCircle(
    image,
    x: oCenterX2,
    y: oCenterY2,
    radius: oRadius - (width ~/ 2),
    color: bgColor,
  );

  // Ensure directory exists
  final directory = Directory('assets/images');
  if (!directory.existsSync()) {
    directory.createSync(recursive: true);
  }

  // Save the image
  final png = encodePng(image);
  File('assets/images/logo.png').writeAsBytesSync(png);
  print('Logo generated at assets/images/logo.png');
}
