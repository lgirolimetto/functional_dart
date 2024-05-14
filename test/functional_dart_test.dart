import 'package:basic_functional_dart/basic_functional_dart.dart';
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

    test('Pure metadata', () {
      @pure
      int i;
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

    test('ValidatedResult test', () async {
      double getDouble() {
        return 2.0;
      }

      Future<double> getFutureDouble() {
        return 2.0.toFuture();
      }

      double failDouble() {
        throw Error();
      }

      Future<double> failFutureDouble() {
        throw Error();
      }

      double mulBy3(double d) {
        print('mulBy3');
        return 3 * d;
      }

      Future<double> futureMulBy3(double d) {
        return Future
                .value(3 * d)
                .then((value) {
                  print('future mulBy3');
                  return value;
                });
      }

      double failMulBy3(double d) {
        throw Error();
      }

      Future<double> failFutureMulBy3(double d) {
        return Future.value(1.0).then((value) => throw Error());
      }

      Future<double> syncFailFutureMulBy3(double d) {
        return throw Error();
      }

      try_(() => failDouble())
        .try_((val) => mulBy3(val))
        .fold(
          (failure) => failure
                        .fold(
                          (err) => print(err),
                          (exc) => fail('Expected failure with Error')
                        ),
          (val) => fail('Expected failure')
        );

      try_(() => getDouble())
          .try_((val) => mulBy3(val))
          .fold(
            (failure) => fail('Expected Success'),
            (val) => expect(val, 6)
          );

      await try_(() => getDouble())
          .tryFuture((val) => failFutureMulBy3(val))
          .fold(
              (failure) => print(failure),
              (val) => fail('Expected Failure')
      );

      await tryFuture(() => getFutureDouble())
          .try_((val) => mulBy3(val))
          .fold(
              (failure) => fail('Expected Success'),
              (val) => expect(val, 6)
      );

      await tryFuture(() => getFutureDouble())
          .tryFuture((val) => futureMulBy3(val))
          .fold(
              (failure) => fail('Expected Success'),
              (val) => expect(val, 6)
      );

      await tryFuture(() => getFutureDouble())
          .tryFuture((val) => failFutureMulBy3(val))
          .fold(
              (failure) => failure
                            .fold(
                              (err) => print(err),
                              (exc) => fail('Expected failure with Error'),
                            ),
              (val) => fail('Expected Failure'),
      );

      await tryFuture(() => getFutureDouble())
          .tryFuture((val) => syncFailFutureMulBy3(val))
          .fold(
            (failure) => failure
                          .fold(
                            (err) => print(err),
                            (exc) => fail('Expected failure with Error'),
                          ),
            (val) => fail('Expected Failure'),
          );
    });

    test('ValidatedResult with errorCode test', () async {
      const int errorCodeGetDoubleFail = 1;
      const int errorCodeMulFail = 2;

      double getDouble() {
        return 2.0;
      }

      double failDouble() {
        throw Error();
      }

      Future<double> futureFailDouble() {
        throw Error();
      }

      double failMulBy3(double d) {
        throw Error();
      }

      double mulBy3(double d) {
        print('mulBy3');
        return 3 * d;
      }

      Future<double> futureMulBy3(double d) {
        return Future.value(3 * d);
      }

      double mulBy6(double d) {
        print('mulBy6');
        return 6 * d;
      }

      try_(
        () => getDouble(),
        internalErrorCode: errorCodeGetDoubleFail
      )
      .try_(
        (d) => failMulBy3(d),
        internalErrorCode: errorCodeMulFail
      )
      .fold(
        (failure) => expect(failure.internalErrorCode, errorCodeMulFail),
        (val) => fail('Failure expected')
      );

      try_(
        () => failDouble(),
        internalErrorCode: errorCodeGetDoubleFail
      )
      .map((d) => mulBy3.apply(d).try_().orElseRetry(() => mulBy6(d)))
      .fold(
          (failure) => expect(failure.internalErrorCode, errorCodeGetDoubleFail),
          (val) => fail('Failure expected')
      );
    });

    test('Parallel Isolates', () async {
      var t = await List
          .generate(10, (index) => () => index.isEven
                                          ? Future.delayed(const Duration(seconds: 1), index.toString)
                                          : Future<String>.delayed(const Duration(seconds: 1), throw Exception('Forced Exception'))
                    )
          .tryAsParallel()
          .fold_(
            (failures) => expect(failures.length, 5),
            (values) => expect(values.length, 5),
          );

      t = await List
          .generate(10, (index) => () => index.isEven
            ? Future.delayed(const Duration(seconds: 1), index.toString)
            : Future<String>.delayed(const Duration(seconds: 1), throw Exception('Forced Exception'))
          )
          .tryAsParallel()
          .failsIfAllFailures()
          .fold(
            (failures) => fail('Failure not expected'),
            (values) => expect(values.length, 5),
      );

      t = await List
          .generate(10, (index) => () => index.isEven
            ? Future.delayed(const Duration(seconds: 1), index.toString)
            : Future<String>.delayed(const Duration(seconds: 1), throw Exception('Forced Exception'))
          )
          .tryAsParallel()
          .failsIfSomeFailures(internalErrorCode: 5)
          .fold(
            (failures) => expect(failures.internalErrorCode, 5),
            (values) => fail('Success not expected'),
      );

      t = await List
          .generate(10, (index) => () => index.isEven
              ? Future.delayed(const Duration(seconds: 1), index.toString)
              : Future<String>.delayed(const Duration(seconds: 1), throw Exception('Forced Exception'))
          )
          .tryAsParallel()
          .failsIfAllFailures(internalErrorCode: 5)
          .mapI((s) => '$s -> success')
          .fold(
            (failures) => fail('Failure not expected'),
            (values) => expect(values, ['0 -> success', '2 -> success', '4 -> success', '6 -> success', '8 -> success']),
      );
    });
  });
}
