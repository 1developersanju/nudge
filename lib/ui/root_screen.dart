import 'dart:ui';
import 'package:flutter/material.dart';

import '../data/repository.dart';
import '../data/text_splitter.dart';
import '../theme/review_spacing_controller.dart';
import '../theme/theme_controller.dart';
import 'app_theme.dart';
import '../background/notification_channels.dart';
import 'capture_overlay.dart';
import 'history_page.dart';
import 'home_screen.dart';
import 'settings_page.dart';

class RootScreen extends StatefulWidget {
  const RootScreen({
    super.key,
    required this.repo,
    required this.theme,
    required this.spacing,
  });

  final LearningRepository repo;
  final ThemeController theme;
  final ReviewSpacingController spacing;

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> with WidgetsBindingObserver {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await requestAndroidReviewNotificationPermissions();
      if (mounted) await widget.repo.rescheduleNotificationAlarms();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      widget.repo.rescheduleNotificationAlarms();
    }
  }

  void _onNavTapped(int index) {
    if (index == 1) {
      // Capture Overlay doesn't change bottom nav active state. It just opens an overlay.
      showCaptureOverlay(
        context,
        onCapture: (String text) {
          final chunks = LearningInputSplitter.splitLearningInput(text);
          widget.repo.addTopicsFromChunks(chunks);
        },
      );
      return;
    }
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // The "pages" mapping to nav:
    // 0: Dashboard (home_screen)
    // 1: Capture (Triggered as overlay, so index 1 in nav won't technically persist)
    // 2: Log (history)
    // 3: Settings (settings)

    Widget body;
    if (_currentIndex == 0) {
      body = HomeScreen(
        repo: widget.repo,
        theme: widget.theme,
        spacing: widget.spacing,
      );
    } else if (_currentIndex == 2) {
      body = HistoryPage(repo: widget.repo);
    } else if (_currentIndex == 3) {
      body = SettingsPage(
        repo: widget.repo,
        theme: widget.theme,
        spacing: widget.spacing,
      );
    } else {
      body = const SizedBox.shrink(); // Shouldn't stay here
    }

    return Scaffold(
      body: Stack(
        children: [
          body,
          // Custom Bottom Navigation Bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _ObsidianBottomNav(
              currentIndex: _currentIndex,
              onTap: _onNavTapped,
            ),
          ),
        ],
      ),
    );
  }
}

class _ObsidianBottomNav extends StatelessWidget {
  const _ObsidianBottomNav({required this.currentIndex, required this.onTap});

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final shadowColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.black45
        : Colors.black.withValues(alpha: 0.1);

    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(48)),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 40,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(48)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            color: AppTheme.surfaceContainerHigh(
              context,
            ).withValues(alpha: 0.88),
            padding: const EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: 16,
            ),
            child: SafeArea(
              top: false,
              child: _NavContent(currentIndex: currentIndex, onTap: onTap),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavContent extends StatelessWidget {
  const _NavContent({required this.currentIndex, required this.onTap});

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _NavItem(
          icon: Icons.grid_view_rounded,
          label: 'Dashboard',
          isActive: currentIndex == 0,
          onTap: () => onTap(0),
        ),
        _NavItem(
          icon: Icons.add_circle_rounded,
          label: 'Capture',
          isActive: currentIndex == 1,
          onTap: () => onTap(1),
          highlight: true,
        ),
        _NavItem(
          icon: Icons.history_rounded,
          label: 'Log',
          isActive: currentIndex == 2,
          onTap: () => onTap(2),
        ),
        _NavItem(
          icon: Icons.settings_outlined,
          label: 'Settings',
          isActive: currentIndex == 3,
          onTap: () => onTap(3),
        ),
      ],
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
    this.highlight = false,
  });

  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final color = isActive || highlight
        ? AppTheme.primary(context)
        : AppTheme.muted(context);
    final bgColor = isActive
        ? AppTheme.primary(context).withValues(alpha: 0.1)
        : Colors.transparent;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16), // So ripple isn't a square
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: highlight && isActive
                ? AppTheme.surfaceContainer(context)
                : bgColor,
            borderRadius: BorderRadius.circular(32),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 4),
              Text(
                label.toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
