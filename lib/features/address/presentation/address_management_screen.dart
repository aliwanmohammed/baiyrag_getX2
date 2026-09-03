import 'package:bhm_supermarket/app/localization/lang.dart';
import 'package:bhm_supermarket/core/widgets/app_page_header.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/design_system/components/feedback/app_empty_state.dart';
import '../../../core/design_system/components/feedback/app_loading.dart';
import '../../../core/design_system/components/app_button.dart';
import '../../../core/design_system/components/app_icon.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/widgets/app_message.dart';
import '../../../core/widgets/app_dialog.dart';
import '../models/address_model.dart';
import '../controllers/address_controller.dart';
import '../widgets/pick_location_sheet.dart';
import '../../../core/utils/validators.dart';

class AddressManagementScreen extends StatefulWidget {
  final bool fromCheckout;
  // final PickedLocation? pickedLocation;

  const AddressManagementScreen({
    super.key,
    this.fromCheckout = false,
    // this.pickedLocation,
  });

  @override
  State<AddressManagementScreen> createState() =>
      _AddressManagementScreenState();
}

class _AddressManagementScreenState extends State<AddressManagementScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final controller = Get.find<AddressController>();

        if (controller.addresses.isEmpty) {
          await controller.loadAddresses();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AddressController>(builder: (_) => _buildGetX0(context));
  }

  Widget _buildGetX0(BuildContext context) {
    return Scaffold(
      appBar: AppPageHeader(
        title: lang.t('delivery_addresses'),
        onBack: () {
          Navigator.of(context).pop(widget.fromCheckout);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: Icon(Icons.add),
        label: Text(lang.t('add_address')),
        onPressed: () {
          _showAddressDialog(context);
        },
      ),
      body: GetBuilder<AddressController>(
        builder: (controller) {
          if (controller.loading) {
            return Center(child: AppLoading());
          }

          if (controller.addresses.isEmpty) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.xxl),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AppEmptyState(
                      icon: Icons.location_off,
                      title: lang.t('no_addresses'),
                      subtitle: lang.t('add_first_address'),
                    ),
                    SizedBox(height: AppSpacing.xl),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: AppButton(
                        icon: AppIcon(Icons.add_location_alt,
                            size: AppIconSize.medium),
                        text: lang.t('add_address'),
                        onPressed: () {
                          _showAddressDialog(context);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 100),
            itemCount: controller.addresses.length,
            separatorBuilder: (_, __) => SizedBox(height: 12),
            itemBuilder: (_, index) {
              final address = controller.addresses[index];

              return _AddressTile(
                address: address,
                onEdit: () {
                  _showAddressDialog(context, existing: address);
                },
                onDelete: () {
                  _confirmDelete(context, controller, address.id);
                },
                onSetDefault: () async {
                  await controller.setDefault(address.id);
                },
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _showAddressDialog(
    BuildContext context, {
    AddressModel? existing,
  }) async {
    final pickedLocation = await showModalBottomSheet<PickedLocation>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => PickLocationSheet(),
    );

    if (!context.mounted) return;

    await _showManualForm(existing, picked: pickedLocation);
  }

  Future<void> _showManualForm(
    AddressModel? existing, {
    PickedLocation? picked,
  }) async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddressFormSheet(
        existing: existing,
        fromCheckout: widget.fromCheckout,
        pickedLocation: picked,
      ),
    );

    if (!mounted) return;

    // الـ BottomSheet أُغلق بنجاح
    if (saved == true && widget.fromCheckout) {
      Navigator.of(context).pop(true);
    }
  }

  void _confirmDelete(
    BuildContext context,
    AddressController controller,
    String id,
  ) {
    AppDialog.confirm(
      context,
      title: lang.t('delete_address'),
      message: lang.t('delete_address_confirm'),
      confirmText: lang.t('delete'),
      isDanger: true,
    ).then((confirmed) async {
      if (confirmed != true || !context.mounted) return;

      final success = await controller.deleteAddress(id);

      if (!context.mounted) return;
      if (success) {
        AppMessage.success(context, lang.t('address_deleted'));
      } else {
        AppMessage.error(context, lang.t('address_delete_failed'));
      }
    });
  }
}

class _AddressTile extends StatelessWidget {
  final AddressModel address;

  final VoidCallback onEdit;

  final VoidCallback onDelete;

  final VoidCallback onSetDefault;

  const _AddressTile({
    required this.address,
    required this.onEdit,
    required this.onDelete,
    required this.onSetDefault,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.location_on, color: AppColors.primary),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    address.title,
                    style: AppTypography.titleSmall,
                  ),
                ),
                if (address.isDefault)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: .1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(lang.t('default')),
                  ),
              ],
            ),
            SizedBox(height: 10),
            Text(address.address),
            SizedBox(height: 10),
            Row(
              children: [
                if (!address.isDefault)
                  TextButton(
                    onPressed: onSetDefault,
                    child: Text(lang.t('set_default')),
                  ),
                Spacer(),
                IconButton(onPressed: onEdit, icon: Icon(Icons.edit)),
                IconButton(
                  onPressed: onDelete,
                  icon: Icon(Icons.delete, color: Colors.red),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AddressFormSheet extends StatefulWidget {
  final AddressModel? existing;
  final bool fromCheckout;
  final PickedLocation? pickedLocation;

  const _AddressFormSheet({
    this.existing,
    this.fromCheckout = false,
    this.pickedLocation,
  });

  @override
  State<_AddressFormSheet> createState() => _AddressFormSheetState();
}

class _AddressFormSheetState extends State<_AddressFormSheet> {
  final _titleCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();

  bool _isDefault = false;
  bool _isSaving = false;

  // Reserved for future Google Maps location picker integration
  double? _latitude;
  double? _longitude;

  @override
  void initState() {
    super.initState();

    final e = widget.existing;

    if (e != null) {
      _titleCtrl.text = e.title;
      _addressCtrl.text = e.address;
      _isDefault = e.isDefault;
      _latitude = e.latitude;
      _longitude = e.longitude;
    }

    if (widget.pickedLocation != null) {
      _addressCtrl.text = widget.pickedLocation!.address;
      _latitude = widget.pickedLocation!.latitude;
      _longitude = widget.pickedLocation!.longitude;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    // منع الضغط المتكرر أثناء الحفظ
    if (_isSaving) {
      return;
    }

    final title = _titleCtrl.text.trim();
    final address = _addressCtrl.text.trim();

    // ─────────────────────────────────────────────────────────────
    // التحقق من اسم العنوان
    // ─────────────────────────────────────────────────────────────

    final titleError = Validators.required(
      title,
      lang.t('address_name'),
    );

    if (titleError != null) {
      AppMessage.warning(context, titleError);
      return;
    }

    // ─────────────────────────────────────────────────────────────
    // التحقق من طول اسم العنوان
    // ─────────────────────────────────────────────────────────────

    final titleLengthError = Validators.minLength(
      title,
      2,
      lang.t('address_name'),
    );

    if (titleLengthError != null) {
      AppMessage.warning(context, titleLengthError);
      return;
    }

    // ─────────────────────────────────────────────────────────────
    // التحقق من العنوان / الشارع
    // ─────────────────────────────────────────────────────────────

    final addressError = Validators.required(
      address,
      lang.t('address'),
    );

    if (addressError != null) {
      AppMessage.warning(context, addressError);
      return;
    }

    // ─────────────────────────────────────────────────────────────
    // التحقق من طول العنوان
    // ─────────────────────────────────────────────────────────────

    final addressLengthError = Validators.minLength(
      address,
      3,
      lang.t('address'),
    );

    if (addressLengthError != null) {
      AppMessage.warning(context, addressLengthError);
      return;
    }

    // ─────────────────────────────────────────────────────────────
    // بدء الحفظ
    // ─────────────────────────────────────────────────────────────

    setState(() {
      _isSaving = true;
    });

    final controller = Get.find<AddressController>();

    String? error;

    if (widget.existing == null) {
      // ───────────────────────────────────────────────────────────
      // إضافة عنوان جديد
      // ───────────────────────────────────────────────────────────

      error = await controller.addAddress(
        title: title,
        address: address,
        isDefault: _isDefault,
        latitude: _latitude,
        longitude: _longitude,
      );
    } else {
      // ───────────────────────────────────────────────────────────
      // تعديل عنوان موجود
      // ───────────────────────────────────────────────────────────

      error = await controller.editAddress(
        id: widget.existing!.id,
        title: title,
        address: address,
        latitude: _latitude,
        longitude: _longitude,
        isDefault: _isDefault,
      );
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _isSaving = false;
    });

    // ─────────────────────────────────────────────────────────────
    // فشل الحفظ
    // ─────────────────────────────────────────────────────────────

    if (error != null) {
      AppMessage.error(
        context,
        error,
      );
      return;
    }

    // ─────────────────────────────────────────────────────────────
    // نجاح الحفظ
    // ─────────────────────────────────────────────────────────────

    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 60),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Text(
              widget.existing == null
                  ? lang.t('add_address')
                  : lang.t('edit_address'),
              style: AppTypography.titleLarge,
            ),
            SizedBox(height: 20),
            _field(lang.t('address_name'), _titleCtrl),
            _field(lang.t('street'), _addressCtrl),
            SizedBox(height: 10),
            InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () async {
                final pickedLocation =
                    await showModalBottomSheet<PickedLocation>(
                  context: context,
                  isScrollControlled: true,
                  useSafeArea: true,
                  builder: (_) => PickLocationSheet(),
                );

                if (pickedLocation == null) return;

                setState(() {
                  _latitude = pickedLocation.latitude;
                  _longitude = pickedLocation.longitude;
                  _addressCtrl.text = pickedLocation.address;
                });
              },
              child: Container(
                height: 70,
                padding: EdgeInsets.symmetric(horizontal: 18),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    Icon(Icons.map, color: Colors.green),
                    SizedBox(width: 12),
                    Expanded(child: Text(lang.t('choose_location_map'))),
                    Icon(Icons.arrow_forward_ios, size: 16),
                  ],
                ),
              ),
            ),
            SwitchListTile(
              value: _isDefault,
              onChanged: (v) {
                setState(() {
                  _isDefault = v;
                });
              },
              title: Text(lang.t('default_address_title')),
            ),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                child: _isSaving
                    ? AppLoading(
                        type: AppLoadingType.bars,
                        size: 22,
                        color: Colors.white,
                      )
                    : Text(lang.t('save')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(
    String label,
    TextEditingController controller, {
    TextInputType type = TextInputType.text,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        keyboardType: type,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
