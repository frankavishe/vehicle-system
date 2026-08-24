import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/api/autoserve_api.dart';
import 'core/push/fcm_service.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/shell/shell_tab_index.dart';

void main() {
  runApp(const ProviderScope(child: AutoServeApp()));
}

class AutoServeApp extends ConsumerStatefulWidget {
  const AutoServeApp({super.key});

  @override
  ConsumerState<AutoServeApp> createState() => _AutoServeAppState();
}

class _AutoServeAppState extends ConsumerState<AutoServeApp> {
  @override
  void initState() {
    super.initState();
    // Fire-and-forget: a missing/absent Firebase project must not block
    // app boot (FcmService is guarded end-to-end, see its docstring).
    Future.microtask(_initPush);
  }

  Future<void> _initPush() async {
    final api = ref.read(autoserveApiProvider);
    final fcm = FcmService(api);
    // Deep-link tap-through target: the notifications tab lives inside
    // each role's tab-based shell (not a distinct go_router route), so
    // there's no route to push here — bumping the shared index provider
    // is enough to land the already-open shell on that tab. A cold start
    // still lands on the shell's default (first) tab, since the shell
    // itself hasn't mounted yet when this fires.
    fcm.onNotificationTapped = () => ref.read(shellTabIndexProvider.notifier).state = 2;
    await fcm.initialize(platform: 'ANDROID');
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'AutoServe',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      routerConfig: router,
    );
  }
}
