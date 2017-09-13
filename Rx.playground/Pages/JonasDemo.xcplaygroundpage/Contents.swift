//: [Previous](@previous)

import Foundation
import RxSwift

extension ObservableType {
    func demoObserver(_ id: String) -> Disposable {
        return subscribe { print("Subscription:", id, "Event:", $0) }
    }
}

example("PublishSubject") {
    let disposeBag = DisposeBag()
    let subject = PublishSubject<String>()
    
    subject.demoObserver("1").disposed(by: disposeBag)
    subject.onNext("🐶")
    subject.onNext("🐱")
    
    subject.demoObserver("2").disposed(by: disposeBag)
    subject.onNext("🅰️")
    subject.onNext("🅱️")
}

example("map") {
    let disposeBag = DisposeBag()
    
    let subject = PublishSubject<Int>()
    
    subject
        .map { $0 * 10 }
        .subscribe(onNext: { print($0) })
        .disposed(by: disposeBag)
    
    subject.onNext(1)
    subject.onNext(2)
    subject.onNext(3)
}

example("filter") {
    let disposeBag = DisposeBag()
    
    let subject = PublishSubject<Int>()
    
    subject
        .map { $0 * 10 }
        .filter { $0 > 15 }
        .subscribe(onNext: { print($0) })
        .disposed(by: disposeBag)
    
    subject.onNext(1)
    subject.onNext(2)
    subject.onNext(3)
}

example("distinctUntilChanged") {
    let disposeBag = DisposeBag()
    
    Observable.of(1, 2, 3, 3, 3, 3, 3, 4, 1)
        .distinctUntilChanged()
        .subscribe(onNext: { print($0) })
        .disposed(by: disposeBag)
}

example("error") {
    let disposeBag = DisposeBag()
    
    let sequenceThatFails = PublishSubject<String>()
    
    sequenceThatFails
        .subscribe { print($0) }
        .disposed(by: disposeBag)
    
    sequenceThatFails.onNext("😬")
    sequenceThatFails.onError(TestError.test)
    sequenceThatFails.onNext("😨")
    sequenceThatFails.onNext("😡")
}

example("catchErrorJustReturn") {
    let disposeBag = DisposeBag()
    
    let sequenceThatFails = PublishSubject<String>()
    
    sequenceThatFails
        .catchErrorJustReturn("😊")
        .subscribe { print($0) }
        .disposed(by: disposeBag)
    
    sequenceThatFails.onNext("😬")
    sequenceThatFails.onNext("😨")
    sequenceThatFails.onError(TestError.test)
}

func fakeNetworkRequest(s: String) -> Observable<Int> {
    let myDelay = Double(arc4random()).truncatingRemainder(dividingBy: 10)
    print(myDelay)
    let scheduler = ConcurrentDispatchQueueScheduler(qos: DispatchQoS.background)
    return Observable.of(s.characters.count).delay(myDelay, scheduler: scheduler)
}

example("flatMapLatest") {
    
    let disposeBag = DisposeBag()
    
    let name = PublishSubject<String>()
    
    name
        .flatMapLatest { name in fakeNetworkRequest(s: name) }
        .observeOn(MainScheduler.instance)
        .subscribe { print($0) }
    
    name.onNext("j")
    name.onNext("jo")
    name.onNext("jon")
    name.onNext("jona")
    name.onNext("jonas")
    name.onCompleted()
}
//: [Next](@next)
