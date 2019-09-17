//
//  EpisodeListCoordinator.swift
//  AudioLearning
//
//  Created by Han Chen on 2019/9/11.
//  Copyright © 2019 cshan. All rights reserved.
//

import RxSwift

class BaseCoordinator<ResultType> {

    let disposeBag = DisposeBag()

    private let identifier = UUID()
    private var childCoordinators = [UUID: Any]()

    func start() -> Observable<ResultType> {
        fatalError("Start method should be implemented.")
    }
    
    /*
     1. Stores coordinator in a dictionary of child coordinators.
     2. Calls method start() on that coordinator.
     3. On the 'onNext:' of returning observable of method start() removes coordinator from the dictionary
    */
    func coordinate<T>(to coordinator: BaseCoordinator<T>) -> Observable<T> {
        store(coordinator: coordinator)
        return coordinator.start()
            .do(onNext: { [weak self] _ in self?.free(coordinator: coordinator) })
    }

    // Stores coordinator to the childCoordinators dictionary.
    private func store<T>(coordinator: BaseCoordinator<T>) {
        childCoordinators[coordinator.identifier] = coordinator
    }

    // Release coordinator from the childCoordinators dictionary.
    private func free<T>(coordinator: BaseCoordinator<T>) {
        childCoordinators[coordinator.identifier] = nil
    }
}
