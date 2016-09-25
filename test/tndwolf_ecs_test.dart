// Copyright (c) 2016, Luca Carbone. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:tndwolf/tndwolf_ecs.dart';
import 'package:test/test.dart';

class ManagedComponent extends GameComponent {
  ManagedComponent(num entity): super(entity, true) {}
}

class MySystem extends GameSystem {
  List<ManagedComponent> components;
  num iter = 0;
  void initialize(World world) {
    iter = 0;
    components = new List<ManagedComponent>();
  }
  bool register(GameComponent component) {
    if (component is ManagedComponent)
      components.add(component);
  }
  void unregister(GameComponent component) {
    components.remove(component);
  }
  void update(World world) {
    iter++;
    components.forEach((c) => print("Managing component ${c.entity}"));
  }
}

/// Test implementation
class MyWorld extends World {
  void initialize() { }
  void update() {
    updateTime(1);
    clean();
    updateAll();
  }
}

class UnmanagedComponent extends GameComponent {
  num iter = 0;
  UnmanagedComponent(num entity): super(entity, false) {}
  void update(World world) {
    iter++;
    print("UnmanagedComponent $entity update $iter");
  }
}

void main() {
  group('tndwolf.ecs tests', () {
    MyWorld world;
    ManagedComponent managed;
    UnmanagedComponent unmanaged;

    setUp(() {
      world = new MyWorld();
      managed = new ManagedComponent(1);
      unmanaged = new UnmanagedComponent(2);
      world.addSystem(new MySystem());
    });

    test('Components creation', () {
      expect(managed.entity, 1);
      expect(managed.isManaged, isTrue);
      expect(unmanaged.entity, 2);
      expect(unmanaged.isManaged, isFalse);
      expect(world.nextEntityId, 0);
      world.addComponent(managed);
      expect(world.nextEntityId, 2);
      world.addComponent(unmanaged);
      expect(world.nextEntityId, 3);
      expect(world.getComponent(ManagedComponent, 1), isNotNull);
      expect(world.getComponent(ManagedComponent, 1).entity, 1);
      expect(world.getComponent(UnmanagedComponent, 1), isNull);
      expect(world.getComponent(UnmanagedComponent, 2).entity, 2);
    });

    test('Setting systems and components', () {
      world.addComponent(managed);
      world.addComponent(unmanaged);
      world.update();
      expect(world.time, 1);
      expect(world.getComponent(ManagedComponent, 1), isNotNull);
      expect(world.getComponent(UnmanagedComponent, 2).iter, 1);
    });

    test('Updates', () {
      world.addComponent(managed);
      world.addComponent(unmanaged);
      world.update();
      expect(world.time, 1);
      expect(world.getSystem(MySystem).iter, 1);
      expect(world.getComponent(UnmanagedComponent, 2).iter, 1);
      world.update();
      expect(world.time, 2);
      expect(world.getSystem(MySystem).iter, 2);
      expect(world.getComponent(UnmanagedComponent, 2).iter, 2);
    });

    test('Clear components', () {
      world.addComponent(managed);
      world.addComponent(unmanaged);
      print("CLEAR ENTITIES - First pass (2 components)");
      world.update();
      expect(world.time, 1);
      world.clearEntities();
      expect(world.getComponent(ManagedComponent, 1), isNotNull);
      expect(world.getComponent(UnmanagedComponent, 2), isNotNull);
      expect(world.getSystem(MySystem).components.length, 1);
      print("CLEAR ENTITIES - Second pass (0 components)");
      world.update();
      expect(world.time, 2);
      expect(world.getComponent(ManagedComponent, 1), isNull);
      expect(world.getComponent(UnmanagedComponent, 2), isNull);
      expect(world.getSystem(MySystem).components.length, 0);
      world.addComponent(new ManagedComponent(3));
      world.addComponent(new UnmanagedComponent(4));
      print("CLEAR ENTITIES - Third pass (2 new components");
      world.update();
      expect(world.time, 3);
      expect(world.getComponent(ManagedComponent, 1), isNull);
      expect(world.getComponent(UnmanagedComponent, 2), isNull);
      expect(world.getComponent(ManagedComponent, 3), isNotNull);
      expect(world.getComponent(UnmanagedComponent, 4), isNotNull);
      expect(world.getSystem(MySystem).components.length, 1);
    });

    test('Clear world', () {
      world.addComponent(managed);
      world.addComponent(unmanaged);
      world.update();
      world.clear();
      expect(world.getComponent(ManagedComponent, 1), isNotNull);
      expect(world.getComponent(UnmanagedComponent, 2), isNotNull);
      expect(world.getSystem(MySystem).components.length, 1);
      world.update();
      expect(world.getComponent(ManagedComponent, 1), isNull);
      expect(world.getComponent(UnmanagedComponent, 2), isNull);
      expect(world.getSystem(MySystem), isNull);
    });
  });
}
