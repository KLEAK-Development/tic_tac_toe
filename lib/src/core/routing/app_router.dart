import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tic_tac_toe/src/features/menu/menu.dart';
import 'package:tic_tac_toe/src/features/game_modes/two_player/two_player.dart';

part 'app_router.g.dart';

// Type-safe route for the menu screen with nested game mode routes
@TypedGoRoute<MenuRoute>(
  path: '/',
  routes: [TypedGoRoute<TwoPlayerGameRoute>(path: 'game/two-player')],
)
// ignore: mixin_application_not_implemented_interface - Required for go_router_builder code generation
class MenuRoute extends GoRouteData with $MenuRoute {
  const MenuRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const MenuScreen();
  }
}

// Type-safe route for the two-player game screen (child of MenuRoute)
// Full path will be: /game/two-player
// ignore: mixin_application_not_implemented_interface - Required for go_router_builder code generation
class TwoPlayerGameRoute extends GoRouteData with $TwoPlayerGameRoute {
  const TwoPlayerGameRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const TwoPlayerGameScreen();
  }
}

// Router configuration
final GoRouter appRouter = GoRouter(initialLocation: '/', routes: $appRoutes);
