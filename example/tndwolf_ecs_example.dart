// Copyright (c) 2016, Luca Carbone. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:tndwolf/tndwolf_ecs.dart';

/// Sample component (managed)
class MyComponent extends GameComponent {
  MyComponent(num entity): super(entity, true) {}
}

/// Sample system
class MySystem extends GameSystem {
  List<MyComponent> _components;

  void initialize(World world) {
    _components = new List<MyComponent>();
  }

  bool register(GameComponent component) {
    if (component is MyComponent) {
      _components.add(component);
    }
  }

  void unregister(GameComponent component) {
    _components.remove(component);
  }

  void update(World world) {
    _components.forEach((c) => print("Managing component ${c.entity}"));
  }
}

/// Sample world implementation
class MyWorld extends World {
  void initialize() {
    addSystem(new MySystem());
  }

  void update() {
    updateTime(1);
    clean();
    updateAll();
  }
}

/// Example entry point
main() {
  var world = new MyWorld();
  world.addComponent(new MyComponent(world.nextEntityId));
  for(num i = 0; i < 3; i++) {
    world.update();
  }
  world.clear();
}
