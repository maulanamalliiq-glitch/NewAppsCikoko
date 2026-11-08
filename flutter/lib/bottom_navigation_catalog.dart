/// Navigation labels and target routes are part of the approved UI contract.
/// Notifications are available from the app-bar bell, not as a replacement
/// for the dedicated Innovation bottom tab.
const cikokoBottomRoutes = <String>[
  'Dashboard',
  'Layanan Online',
  'Menu Cikoko',
  'Inovasi',
  'Profil',
];

String cikokoBottomRoute(int index) {
  if (index < 0 || index >= cikokoBottomRoutes.length) {
    return 'Dashboard';
  }
  return cikokoBottomRoutes[index];
}

/// Keep the last bottom tab highlighted when opening a utility screen,
/// e.g. Notifikasi, without impersonating the Innovation tab.
int cikokoBottomIndexForRoute(String route, int previous) {
  final index = cikokoBottomRoutes.indexOf(route);
  return index >= 0 ? index : previous;
}
