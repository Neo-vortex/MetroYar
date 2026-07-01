import 'package:flutter/material.dart';

/// The small circular ⇅ button sitting between the start/end station
/// fields, letting the user flip origin and destination in one tap.
class SwapStationsButton extends StatelessWidget {
  final VoidCallback onPressed;

  const SwapStationsButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return SizedBox(
      height: 30,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 30),
              child: Container(width: 1.4, height: 14, color: colors.outlineVariant),
            ),
          ),
          Material(
            color: colors.surfaceContainerHighest,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onPressed,
              child: Padding(
                padding: const EdgeInsets.all(7),
                child: Icon(
                  Icons.swap_vert_rounded,
                  size: 17,
                  color: colors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
