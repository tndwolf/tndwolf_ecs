// Copyright (c) 2016, Luca Carbone. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'game_component.dart';
import 'game_system.dart';

/// Base class from where a specific implementation of a game world can be
/// derived.
abstract class World {
  bool _clearMe = false;
  List<GameComponent> _components = <GameComponent>[];
  num _deltaTime = 0;
  num _lastAssignedEntity = -1;
  List<GameSystem> _systems = <GameSystem>[];
  num _time = 0;
  List<GameComponent> _unmanagedComponents = <GameComponent>[];

  /// Adds a component to the world and automatically registers it to the
  /// subsystems (or to the execution queue is unmanaged).
  void addComponent(GameComponent component) {
    if (component.isManaged) {
      for (var system in _systems) system.register(component);
    } else {
      _unmanagedComponents.add(component);
    }
    _components.add(component);
    if (component.entity > _lastAssignedEntity) {
      _lastAssignedEntity = component.entity;
    }
  }

  /// Adds a system to the world. This method also initialize the system and
  /// registers already existing components if necessary.
  void addSystem(GameSystem system) {
    system.initialize(this);
    _systems.add(system);
    for (var component in _components) system.register(component);
  }

  /// Cleans unused components. It must only/always be used at the beginning
  /// of [update] and nowhere else, so to not modify the world status during an
  /// [update], otherwise all the update queues will be broken.
  void clean() {
    if (_clearMe == true) {
      forceClear();
    } else {
      var toDelete = _components.where((c) => c.deleteMe == true);
      toDelete.forEach((c) => _systems.forEach((s) => s.unregister(c)));
      _components.removeWhere((c) => c.deleteMe == true);
      _unmanagedComponents.removeWhere((c) => c.deleteMe == true);
    }
  }

  /// Prepares the world to be purged at the next [update]. All entities and
  /// systems will be removed.
  void clear() {
    _clearMe = true;
    for (var component in _components) component.deleteMe = true;
  }

  /// Removes all entities and components from new the world at the beginning
  /// of the next [update] cycle.
  void clearEntities() {
    for (var component in _components) component.deleteMe = true;
  }

  /// Sets the specific component to be deleted at the next [update] loop.
  void deleteComponent(GameComponent component) {
    var tmp = _components.firstWhere((c) => c == component);
    if (tmp != null) tmp.deleteMe = true;
  }

  /// Sets all the components owned by an entity to be deleted at the next
  /// [update] loop.
  void deleteEntity(num entity) {
    var tmp = _components.where((c) => c.entity == entity);
    for (var component in tmp) component.deleteMe = true;
  }

  /// Gets the time elapsed since the last [update].
  num get deltaTime => _deltaTime;

  /// Deletes all the components and systems. After that the world needs to be
  /// re-initialized. It should only be used at the beginning of an [update]
  /// loop.
  void forceClear() {
    _components.clear();
    _unmanagedComponents.clear();
    _systems.clear();
    _clearMe = false;
    _lastAssignedEntity = -1;
  }

  /// Initialize the world. This function must be overridden and should
  /// contain all the systems registration and initialization code
  void initialize();

  /// Constant ID of an invalid or undefined entity
  static const num invalidEntity = -1;

  /// Returns the first component of the specified type owned by the entity.
  /// To get all components of a type, if necessary, run a filtered search on
  /// the result of a [getEntity] query.
  GameComponent getComponent(Type componentType, int entity) {
    return _components.firstWhere(
        (c) => c.runtimeType == componentType && c.entity == entity
        , orElse: () => null);
  }

  /// Returns all the components of a specified [Type] added to the world.
  List<GameComponent> getComponents(Type componentType) {
    return _components.where((c) => c.runtimeType == componentType).toList();
  }

  /// Return all components owned by an entity.
  List<GameComponent> getEntity(int entity) {
    return _components.where((c) => c.entity == entity).toList();
  }

  /// Return all components owned by an entity.
  GameSystem getSystem(Type type) {
    return _systems.firstWhere(
        (s) => s.runtimeType == type
        , orElse: () => null);
  }

  /// Returns a valid entity ID that can be immediately used with a new
  /// component.
  num get nextEntityId => _lastAssignedEntity + 1;

  /// Gets the time elapsed since the initialization of the world.
  num get time => _time;

  /// Updates the world status.
  ///
  /// A normal [update] method should look like this:
  ///   updateTime(deltaTime); // depends on how time is managed
  ///   clean();
  ///   updateAll();
  void update();

  /// Executes all the systems and unmanaged components [update] functions. It
  /// should be called inside an [update] method after [updateTime] and [clean].
  void updateAll() {
    for (var system in _systems) system.update(this);
    for (var component in _unmanagedComponents) component.update(this);
  }

  /// Updates the world time. This method should be the first one called by
  /// an overridden [update] method.
  void updateTime(num deltaTime) {
    _deltaTime = deltaTime;
    _time += deltaTime;
  }
}