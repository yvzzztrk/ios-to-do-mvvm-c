//
//  ListViewModelTests.swift
//  to-doTests
//
//  Created by YAVUZ OZTURK on 26/11/2020.
//

import XCTest
import RxSwift
import RxCocoa
@testable import to_do

class ListViewModelTests: XCTestCase {

    var viewModel: ListViewModel!
    var provider: RealmProvider!
    var disposeBag: DisposeBag!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        provider = RealmProvider(test: true)
        viewModel = ListViewModel(provider: provider)
        disposeBag = DisposeBag()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        provider = nil
        viewModel = nil
        disposeBag = nil
    }

    func testListViewModel() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.

        Observable.just(TodoModel(title: "to-do 1", done: false)).bind(to: provider.rx.create).disposed(by: disposeBag)
        Observable.just(TodoModel(title: "to-do 2", done: false)).bind(to: provider.rx.create).disposed(by: disposeBag)
        Observable.just(TodoModel(title: "to-do 3", done: false)).bind(to: provider.rx.create).disposed(by: disposeBag)

        let viewWillAppear = PublishSubject<Void>()
        let todoItemSelected = PublishSubject<TodoModel>()
        let addTodoTapped = PublishSubject<Void>()

        let input = ListViewModel.Input(viewWillAppear: viewWillAppear.asObservable(),
                                        todoItemSelected: ControlEvent<TodoModel>(events: todoItemSelected),
                                        addTodoTapped: ControlEvent<Void>(events: addTodoTapped))
        let output = viewModel.transform(input: input)

        XCTAssertEqual(output.todoItems.value.count, 0)
        viewWillAppear.onNext(())
        XCTAssertEqual(output.todoItems.value.count, 3)

        let selectedItem = output.todoItems.value.last
        XCTAssertNotNil(selectedItem)

        if let selectedItem = selectedItem {
            output.navigateToDetail.drive(onNext: { (item) in

                guard let item = item else { return }
                XCTAssertEqual(selectedItem.id, item.id)
            }).disposed(by: disposeBag)
            todoItemSelected.onNext(selectedItem)
        }

        output.navigateToDetail.filter({ $0 == nil }).drive(onNext: { (item) in
            XCTAssertNil(item)
        }).disposed(by: disposeBag)
        addTodoTapped.onNext(())
        
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
