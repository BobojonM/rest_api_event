enum PrinterMode { OFF, EXCEPTIONS, FULL }

class Printer {
  static final Printer _printer = Printer._internal();
  factory Printer() => _printer;
  Printer._internal();

  static PrinterMode mode = PrinterMode.EXCEPTIONS;

  void exception(String message) {
    if (_isPrintAllow(PrinterMode.EXCEPTIONS)) _printException(message);
  }

  void info(String message) {
    if (_isPrintAllow(PrinterMode.FULL)) print(message);
  }

  bool _isPrintAllow(PrinterMode printerMode) =>
      PrinterMode.values.indexOf(printerMode) <=
          PrinterMode.values.indexOf(Printer.mode);

  void _printException(String text) {
    print('\x1B[31m$text\x1B[0m');
  }
}
