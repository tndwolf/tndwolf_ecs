// Copyright (c) 2016, Luca Carbone. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'game_component.dart';
import 'world.dart';

/// Base class from which all [GameSystem] are derived. At least the [update]
/// method must be overridden.
abstract class GameSystem {
  /// Initializes the system. Throws an exception if something went wrong.
  void initialize(World world) {  }

  /// Tries to register a component. It returns true if the registration was
  /// successful, false otherwise.
  bool register(GameComponent component) { return false; }

  /// Unregisters a component. It fails silently if the component was not
  /// registered or is invalid
  void unregister(GameComponent component) {  }

  /// Updates the components part of the system according to the world status.
  /// This method is called by [World] at every [update] loop.
  void update(World world);
}