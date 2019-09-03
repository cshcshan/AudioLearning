//
//  EpisodeListViewModelTests.swift
//  AudioLearningTests
//
//  Created by Han Chen on 2019/9/2.
//  Copyright © 2019 cshan. All rights reserved.
//

import XCTest
import RxTest
import RxSwift
import RxCocoa
@testable import AudioLearning

// swiftlint:disable force_try
class EpisodeListViewModelTests: XCTestCase {
    
    var sut: EpisodeListViewModel!
    var apiService: MockAPIService!
    
    var scheduler: TestScheduler!
    var disposeBag: DisposeBag!

    override func setUp() {
        super.setUp()
        apiService = MockAPIService()
        sut = EpisodeListViewModel(apiService: apiService)
        scheduler = TestScheduler(initialClock: 0)
        disposeBag = DisposeBag()
    }

    override func tearDown() {
        sut = nil
        apiService = nil
        super.tearDown()
    }
    
    func testInit() {
        let bundle = Bundle(for: type(of: self))
        let urlString = bundle.path(forResource: "6-minute-english", ofType: "html")!
        let url = URL(fileURLWithPath: urlString)
        let html = try! String(contentsOf: url)
        let episodesModels = ParseSixMinutesHelper().parseHtmlToEpisodeModels(by: html, urlString: urlString)
        
        let expectingModel = EpisodeModel(episode: "Episode 190822",
                                          title: "Does your age affect your political views?",
                                          desc: "Age and political views",
                                          date: "22 Aug 2019".toDate(dateFormat: "dd MMM yyyy"),
                                          imagePath: "http://ichef.bbci.co.uk/images/ic/976xn/p07jtrrn.jpg",
                                          path: "/learningenglish/english/features/6-minute-english/ep-190822")
        
        apiService.episodesReturnValue = .just(episodesModels)
        
        // Create a MockObserver<[EpisodeModel]>
        let episodes = scheduler.createObserver([EpisodeModel].self)
        
        // Output combines with the MockObserver(episodes above)
        sut.episodes
            .bind(to: episodes)
            .disposed(by: disposeBag)
        
        // MockObservable combines with Input
        scheduler.createColdObservable([.next(0, ()),
                                        .next(10, ()),
                                        .next(200, ())])
            .bind(to: sut.reload)
            .disposed(by: disposeBag)
        
        scheduler.start()
        
        XCTAssertEqual(episodes.events.count, 3)
        
        let firstModel = episodes.events.first!.value.element!.first!
        XCTAssertEqual(firstModel, expectingModel)
    }
    
    func testInit_WithError() {
        let error = NSError(domain: "unit test", code: 2, userInfo: nil)
        let expectingModel = AlertModel(title: "Get Episode List Error",
                                        message: error.localizedDescription)
        apiService.episodesReturnValue = .error(error)
        
        let alert = scheduler.createObserver(AlertModel.self)
        sut.alert
            .bind(to: alert)
            .disposed(by: disposeBag)
        scheduler.createColdObservable([.next(300, ())])
            .bind(to: sut.reload)
            .disposed(by: disposeBag)
        
        // ###
        sut.episodes
            .subscribe()
            .disposed(by: disposeBag)

        scheduler.start()

        XCTAssertEqual(alert.events.count, 1)
        XCTAssertEqual(alert.events, [.next(300, expectingModel)])
    }
}
// swiftlint:enable force_try
