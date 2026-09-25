import 'package:flutter/material.dart';

class AuthScreenSection extends StatelessWidget {
  const AuthScreenSection({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
  });

  final String title;
  final Widget child;
  final Widget? subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 16),
              Align(alignment: Alignment.centerLeft, child: subtitle!),
            ],
            if (subtitle == null) const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}
