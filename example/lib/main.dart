import 'dart:io';
import 'dart:ui';

import 'package:example/store/ChatMessage.dart';
import 'package:example/store/loading.dart';
import 'package:example/store/user.dart';
import 'package:example/store/webSocket.dart';
import 'package:example/view/home.dart';
import 'package:example/view/login.dart';
import 'package:fluent_ui/fluent_ui.dart' hide Page;
import 'package:flutter/foundation.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart' as flutter_acrylic;
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:system_theme/system_theme.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';

import 'routes/forms.dart' deferred as forms;
import 'routes/inputs.dart' deferred as inputs;
import 'routes/navigation.dart' deferred as navigation;
import 'routes/popups.dart' deferred as popups;
import 'routes/surfaces.dart' deferred as surfaces;
import 'routes/theming.dart' deferred as theming;
import 'theme.dart';
import 'widgets/deferred_widget.dart';

const String appTitle = '清语';

/// Checks if the current environment is a desktop environment.
bool get isDesktop {
  if (kIsWeb) return false;
  return [
    TargetPlatform.windows,
    TargetPlatform.linux,
    TargetPlatform.macOS,
  ].contains(defaultTargetPlatform);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb &&
      [
        TargetPlatform.windows,
        TargetPlatform.android,
      ].contains(defaultTargetPlatform)) {
    SystemTheme.accentColor.load();
  }

  if (isDesktop) {
    await flutter_acrylic.Window.initialize();
    if (defaultTargetPlatform == TargetPlatform.windows) {
      await flutter_acrylic.Window.hideWindowControls();
    }
    await WindowManager.instance.ensureInitialized();
    windowManager.waitUntilReadyToShow().then((_) async {
      await windowManager.setTitleBarStyle(
        TitleBarStyle.hidden,
        windowButtonVisibility: false,
      );
      await windowManager.setSize(const Size(1000, 600));
      await windowManager.setMinimumSize(const Size(1000, 600));
      await windowManager.center();
      await windowManager.setPreventClose(true);
      await windowManager.setSkipTaskbar(false);
    });

    trayManager.setIcon(
      Platform.isWindows
          ? '/assets/images/qingyu.png'
          : '/assets/images/qingyu.png',
    );

    Menu menu = Menu(
      items: [
        MenuItem(
          key: '退出',
          label: '退出',
        ),
      ],
    );
    await trayManager.setContextMenu(menu);
  }

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => LoadingEle()),
      ChangeNotifierProvider(create: (context) => UserStore()),
      ChangeNotifierProvider(create: (context) => ChatMessageStore()),
    ],
    child: const MyApp(),
  ));
  Future.wait([
    DeferredWidget.preload(popups.loadLibrary),
    DeferredWidget.preload(forms.loadLibrary),
    DeferredWidget.preload(inputs.loadLibrary),
    DeferredWidget.preload(navigation.loadLibrary),
    DeferredWidget.preload(surfaces.loadLibrary),
    DeferredWidget.preload(theming.loadLibrary),
  ]);
}

final _appTheme = AppTheme();
final loading = LoadingEle();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _appTheme,
      builder: (context, child) {
        final appTheme = context.watch<AppTheme>();
        return FluentApp.router(
          title: appTitle,
          themeMode: appTheme.mode,
          debugShowCheckedModeBanner: false,
          color: appTheme.color,
          darkTheme: FluentThemeData(
            brightness: Brightness.dark,
            accentColor: appTheme.color,
            visualDensity: VisualDensity.standard,
            focusTheme: FocusThemeData(
              glowFactor: is10footScreen(context) ? 2.0 : 0.0,
            ),
          ),
          theme: FluentThemeData(
            accentColor: appTheme.color,
            visualDensity: VisualDensity.standard,
            focusTheme: FocusThemeData(
              glowFactor: is10footScreen(context) ? 2.0 : 0.0,
            ),
          ),
          locale: appTheme.locale,
          builder: (context, child) {
            return Directionality(
              textDirection: appTheme.textDirection,
              child: NavigationPaneTheme(
                data: NavigationPaneThemeData(
                  backgroundColor: appTheme.windowEffect !=
                          flutter_acrylic.WindowEffect.disabled
                      ? Colors.transparent
                      : null,
                ),
                child: Stack(
                  children: [
                    child!,
                    Consumer<LoadingEle>(
                      builder: (context, loading, child) {
                        return loading.value
                            ? Container(
                                decoration: BoxDecoration(
                                    color: Colors.grey[20].withOpacity(0.5)),
                                child: const Center(
                                  child: ProgressRing(),
                                ))
                            : const SizedBox.shrink();
                      },
                    )
                  ],
                ),
              ),
            );
          },
          routeInformationParser: router.routeInformationParser,
          routerDelegate: router.routerDelegate,
          routeInformationProvider: router.routeInformationProvider,
        );
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
    required this.child,
    required this.shellContext,
  });

  final Widget child;
  final BuildContext? shellContext;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with WindowListener, TrayListener {
  bool value = false;
  final viewKey = GlobalKey(debugLabel: 'Navigation View Key');
  final searchKey = GlobalKey(debugLabel: 'Search Bar Key');
  final searchFocusNode = FocusNode();
  final searchController = TextEditingController();
  late final List<NavigationPaneItem> originalItems = [
    PaneItem(
      key: const ValueKey('/home'),
      icon: const Icon(FluentIcons.chat_invite_friend),
      title: const Text('首页'),
      body: const SizedBox.shrink(),
    ),
    // TODO: Scrollbar, RatingBar
  ].map<NavigationPaneItem>((e) {
    PaneItem buildPaneItem(PaneItem item) {
      return PaneItem(
        key: item.key,
        icon: item.icon,
        title: item.title,
        body: item.body,
        onTap: () {
          final path = (item.key as ValueKey).value;
          if (GoRouterState.of(context).uri.toString() != path) {
            context.go(path);
          }
          item.onTap?.call();
        },
      );
    }

    return buildPaneItem(e);
  }).toList();
  late final List<NavigationPaneItem> footerItems = [
    PaneItemSeparator(),
    PaneItem(
      key: const ValueKey('/settings'),
      icon: const Icon(FluentIcons.settings),
      title: const Text('Settings'),
      body: const SizedBox.shrink(),
      onTap: () {
        //
      },
    ),
  ];

  @override
  void initState() {
    windowManager.addListener(this);
    trayManager.addListener(this);
    super.initState();
  }

  @override
  void onTrayIconMouseDown() {
    windowManager.show();
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) {
    if (menuItem.key == '退出') {
      windowManager.hide();
      windowManager.close();
      windowManager.destroy();
    }
  }

  @override
  void onTrayIconRightMouseUp() {
    trayManager.popUpContextMenu();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    trayManager.removeListener(this);
    searchController.dispose();
    searchFocusNode.dispose();
    super.dispose();
  }

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    int indexOriginal = originalItems
        .where((item) => item.key != null)
        .toList()
        .indexWhere((item) => item.key == Key(location));

    if (indexOriginal == -1) {
      int indexFooter = footerItems
          .where((element) => element.key != null)
          .toList()
          .indexWhere((element) => element.key == Key(location));
      if (indexFooter == -1) {
        return 0;
      }
      return originalItems
              .where((element) => element.key != null)
              .toList()
              .length +
          indexFooter;
    } else {
      return indexOriginal;
    }
  }

  @override
  Widget build(BuildContext context) {
    final appTheme = context.watch<AppTheme>();
    if (widget.shellContext != null) {
      if (router.canPop() == false) {
        setState(() {});
      }
    }
    return NavigationView(
      key: viewKey,
      appBar: NavigationAppBar(
        automaticallyImplyLeading: false,
        title: () {
          if (kIsWeb) {
            return const Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(appTitle),
            );
          }
          return DragToMoveArea(
            child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: Row(
                  children: [
                    Image.asset(
                      "assets/images/qingyu.png",
                    ),
                  ],
                )),
          );
        }(),
        actions: const Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          if (!kIsWeb) WindowButtons(),
        ]),
      ),
      paneBodyBuilder: (item, child) {
        final name =
            item?.key is ValueKey ? (item!.key as ValueKey).value : null;
        return FocusTraversalGroup(
          key: ValueKey('body$name'),
          child: widget.child,
        );
      },
      pane: NavigationPane(
          Expand: false,
          selected: _calculateSelectedIndex(context),
          displayMode: PaneDisplayMode.compact,
          indicator: () {
            switch (appTheme.indicator) {
              case NavigationIndicators.end:
                return const EndNavigationIndicator();
              case NavigationIndicators.sticky:
              default:
                return const StickyNavigationIndicator();
            }
          }(),
          items: originalItems,
          footerItems: footerItems),
      onOpenSearch: searchFocusNode.requestFocus,
    );
  }

  @override
  void onWindowClose() async {
    bool isPreventClose = await windowManager.isPreventClose();
    if (isPreventClose && mounted) {
      showDialog(
        context: context,
        builder: (_) {
          return ContentDialog(
            title: const Text('操作'),
            content: const Text('是否要最小化到托盘栏'),
            actions: [
              FilledButton(
                child: const Text('确定'),
                onPressed: () {
                  Navigator.pop(context);
                  windowManager.hide();
                },
              ),
              Button(
                child: const Text('退出'),
                onPressed: () {
                  Navigator.pop(context);
                  windowManager.close();
                  windowManager.destroy();
                },
              ),
            ],
          );
        },
      );
    }
  }
}

class WindowButtons extends StatelessWidget {
  const WindowButtons({super.key});

  @override
  Widget build(BuildContext context) {
    final FluentThemeData theme = FluentTheme.of(context);
    return SizedBox(
      width: 138,
      height: 50,
      child: WindowCaption(
        brightness: theme.brightness,
        backgroundColor: Colors.transparent,
      ),
    );
  }
}

final rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();
final router = GoRouter(navigatorKey: rootNavigatorKey, routes: [
  GoRoute(path: '/', builder: (context, state) => const LoginPage()),
  ShellRoute(
    navigatorKey: _shellNavigatorKey,
    builder: (context, state, child) {
      return MyHomePage(
        shellContext: _shellNavigatorKey.currentContext,
        child: child,
      );
    },
    routes: <GoRoute>[
      GoRoute(path: '/home', builder: (context, state) => const HomePage()),
    ],
  ),
]);
