import '../../cheyalpaadugal/amaippugal/tharavu/niruvana_tharavugal.dart';

/// Helper to unify the monolingual display logic for Niruvanam UI components in Kooli
class OruMozhiNiruvanamUdhavi {
  /// Returns the primary display name based on the Kooli achu mozhi.
  static String mudhanmaiPeyar(NiruvanaTharavugal p, String kooliAchuMozhi) {
    return p.niruvanathinPeyar[kooliAchuMozhi] ??
        p.niruvanathinPeyar['Tamil'] ??
        p.niruvanathinPeyar.values.firstOrNull ??
        '';
  }
}
