import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_theme.dart';

Future<void> showCaptureOverlay(
  BuildContext context, {
  required ValueChanged<String> onCapture,
}) async {
  await showGeneralDialog(
    context: context,
    pageBuilder: (ctx, anim, secondAnim) {
      return _CaptureOverlay(onCapture: onCapture);
    },
    barrierDismissible: true,
    barrierLabel: 'Dismiss Capture',
    barrierColor: AppTheme.surfaceContainerLowest(
      context,
    ).withValues(alpha: 0.85),
    transitionDuration: const Duration(milliseconds: 300),
    transitionBuilder: (context, anim, secondaryAnim, child) {
      return BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 20 * anim.value,
          sigmaY: 20 * anim.value,
        ),
        child: FadeTransition(opacity: anim, child: child),
      );
    },
  );
}

class _CaptureOverlay extends StatefulWidget {
  const _CaptureOverlay({required this.onCapture});

  final ValueChanged<String> onCapture;

  @override
  State<_CaptureOverlay> createState() => _CaptureOverlayState();
}

class _CaptureOverlayState extends State<_CaptureOverlay> {
  final _ctrl = TextEditingController();
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _focus.requestFocus();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _submit() {
    final t = _ctrl.text.trim();
    if (t.isNotEmpty) {
      widget.onCapture(t);
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    // Glassmorphic layout matching the HTML design context
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 24, right: 24, top: 32, bottom: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.auto_awesome,
                        color: AppTheme.primaryContainer(context),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'NEW REFLECTION',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5,
                          color: AppTheme.muted(context),
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    style: IconButton.styleFrom(
                      backgroundColor: AppTheme.surfaceContainerHigh(context),
                      foregroundColor: AppTheme.ink(context),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),

              // Center input
              Expanded(
                child: Center(
                  child: TextField(
                    controller: _ctrl,
                    focusNode: _focus,
                    autofocus: true,
                    textAlign: TextAlign.center,
                    maxLines: null,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _submit(),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText:
                          'What did you learn today? You can separate chapters with commas...',
                      hintStyle: TextStyle(
                        color: AppTheme.outlineVariant(context),
                      ),
                    ),
                  ),
                ),
              ),

              // Footer / Actions
              Column(
                children: [
                  GestureDetector(
                    onTap: _submit,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.primary(context),
                            AppTheme.primaryContainer(context),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primary(
                              context,
                            ).withValues(alpha: 0.15),
                            blurRadius: 48,
                            offset: const Offset(0, 24),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.archive_outlined,
                            color: AppTheme.onPrimary(context),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Archive to Vault',
                            style: TextStyle(
                              color: AppTheme.onPrimary(context),
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Dummy actions for presentation polish (non-functional visual decorators based on HTML)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _MinimalAction(
                        icon: Icons.schedule,
                        label: 'REMIND LATER',
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            color: AppTheme.outlineVariant(context),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      _MinimalAction(
                        icon: Icons.label_outline,
                        label: 'ADD CONTEXT',
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Crafted by Sanju ✨',
                    style: GoogleFonts.caveat(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.muted(context).withValues(alpha: 0.5),
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MinimalAction extends StatelessWidget {
  final IconData icon;
  final String label;

  _MinimalAction({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.muted(context)),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
            color: AppTheme.muted(context),
          ),
        ),
      ],
    );
  }
}
