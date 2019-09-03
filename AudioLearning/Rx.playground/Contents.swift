import RxSwift
import RxCocoa

print("A: ---")

let observer: AnyObserver<String> = AnyObserver { (event) in
    switch event {
    case .next(let str):
        print("next 1: \(str)")
    case .error(_): break
    case .completed:
        print("completed")
    }
}

Observable.just("Hello world").subscribe(observer)

print("B: ---")

Observable.just("This is RxSwift.").subscribe(onNext: { (str) in
    print("next 2: \(str)")
})

print("C: ---")

let behaviorSubject = BehaviorSubject<String>(value: "initial value")
_ = behaviorSubject.subscribe(onNext: { (str) in
    print(str)
}, onError: { (error) in
    print("Won't got an error")
}, onCompleted: {
    print("Completed")
}) {
    print("onDisposed")
}
behaviorSubject.onNext("second value")

print("D: ---")

let behaviorRelay = BehaviorRelay(value: "initial value 2")
_ = behaviorRelay.subscribe(onNext: { (str) in
    print(str)
}, onError: { (error) in
    print("Won't got an error")
}, onCompleted: {
    print("Completed")
}) {
    print("onDisposed")
}
behaviorRelay.accept("second value 2")

print("E: ---")

let alert = PublishSubject<String>()
alert.onNext("This is alert 1.")
//alert.onCompleted()
alert.subscribe(onNext: { (str) in
    print(str)
}, onCompleted: {
    print("Completed")
})
alert.onNext("This is alert 2.")

let subject = BehaviorSubject(value: 1)
subject.on(.next(2))
//subject.on(.completed)
subject.subscribe(onNext: { (int) in
    print(int)
}, onCompleted: {
    print("Completed.")
})
subject.on(.next(3))

print("F: ---")

var o = Observable<String>.create { (observer) -> Disposable in
    observer.onNext("Observable 1")
    return Disposables.create()
}
o.subscribe(onNext: { (str) in
    print(str)
})
o = Observable<String>.create { (observer) -> Disposable in
    observer.onNext("Observable 2")
    return Disposables.create()
}

