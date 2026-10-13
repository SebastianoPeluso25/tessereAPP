import 'package:barcode_widget/barcode_widget.dart';
import 'package:mobile_scanner/mobile_scanner.dart' as scanner;

/// Formati salvati in [CardModel.barcodeFormat].
class CardBarcodeFormat {
  static const code128 = 'CODE128';
  static const code39 = 'CODE39';
  static const code93 = 'CODE93';
  static const codabar = 'CODABAR';
  static const ean13 = 'EAN13';
  static const ean8 = 'EAN8';
  static const upcA = 'UPCA';
  static const upcE = 'UPCE';
  static const itf = 'ITF';
  static const itf14 = 'ITF14';
  static const qr = 'QR';
  static const dataMatrix = 'DATAMATRIX';
  static const pdf417 = 'PDF417';
  static const aztec = 'AZTEC';
}

/// Converte il formato rilevato dalla fotocamera nel formato salvato,
/// così la tessera viene ridisegnata con la stessa simbologia dell'originale.
String formatFromScanner(scanner.BarcodeFormat format) {
  switch (format) {
    case scanner.BarcodeFormat.code39:
      return CardBarcodeFormat.code39;
    case scanner.BarcodeFormat.code93:
      return CardBarcodeFormat.code93;
    case scanner.BarcodeFormat.codabar:
      return CardBarcodeFormat.codabar;
    case scanner.BarcodeFormat.ean13:
      return CardBarcodeFormat.ean13;
    case scanner.BarcodeFormat.ean8:
      return CardBarcodeFormat.ean8;
    case scanner.BarcodeFormat.upcA:
      return CardBarcodeFormat.upcA;
    case scanner.BarcodeFormat.upcE:
      return CardBarcodeFormat.upcE;
    case scanner.BarcodeFormat.itf2of5:
    case scanner.BarcodeFormat.itf2of5WithChecksum:
      return CardBarcodeFormat.itf;
    case scanner.BarcodeFormat.itf14:
      return CardBarcodeFormat.itf14;
    case scanner.BarcodeFormat.qrCode:
    case scanner.BarcodeFormat.microQrCode:
      return CardBarcodeFormat.qr;
    case scanner.BarcodeFormat.dataMatrix:
      return CardBarcodeFormat.dataMatrix;
    case scanner.BarcodeFormat.pdf417:
      return CardBarcodeFormat.pdf417;
    case scanner.BarcodeFormat.aztec:
      return CardBarcodeFormat.aztec;
    default:
      return CardBarcodeFormat.code128;
  }
}

/// Deduce il formato di un codice inserito a mano: EAN se le cifre e la
/// cifra di controllo sono corrette, altrimenti CODE128.
String inferFormat(String data) {
  if (_isDigits(data, 13) && _isValid(Barcode.ean13(), data)) {
    return CardBarcodeFormat.ean13;
  }
  if (_isDigits(data, 8) && _isValid(Barcode.ean8(), data)) {
    return CardBarcodeFormat.ean8;
  }
  return CardBarcodeFormat.code128;
}

/// Restituisce la simbologia con cui disegnare la tessera, oppure `null`
/// se il codice non è rappresentabile.
///
/// Per EAN/UPC si richiede la lunghezza completa: con una cifra in meno il
/// pacchetto `barcode` calcolerebbe una nuova cifra di controllo, generando
/// un numero diverso da quello della tessera.
Barcode? barcodeFor(String format, String data) {
  final Barcode? type = switch (format.toUpperCase()) {
    CardBarcodeFormat.ean13 => _isDigits(data, 13) ? Barcode.ean13() : null,
    CardBarcodeFormat.ean8 => _isDigits(data, 8) ? Barcode.ean8() : null,
    CardBarcodeFormat.upcA => _isDigits(data, 12) ? Barcode.upcA() : null,
    CardBarcodeFormat.upcE => Barcode.upcE(),
    CardBarcodeFormat.code39 => Barcode.code39(),
    CardBarcodeFormat.code93 => Barcode.code93(),
    CardBarcodeFormat.codabar => Barcode.codabar(
        explicitStartStop: RegExp(r'^[A-D].*[A-D]$').hasMatch(data),
      ),
    CardBarcodeFormat.itf => Barcode.itf(),
    CardBarcodeFormat.itf14 =>
      _isDigits(data, 14) ? Barcode.itf14() : Barcode.itf(),
    CardBarcodeFormat.qr => Barcode.qrCode(),
    CardBarcodeFormat.dataMatrix => Barcode.dataMatrix(),
    CardBarcodeFormat.pdf417 => Barcode.pdf417(),
    CardBarcodeFormat.aztec => Barcode.aztec(),
    _ => Barcode.code128(),
  };
  if (type == null || !_isValid(type, data)) return null;
  return type;
}

bool _isDigits(String data, int length) =>
    data.length == length && RegExp(r'^\d+$').hasMatch(data);

bool _isValid(Barcode type, String data) {
  try {
    return type.isValid(data);
  } catch (_) {
    return false;
  }
}
