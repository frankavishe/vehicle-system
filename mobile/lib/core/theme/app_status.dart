/// Semantic status tones — mirrors web/src/components/ui/Badge.tsx's tone
/// vocabulary (go/stop/signal/neutral) exactly, so mobile status chips use
/// the same color language as the web app instead of an independent set.
///
/// Replaces the old `Color statusColor(String status)` (previously in
/// app_theme.dart), which mapped statuses directly to raw Colors.* with
/// no tie to the app's palette. Call sites now do:
///   AppBadge.status(request.status)
/// which internally resolves `statusToneFor` then looks up the tone's
/// color pair from AppSemanticColors — see app_theme_extension.dart and
/// shared/widgets/app_badge.dart.
enum AppTone { go, stop, signal, neutral }

/// Maps backend status strings to a semantic tone.
///
/// Note: the old raw-Colors mapping used four *visually* distinct hues
/// for ACCEPTED/APPROVED/EN_ROUTE/IN_PROGRESS (blue/blue/indigo/purple).
/// web/'s Badge only defines four tones total, so EN_ROUTE and
/// IN_PROGRESS collapse into `signal` here alongside ACCEPTED/APPROVED —
/// an intentional, visible reduction in status-color granularity in
/// exchange for matching the web app's actual palette rather than
/// inventing an off-system indigo/purple.
AppTone statusToneFor(String status) {
  switch (status) {
    case 'PENDING':
      return AppTone.neutral;
    case 'ACCEPTED':
    case 'APPROVED':
    case 'EN_ROUTE':
    case 'IN_PROGRESS':
    case 'PROCESSING':
      return AppTone.signal;
    case 'COMPLETED':
    case 'ORDERED':
    case 'PAID':
      return AppTone.go;
    case 'CANCELLED':
    case 'REJECTED':
    case 'FAILED':
      return AppTone.stop;
    default:
      return AppTone.neutral;
  }
}
