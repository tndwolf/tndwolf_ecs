// Copyright (c) 2016, Luca Carbone. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'world.dart';

/// Base class from which all [GameComponents] derive.
abstract class GameComponent {
  /// When set to [True] the component is flagged for deletion before the next
  /// [update] loop
  bool deleteMe = false;

  /// The entity ID of the component's owner.
  num entity = World.invalidEntity;

  /// If a [GameComponent] is managed, it means that it should be owned by a
  /// [GameSystem] and updated by it. If the component is unmanaged, the
  /// [World] itself will run its update cycle after all systems have finished.
  final bool isManaged;

  GameComponent(num this.entity, [bool this.isManaged = false]);

  /// Updates the component according to the world status. This function is
  /// called at each update by [World] and only if the [GameComponent] is
  /// unmanaged.
  void update(World world) { }
}