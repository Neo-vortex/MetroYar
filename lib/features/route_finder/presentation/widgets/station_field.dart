import 'package:flutter/material.dart';

import '../../../../shared/models/station.dart';

/// An autocomplete text field for picking a [Station] by Farsi name.
///
/// When [showLocationButton] is true (used for the start-station field), a
/// small location button sits beside it — tapping it fetches the user's
/// GPS position and selects the nearest station, handled entirely by the
/// bloc via [onLocationPressed].
class StationField extends StatefulWidget {
  final String label;
  final IconData icon;
  final Color iconColor;
  final List<Station> stations;
  final Station? value;
  final ValueChanged<Station?> onChanged;
  final bool showLocationButton;
  final bool isLocating;
  final VoidCallback? onLocationPressed;
  final VoidCallback? onPickFromMapPressed;

  const StationField({
    super.key,
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.stations,
    required this.value,
    required this.onChanged,
    this.showLocationButton = false,
    this.isLocating = false,
    this.onLocationPressed,
    this.onPickFromMapPressed,
  });

  @override
  State<StationField> createState() => _StationFieldState();
}

class _StationFieldState extends State<StationField> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.value?.displayName ?? '');

  // Autocomplete requires an explicit focusNode whenever a custom
  // textEditingController is supplied — without it, the widget asserts.
  final FocusNode _focusNode = FocusNode();

  @override
  void didUpdateWidget(StationField oldWidget) {
    super.didUpdateWidget(oldWidget);
    final desired = widget.value?.displayName ?? '';
    if (_controller.text != desired) {
      _controller.text = desired;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Row(
          children: [
            Expanded(
              child: Autocomplete<Station>(
                textEditingController: _controller,
                focusNode: _focusNode,
                displayStringForOption: (s) => s.displayName,
                optionsBuilder: (value) {
                  if (value.text.isEmpty) return widget.stations;
                  final query = value.text.toLowerCase();
                  return widget.stations.where(
                    (s) => s.displayName.toLowerCase().contains(query),
                  );
                },
                onSelected: widget.onChanged,
                fieldViewBuilder: (context, controller, focusNode, onSubmit) {
                  return TextFormField(
                    controller: controller,
                    focusNode: focusNode,
                    onEditingComplete: onSubmit,
                    onChanged: (text) {
                      if (text.isEmpty) widget.onChanged(null);
                    },
                    decoration: InputDecoration(
                      labelText: widget.label,
                      prefixIcon: Container(
                        margin: const EdgeInsets.all(12),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: widget.iconColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(widget.icon, color: widget.iconColor, size: 20),
                      ),
                      border: InputBorder.none,
                      filled: false,
                    ),
                  );
                },
                optionsViewBuilder: (context, onSelected, options) {
                  return Align(
                    alignment: Alignment.topRight,
                    child: Material(
                      elevation: 6,
                      borderRadius: BorderRadius.circular(16),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width - 56,
                          maxHeight: 240,
                        ),
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          shrinkWrap: true,
                          itemCount: options.length,
                          itemBuilder: (context, index) {
                            final option = options.elementAt(index);
                            return ListTile(
                              dense: true,
                              leading: Icon(
                                Icons.location_on_outlined,
                                size: 19,
                                color: colors.onSurfaceVariant,
                              ),
                              title: Text(option.displayName),
                              subtitle: option.nameEn.isNotEmpty
                                  ? Text(
                                      option.nameEn,
                                      style: const TextStyle(fontSize: 11),
                                    )
                                  : null,
                              onTap: () => onSelected(option),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            if (widget.showLocationButton) ...[
              const SizedBox(width: 3),
              _LocationButton(
                isLocating: widget.isLocating,
                onPressed: widget.onLocationPressed,
              ),
            ],
            if (widget.onPickFromMapPressed != null) ...[
              const SizedBox(width: 10),
              _MapPickButton(onPressed: widget.onPickFromMapPressed),
            ],
            const SizedBox(width: 4),
          ],
        ),
      ),
    );
  }
}

class _MapPickButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const _MapPickButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Tooltip(
      message: 'انتخاب از روی نقشه',
      child: Material(
        color: colors.secondaryContainer,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Icon(
              Icons.map_rounded,
              size: 20,
              color: colors.onSecondaryContainer,
            ),
          ),
        ),
      ),
    );
  }
}

class _LocationButton extends StatelessWidget {
  final bool isLocating;
  final VoidCallback? onPressed;

  const _LocationButton({required this.isLocating, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Tooltip(
      message: 'استفاده از موقعیت فعلی من',
      child: Material(
        color: colors.primaryContainer,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: isLocating ? null : onPressed,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: isLocating
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        colors.onPrimaryContainer,
                      ),
                    ),
                  )
                : Icon(
                    Icons.my_location_rounded,
                    size: 20,
                    color: colors.onPrimaryContainer,
                  ),
          ),
        ),
      ),
    );
  }
}
