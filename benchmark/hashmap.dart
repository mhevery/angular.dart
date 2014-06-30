library hashmap_perf;

import 'package:benchmark_harness/benchmark_harness.dart';

class MapRead extends BenchmarkBase {
  final Map<String, object> map;

  MapRead(name): super(name) {
    map[".a"] = 1;
    map[".b"] = 1;
    map[".c"] = 1;
    map[".d"] = 1;
    map[".e"] = 1;

    map[".f"] = 1;
    map[".g"] = 1;
    map[".h"] = 1;
    map[".i"] = 1;
    map[".j"] = 1;

    map[".k"] = 1;
    map[".l"] = 1;
    map[".m"] = 1;
    map[".n"] = 1;
    map[".p"] = 1;

    map[".q"] = 1;
    map[".r"] = 1;
    map[".s"] = 1;
    map[".t"] = 1;
    map[".u"] = 1;
  }

  run() {
    String keys = '.a.b.c.d.e.f.g.h.i.j.k.l.m.n.p.q.r.s.t.u';
    int sum = 0;
    int count = 17;
    for(var i = 0; i < count; i++) {
      sum += map[keys.substring(i * 2, (i * 2) + 2)];
    }
    if (sum != count) throw "Error";
    return sum;
  }
}

class HashmapRead extends MapRead {
  Map<String, objec> map = {};
  HashmapRead() : super('HashMapRead');
}

class FastMapRead extends MapRead {
  Map<String, object> map = new FastMap();
  FastMapRead() : super('FastMapRead');
}

class FastMap implements Map {
  var key0; var obj0;
  var key1; var obj1;
  var key2; var obj2;
  var key3; var obj3;
  var key4; var obj4;
  var key5; var obj5;
  var key6; var obj6;
  var key7; var obj7;
  var key8; var obj8;
  var key9; var obj9;
  var key10; var obj10;
  var key11; var obj11;
  var key12; var obj12;
  var key13; var obj13;
  var key14; var obj14;
  var key15; var obj15;
  var key16; var obj16;
  var key17; var obj17;
  var key18; var obj18;
  var key19; var obj19;

  V operator [](Object key) {
    if (key == key0) return obj0;
    if (key == key1) return obj1;
    if (key == key2) return obj2;
    if (key == key3) return obj3;
    if (key == key4) return obj4;
    if (key == key5) return obj5;
    if (key == key6) return obj6;
    if (key == key7) return obj7;
    if (key == key8) return obj8;
    if (key == key9) return obj9;
    if (key == key10) return obj10;
    if (key == key11) return obj11;
    if (key == key12) return obj12;
    if (key == key13) return obj13;
    if (key == key14) return obj14;
    if (key == key15) return obj15;
    if (key == key16) return obj16;
    if (key == key17) return obj17;
    if (key == key18) return obj18;
    if (key == key19) return obj19;
    return null;
  }

  void operator []=(K key, V value) {
    if      (key0 == null) { key0 = key; obj0 = value; }
    else if (key1 == null) { key1 = key; obj1 = value; }
    else if (key2 == null) { key2 = key; obj2 = value; }
    else if (key3 == null) { key3 = key; obj3 = value; }
    else if (key4 == null) { key4 = key; obj4 = value; }
    else if (key5 == null) { key5 = key; obj5 = value; }
    else if (key6 == null) { key6 = key; obj6 = value; }
    else if (key7 == null) { key7 = key; obj7 = value; }
    else if (key8 == null) { key8 = key; obj8 = value; }
    else if (key9 == null) { key9 = key; obj9 = value; }
    else if (key10 == null) { key10 = key; obj10 = value; }
    else if (key11 == null) { key11 = key; obj11 = value; }
    else if (key12 == null) { key12 = key; obj12 = value; }
    else if (key13 == null) { key13 = key; obj13 = value; }
    else if (key14 == null) { key14 = key; obj14 = value; }
    else if (key15 == null) { key15 = key; obj15 = value; }
    else if (key16 == null) { key16 = key; obj16 = value; }
    else if (key17 == null) { key17 = key; obj17 = value; }
    else if (key18 == null) { key18 = key; obj18 = value; }
    else if (key19 == null) { key19 = key; obj19 = value; }
    else throw "full: $key $value";
  }
}

main() {
  new FastMapRead().report();
  new HashmapRead().report();
}
