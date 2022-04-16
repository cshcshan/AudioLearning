import RxCocoa
import RxSwift

let disposeBag = DisposeBag()

print("\nM: --- scan and reduce")

print("------ scan")
Observable.of(10, 100, 1000)
    .scan(1) { aggregateValue, newValue in
        aggregateValue + newValue
    }
    .subscribe(onNext: { print($0) })
    .disposed(by: disposeBag)

print("------ reduce")
Observable.of(10, 100, 1000)
    .reduce(1, accumulator: +)
    .subscribe(onNext: { print($0) })
    .disposed(by: disposeBag)

print("\nL: --- subscribeOn")

func currentQueueName() -> String? {
    let name = __dispatch_queue_get_label(nil)
    return String(cString: name, encoding: .utf8)
}

Observable<Int>
    .create { observer in
        observer.onNext(1)
        sleep(1)
        observer.onNext(2)
        return Disposables.create()
    }
    .map { value -> Int in
        print("\n\n 😀 Queue A: \(currentQueueName() ?? "queue")")
        return value * 2
    }
    .subscribeOn(SerialDispatchQueueScheduler(qos: .background))
    .map { value -> Int in
        print(" 😀 Queue B: \(currentQueueName() ?? "queue")")
        return value * 3
    }
    .observeOn(MainScheduler.instance)
    .subscribe(onNext: { element in
        print(" 😀 Queue C: \(element) \(currentQueueName() ?? "queue")")
    })
    .disposed(by: disposeBag)

print("\nK: --- observeOn")

Observable<Int>
    .create { observer in
        observer.onNext(1)
        sleep(1)
        observer.onNext(2)
        return Disposables.create()
    }
    .map { value -> Int in
        print("\n\n 😀 Queue A: \(currentQueueName() ?? "queue")")
        return value * 2
    }
    .observeOn(SerialDispatchQueueScheduler(qos: .background))
    .map { value -> Int in
        print(" 😀 Queue B: \(currentQueueName() ?? "queue")")
        return value * 3
    }
    .observeOn(MainScheduler.instance)
    .subscribe(onNext: { element in
        print(" 😀 Queue C: \(element) \(currentQueueName() ?? "queue")")
    })
    .disposed(by: disposeBag)

print("\nJ: --- duplicate subscription")

let j = PublishSubject<Void>()

j.subscribe(onNext: { _ in
    print("next 1")
}).disposed(by: disposeBag)

j.subscribe(onNext: { _ in
    print("next 2")
}).disposed(by: disposeBag)

j.onNext(())

print("\nI: --- do, afterNext")
Observable.of("AAA", "BBB", "CCC")
    .flatMapLatest { str -> Observable<String> in
        .just("\(str)Test")
    }
    .do(onNext: { str in
        print("do - onNext: \(str)")
    }, afterNext: { str in
        print("do - afterNext: \(str)")
    }, onError: { error in
        print("do - onError: \(error)")
    }, afterError: { error in
        print("do - afterError: \(error)")
    }, onCompleted: {
        print("do - onCompleted")
    }, afterCompleted: {
        print("do - afterCompleted")
    }, onSubscribe: {
        print("do - onSubscribe")
    }, onSubscribed: {
        print("do - onSubscribed")
    }, onDispose: {
        print("do - onDispose")
    })
    .subscribe(onNext: { str in
        print("subscribe - onNext: \(str)")
    }, onError: { error in
        print("subscribe - onError: \(error)")
    }, onCompleted: {
        print("subscribe - onCompleted")
    }, onDisposed: {
        print("subscribe - onDispose")
    })
    .disposed(by: disposeBag)

print("\nH: --- two observers, one observables")

let h1 = AnyObserver<String> { event in
    switch event {
    case .next(let str):
        print("next 1: \(str)")
    case .error: break
    case .completed:
        print("completed 1")
    }
}

let h2 = AnyObserver<String> { event in
    switch event {
    case .next(let str):
        print("next 2: \(str)")
    case .error: break
    case .completed:
        print("completed 2")
    }
}

let h = Observable<String>
    .create { observer -> Disposable in
        observer.onNext("Observable")
        return Disposables.create()
    }

h.bind(to: h1).disposed(by: disposeBag)
h.bind(to: h2).disposed(by: disposeBag)

print("\nG: --- one observer, two observables")

let g = PublishSubject<String>()
let gObserver: AnyObserver<String> = g.asObserver()

g.subscribe(onNext: { text in
    print("1: \(text)")
}).disposed(by: disposeBag)

g.subscribe(onNext: { text in
    print("2: \(text)")
}).disposed(by: disposeBag)

gObserver.onNext("GG")

print("\nF: ---")

var f = Observable<String>
    .create { observer -> Disposable in
        observer.onNext("Observable 1")
        return Disposables.create()
    }

f
    .subscribe(onNext: { str in
        print(str)
    })
    .disposed(by: disposeBag)
f = Observable<String>
    .create { observer -> Disposable in
        observer.onNext("Observable 2")
        return Disposables.create()
    }

f
    .subscribe(onNext: { str in
        print(str)
    })
    .disposed(by: disposeBag)

print("\nE: --- emit next and complete")

let e1 = PublishSubject<String>()
e1.onNext("This is e1's first emission.") // haven't subscribed yet
e1
    .subscribe(onNext: { str in
        print(str)
    }, onCompleted: {
        print("e1 Completed")
    })
    .disposed(by: disposeBag)
e1.onNext("This is e1's second emission.")

let e2 = BehaviorSubject(value: 1)
e2.on(.next(2))
e2
    .subscribe(onNext: { int in
        print(int)
    }, onCompleted: {
        print("e2 Completed.")
    })
    .disposed(by: disposeBag)
e2.on(.next(3))
e2.on(.completed) // observing e2 is finished so next emissions below won't work.
e2.onNext(4)

print("\nD: --- BehaviorRelay")

let behaviorRelay = BehaviorRelay(value: "initial value")
behaviorRelay
    .subscribe(onNext: { str in
        print(str)
    }, onError: { _ in
        print("Won't got an error")
    }, onCompleted: {
        print("Completed")
    }) {
        print("onDisposed")
    }
    .disposed(by: disposeBag)
behaviorRelay.accept("second value")

print("\nC: --- BehaviorSubject")

let behaviorSubject = BehaviorSubject<String>(value: "initial value")
_ = behaviorSubject
    .subscribe(onNext: { str in
        print(str)
    }, onError: { _ in
        print("Won't got an error")
    }, onCompleted: {
        print("Completed")
    }) {
        print("onDisposed")
    }
    .disposed(by: disposeBag)
behaviorSubject.onNext("second value")

print("\nB: ---")

Observable
    .just("This is RxSwift.")
    .subscribe(onNext: { str in
        print("next: \(str)")
    })
    .disposed(by: disposeBag)

print("\nA: --- create AnyObserver with subscribe")

let observer: AnyObserver<String> = AnyObserver { event in
    switch event {
    case .next(let str):
        print("next: \(str)")
    case .error: break
    case .completed:
        print("completed")
    }
}

Observable.just("AA 1").subscribe(observer).disposed(by: disposeBag)
Observable.just("AA 2").subscribe(observer).disposed(by: disposeBag)
