import 'package:lg_functional_dart/lg_functional_dart.dart';
import 'package:test/test.dart';

class Animal {
  final String name;
  Animal(this.name);

  @override
  String toString() => name;
}

class FriendOfAnimals {
  final String name;
  final animals = <Animal>[];

  FriendOfAnimals(this.name);

  void addAnimal(String name) {
    animals.add(Animal(name));
  }
}

class Person {
  final Option<int> eta;
  Person({int eta = 0}) : eta = Some(eta);
}

void main() {
  group('A group of tests', () {
    var option = Option.some(0);
    Iterable<Person> population = [Person(eta: 40), Person(), Person(eta: 10)];

    setUp(() {
      option = Option.some(3);
      population = [Person(eta: 40), Person(), Person(eta: 10)];
    });

    test('First Test', () {
      expect(option.isSome, isTrue);

      final optionStr = option.map((t) => t.toString());
      optionStr.fold(() => fail('Value expected'), (some) => print(some));

      final none = Option<int>.none();
      final anotherNone = none.map((t) => t.toString());
      anotherNone.fold(() => null, (some) => fail('None expected'));

      anotherNone.foreach(print);
      optionStr.foreach(print);

      final l = <FriendOfAnimals>[];
      final luca = FriendOfAnimals('Luca');
      final giorgio = FriendOfAnimals('Giorgio');

      luca.addAnimal('Cerbero');
      luca.addAnimal('Fuffy');

      giorgio.addAnimal('Sissy');
      giorgio.addAnimal('Piccolo');
      l.addAll([luca, giorgio]);

      final nested = l.map((e) => e.animals);
      print(nested);

      final flat = l.bind((e) => e.animals);
      print(flat);

      option
          .where((t) => t > 0)
          .fold(() => fail('Value Expeted'), (some) => print(some));

      anotherNone
          .where((t) => true)
          .fold(() => null, (some) => fail('None expected'));

      expect(anotherNone.asIterable().length, 0);
      expect(option.asIterable().length, 1);

      final listOptionEta = population.map((p) => p.eta);
      expect(listOptionEta.length, 3);

      final listEta = population.flatMapOption((p) => p.eta);
      expect(listEta.length, 2);

      final optionalAges = Some(listEta);
      optionalAges.flatMap((t) => t.map((e) => e * 2));
      

      String test({int i = 0, String s = ''}) => '$s $i';

      final testPartial = ({int i = 0}) => ({String s = ''}) => test(i: i, s: s);
      final tp2 = testPartial(i: 10);
      print(tp2(s: 'ciao'));

      final testPartialSwapped = ({String s= ''}) => ({int i = 0}) => test(i: i, s: s);
      final tpswapped = testPartialSwapped(s: 'ciao swapped');
      print(tpswapped(i: 20));

    });

    test('Concatenation test', () async {
      Validation<double> getDouble() => Valid(2.0);
      Future<int> getInt() => Future(() => 1);

      Future<Validation<double>> getFutureDouble() => 2.0.toValidFuture();
      Future<Validation<int>> getFutureInt() => 2.toValidFuture<int>();

      getFutureDouble()
          .bindFuture((t) => getFutureInt())
          .map((t) => NoValue);

      getDouble()
          .mapFuture((val) => getInt())
          .fold(
              (failures) => fail('Success expected'),
              (val) => expect(1, val));
      getFutureDouble().tryCatch();

      getInt().tryCatch();
      int i = 0;
    });

    test('Composition test', () async {
      Option<int> getOne (bool isSome) => isSome ? Some(1) : None();
      Option<int> getTwo (bool isSome) => isSome ? Some(2) : None();

      Future<Validation<String>> getValidation(bool isInerror) => isInerror ? Invalid<String>(Exception('Failed').toFail()).toFuture()
                                                                            : Valid('Stringa valida').toFuture();
      final oi = getOne(true).toFutureOrElseDo(() => 
                    getValidation(true).fold((failures) => None(), 
                                              (val) => getTwo(true).orElseMap(() => 3)
                  ));
      final one = await oi;
      expect(one.orElse(0), 1);
      print (one.orElse(0));

      final none = await getOne(false).toFutureOrElseDo(() => 
                    getValidation(true).fold((failures) => None<int>(), 
                                              (val) => getTwo(true).orElseMap(() => 3)
                  ));
      expect(none.isSome, isFalse);

      final two = await getOne(false).toFutureOrElseDo(() => 
                    getValidation(false).fold((failures) => None<int>(), 
                                              (val) => getTwo(true).orElseMap(() => 3)
                  ));
      expect(two.orElse(0), 2);

      final three = await getOne(false).toFutureOrElseDo(() => 
                    getValidation(false).fold((failures) => None<int>(), 
                                              (val) => getTwo(false).orElseMap(() => 3)
                  ));
      expect(three.orElse(0), 3);

      await AssertionError().toFail().toInvalid<int>().toFuture();
    });

    test('Iterable tests', () async {
      final listOfOptions = [Some('Ciao'), Some('Hei'), None<String>()];
      var flatList = listOfOptions.flatten();
      expect(flatList.length, 2);

      final list = [['Ciao', 'Hei'], ['Hello']];
      flatList = list.flatten();
      expect(flatList, ['Ciao', 'Hei', 'Hello']);
    });
  });
}
