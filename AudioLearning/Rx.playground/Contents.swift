import RxSwift
import RxCocoa

let disposeBag = DisposeBag()

print("\nH: --- two observers, one observables")

let h1 = AnyObserver<String> { (event) in
    switch event {
    case .next(let str):
        print("next 1: \(str)")
    case .error(_): break
    case .completed:
        print("completed 1")
    }
}

let h2 = AnyObserver<String> { (event) in
    switch event {
    case .next(let str):
        print("next 2: \(str)")
    case .error(_): break
    case .completed:
        print("completed 2")
    }
}

let h = Observable<String>
    .create({ (observer) -> Disposable in
        observer.onNext("Observable")
        return Disposables.create()
    })

h.bind(to: h1).disposed(by: disposeBag)
h.bind(to: h2).disposed(by: disposeBag)

print("\nG: --- one observer, two observables")

let g = PublishSubject<String>()
let gObserver: AnyObserver<String> = g.asObserver()

g.subscribe(onNext: { (text) in
    print("1: \(text)")
}).disposed(by: disposeBag)

g.subscribe(onNext: { (text) in
    print("2: \(text)")
}).disposed(by: disposeBag)

gObserver.onNext("GG")

print("\nF: ---")

var f = Observable<String>
    .create({ (observer) -> Disposable in
        observer.onNext("Observable 1")
        return Disposables.create()
    })
f
    .subscribe(onNext: { (str) in
        print(str)
    })
    .disposed(by: disposeBag)
f = Observable<String>
    .create({ (observer) -> Disposable in
        observer.onNext("Observable 2")
        return Disposables.create()
    })
f
    .subscribe(onNext: { (str) in
        print(str)
    })
    .disposed(by: disposeBag)

print("\nE: --- emit next and complete")

let e1 = PublishSubject<String>()
e1.onNext("This is e1's first emission.") // haven't subscribed yet
e1
    .subscribe(onNext: { (str) in
        print(str)
    }, onCompleted: {
        print("e1 Completed")
    })
    .disposed(by: disposeBag)
e1.onNext("This is e1's second emission.")

let e2 = BehaviorSubject(value: 1)
e2.on(.next(2))
e2
    .subscribe(onNext: { (int) in
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
    .subscribe(onNext: { (str) in
        print(str)
    }, onError: { (error) in
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
    .subscribe(onNext: { (str) in
        print(str)
    }, onError: { (error) in
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
    .subscribe(onNext: { (str) in
        print("next: \(str)")
    })
    .disposed(by: disposeBag)

print("\nA: --- create AnyObserver with subscribe")

let observer: AnyObserver<String> = AnyObserver { (event) in
    switch event {
    case .next(let str):
        print("next: \(str)")
    case .error(_): break
    case .completed:
        print("completed")
    }
}

Observable.just("AA 1").subscribe(observer).disposed(by: disposeBag)
Observable.just("AA 2").subscribe(observer).disposed(by: disposeBag)

