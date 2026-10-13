import 'package:flutter/material.dart';

/// Single source of truth for the Amu Sharif Arabiyan Majlis (ASM) palette.
///
/// Hex values are sampled from the master logo asset (`assets/brand/logo.png`):
/// the purple→magenta brand gradient, the metallic gold wordmark, and the
/// warm orange / soft yellow accents lifted from the Amharic and Arabic
/// title lines. Ivory / charcoal / deep plum are the neutral foundations.
abstract final class BrandColors {
  const BrandColors._();

  // ── Brand gradient (left → right) ─────────────────────────────────────────
  static const Color royalViolet = Color(0xFF6A11CB);
  static const Color magenta = Color(0xFFD41F8F);

  /// Midpoint of the brand gradient, useful for flat single-colour fills.
  static const Color brandMid = Color(0xFF9F188D);

  // ── Metallic gold ─────────────────────────────────────────────────────────
  static const Color gold = Color(0xFFC9A24D);
  static const Color goldLight = Color(0xFFE6C97A);
  static const Color goldDark = Color(0xFFB8893A);

  // ── Warm accents (from the Amharic / Arabic title lines, use sparingly) ───
  static const Color warmOrange = Color(0xFFF28C28);
  static const Color softYellow = Color(0xFFF5F77A);

  // ── Neutrals ──────────────────────────────────────────────────────────────
  static const Color ivory = Color(0xFFFBF8F2);
  static const Color charcoal = Color(0xFF16121C);
  static const Color deepPlum = Color(0xFF1E1428);

  /// Elevated surface used on top of [deepPlum] in dark mode.
  static const Color plumSurface = Color(0xFF2A1E38);

  /// Hairline gold border at reduced opacity, used for premium framing.
  static const Color goldHairline = Color(0x66C9A24D);

  // ── Semantic ──────────────────────────────────────────────────────────────
  static const Color success = Color(0xFF2E7D5B);
  static const Color danger = Color(0xFFB3261E);
  static const Color warning = Color(0xFFB9860B);
}
