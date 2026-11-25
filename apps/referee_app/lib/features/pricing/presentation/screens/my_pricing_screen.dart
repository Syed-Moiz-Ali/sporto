import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';

/// Local pricing slots until the referee pricing API exists.
///
/// The Figma export shows five fixed durations with a per-slot hourly price.
/// The backend does not expose pricing yet, so this is an in-memory editor;
/// it resets on app restart. Replace with the API model when available.
class PricingSlot {
  PricingSlot({
    required this.hours,
    required this.price,
    required this.enabled,
  });

  final int hours;
  double price;
  bool enabled;

  String get title => '$hours Hour Slot';
}

abstract final class PricingStore {
  static final List<PricingSlot> slots = [
    PricingSlot(hours: 1, price: 500, enabled: true),
    PricingSlot(hours: 4, price: 500, enabled: false),
    PricingSlot(hours: 8, price: 500, enabled: true),
    PricingSlot(hours: 10, price: 500, enabled: true),
    PricingSlot(hours: 12, price: 500, enabled: true),
  ];
}

class MyPricingScreen extends StatefulWidget {
  const MyPricingScreen({super.key});

  @override
  State<MyPricingScreen> createState() => _MyPricingScreenState();
}

class _MyPricingScreenState extends State<MyPricingScreen> {
  static const _green = Color(0xFF2BB673);
  static const _muted = Color(0xFFA0A0A0);
  static const _disabled = Color(0xFF666666);
  static const _card = Color(0x991C2026);
  static const _trackOff = Color(0xFF373E52);

  Future<void> _editPrice(PricingSlot slot) async {
    final controller = TextEditingController(
      text: slot.price.toStringAsFixed(0),
    );
    final saved = await showModalBottomSheet<double>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: const Color(0xCC090C10),
      isScrollControlled: true,
      builder: (context) => _EditPriceSheet(
        slot: slot,
        controller: controller,
      ),
    );
    if (saved != null) {
      setState(() => slot.price = saved);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090C10),
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(
                children: [
                  Material(
                    color: const Color(0xFF252C3B),
                    borderRadius: BorderRadius.circular(10),
                    child: InkWell(
                      onTap: () => context.pop(),
                      borderRadius: BorderRadius.circular(10),
                      child: const SizedBox(
                        width: 36,
                        height: 36,
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 11),
                  const Text(
                    'My Pricing',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                itemCount: PricingStore.slots.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final slot = PricingStore.slots[index];
                  return _PricingCard(
                    slot: slot,
                    green: _green,
                    muted: _muted,
                    disabled: _disabled,
                    card: _card,
                    trackOff: _trackOff,
                    onToggle: (value) => setState(() => slot.enabled = value),
                    onEdit: () => _editPrice(slot),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PricingCard extends StatelessWidget {
  const _PricingCard({
    required this.slot,
    required this.green,
    required this.muted,
    required this.disabled,
    required this.card,
    required this.trackOff,
    required this.onToggle,
    required this.onEdit,
  });

  final PricingSlot slot;
  final Color green;
  final Color muted;
  final Color disabled;
  final Color card;
  final Color trackOff;
  final ValueChanged<bool> onToggle;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final color = slot.enabled ? Colors.white : disabled;
    final priceColor = slot.enabled ? green : disabled;
    return Container(
      height: 62,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0x332BB673)),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0x991C2026), Color(0x991C2026)],
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onEdit,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    slot.title,
                    style: TextStyle(
                      color: color,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\u20B9${slot.price.toStringAsFixed(0)}',
                    style: TextStyle(
                      color: priceColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
            ),
          ),
          _Toggle(
            value: slot.enabled,
            onChanged: onToggle,
            trackOff: trackOff,
            green: green,
          ),
        ],
      ),
    );
  }
}

class _Toggle extends StatelessWidget {
  const _Toggle({
    required this.value,
    required this.onChanged,
    required this.trackOff,
    required this.green,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final Color trackOff;
  final Color green;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: 40,
        height: 20,
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: value ? green : trackOff,
          borderRadius: BorderRadius.circular(10),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 160),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 16,
            height: 16,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}

class _EditPriceSheet extends StatelessWidget {
  const _EditPriceSheet({
    required this.slot,
    required this.controller,
  });

  final PricingSlot slot;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        decoration: const BoxDecoration(
          color: Color(0xFF1C2026),
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: SportoGradientText(
                    'Edit Price',
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFF7AD3FF), Color(0xFF4FBAF0)],
                    ),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: const BoxDecoration(
                      color: Color(0x1AFFFFFF),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              slot.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Enter Price',
              style: TextStyle(
                color: Color(0xFFA0A0A0),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: controller,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
              ],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: 'Enter price',
                hintStyle: const TextStyle(color: Color(0xFF666666)),
                filled: true,
                fillColor: const Color(0xFF0A0E12),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFF373E52)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFF7AD3FF)),
                ),
              ),
            ),
            const SizedBox(height: 22),
            Center(
              child: GestureDetector(
                onTap: () {
                  final value = double.tryParse(controller.text.trim());
                  if (value == null || value <= 0) return;
                  Navigator.of(context).pop(value);
                },
                child: Container(
                  width: 210,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF7AD3FF), Color(0xFF4FBAF0)],
                    ),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Text(
                    'Submit',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
