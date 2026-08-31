import 'package:get/get.dart';
import '../../../core/models/product_model.dart';
import '../../products/domain/repositories/product_repository.dart';
import '../../products/models/product_unit_model.dart';

enum ScannerState {
  idle,
  scanning,
  loading,
  found,
  notFound,
  permissionDenied,
  error,
}

class BarcodeScannerController extends GetxController {
  final ProductRepository _productRepository;

  BarcodeScannerController(this._productRepository);

  ScannerState _state = ScannerState.scanning;
  ProductModel? _scannedProduct;
  ProductUnitModel? _selectedUnit;
  int _selectedUnitIndex = 0;
  String? _lastScannedBarcode;
  String? _errorMessage;
  bool _isTorchOn = false;

  ScannerState get state => _state;
  ProductModel? get scannedProduct => _scannedProduct;
  ProductUnitModel? get selectedUnit => _selectedUnit;
  int get selectedUnitIndex => _selectedUnitIndex;
  String? get lastScannedBarcode => _lastScannedBarcode;
  String? get errorMessage => _errorMessage;
  bool get isTorchOn => _isTorchOn;

  bool get isLoading => _state == ScannerState.loading;

  void toggleTorch() {
    _isTorchOn = !_isTorchOn;
    update();
  }

  void setTorch(bool value) {
    if (_isTorchOn != value) {
      _isTorchOn = value;
      update();
    }
  }

  void reset() {
    _state = ScannerState.scanning;
    _scannedProduct = null;
    _selectedUnit = null;
    _selectedUnitIndex = 0;
    _lastScannedBarcode = null;
    _errorMessage = null;
    update();
  }

  void selectUnit(int index) {
    if (_scannedProduct == null || _scannedProduct!.units.isEmpty) return;
    if (index >= 0 && index < _scannedProduct!.units.length) {
      _selectedUnitIndex = index;
      _selectedUnit = _scannedProduct!.units[index];
      update();
    }
  }

  /// Looks up a product by barcode using the existing ProductRepository.
  /// Matches exact unit if possible, selects it prominently, and resolves sibling units.
  Future<ProductModel?> lookupBarcode(String rawBarcode) async {
    final barcode = rawBarcode.trim();
    if (barcode.isEmpty) {
      _errorMessage = 'يرجى إدخال رمز باركود صالح';
      _state = ScannerState.error;
      update();
      return null;
    }

    _lastScannedBarcode = barcode;
    _state = ScannerState.loading;
    _errorMessage = null;
    update();

    try {
      final response = await _productRepository.getProducts(
        search: barcode,
        page: 1,
      );

      if (!response.isSuccess || response.data == null || response.data!.items.isEmpty) {
        _state = ScannerState.notFound;
        _errorMessage = 'لم يتم العثور على أي منتج مرتبط بالرمز: $barcode';
        _scannedProduct = null;
        _selectedUnit = null;
        update();
        return null;
      }

      final items = response.data!.items;

      // The barcode belongs to the product unit, not the product itself.
      ProductModel? matchedProduct;
      int matchedUnitIndex = 0;

      for (final product in items) {
        final index = product.units.indexWhere(
          (unit) => unit.barcode.trim() == barcode,
        );
        if (index >= 0) {
          matchedProduct = product;
          matchedUnitIndex = index;
          break;
        }
      }

      // unique_number is a separate product identifier, so it is a safe
      // fallback only when it matches exactly. Never select an arbitrary
      // search result for a barcode that was not found in a unit.
      if (matchedProduct == null) {
        for (final product in items) {
          if (product.uniqueNumber.trim() == barcode) {
            matchedProduct = product;
            break;
          }
        }
      }

      if (matchedProduct == null) {
        _state = ScannerState.notFound;
        _errorMessage = 'لم يتم العثور على وحدة مرتبطة بالرمز: $barcode';
        _scannedProduct = null;
        _selectedUnit = null;
        update();
        return null;
      }

      if (matchedProduct.units.isNotEmpty) {
        _selectedUnitIndex = matchedUnitIndex < matchedProduct.units.length
            ? matchedUnitIndex
            : 0;
        _selectedUnit = matchedProduct.units[_selectedUnitIndex];
      } else {
        _selectedUnitIndex = 0;
        _selectedUnit = null;
      }

      _scannedProduct = matchedProduct;
      _state = ScannerState.found;
      _errorMessage = null;
      update();
      return matchedProduct;
    } catch (e) {
      _state = ScannerState.error;
      _errorMessage = 'حدث خطأ أثناء البحث عن المنتج. يرجى المحاولة مجددًا.';
      _scannedProduct = null;
      _selectedUnit = null;
      update();
      return null;
    }
  }
}
