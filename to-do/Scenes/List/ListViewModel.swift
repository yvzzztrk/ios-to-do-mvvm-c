//
//  ListViewModel.swift
//  to-do
//
//  Created by YAVUZ OZTURK on 24/11/2020.
//

import RxSwift
import RxCocoa

class ListViewModel: BaseViewModel {

}

extension ListViewModel: ViewModelType {

    struct Input {

        let viewWillAppear: Observable<Void>
        let todoItemSelected: ControlEvent<TodoModel>
        let addTodoTapped: ControlEvent<Void>
    }

    struct Output {

        let title: Driver<String>
        let todoItems: BehaviorRelay<[TodoModel]>
        let navigateToDetail: Driver<TodoModel?>
    }

    func transform(input: Input) -> Output {

        let todoItems = BehaviorRelay<[TodoModel]>(value: [])

        input
            .viewWillAppear
            .flatMapLatest({ [weak self] () -> Observable<[TodoModel]> in

                guard let strongSelf = self else { return .empty() }
                return strongSelf.provider.rx.list
            })
            .bind(to: todoItems)
            .disposed(by: disposeBag)

        let addTodoTap = input
            .addTodoTapped
            .asDriver()
            .map({ () -> TodoModel? in nil })
        
        let todoItemSelected = input
            .todoItemSelected
            .flatMapLatest({ [weak self] (model) -> Observable<TodoModel?> in

                guard let strongSelf = self else { return .empty() }
                return strongSelf.provider.rx.detail(id: model.id)
            })
            .asDriver(onErrorDriveWith: .never())
            .map({ (todoItem) -> TodoModel? in return todoItem })

        let navigateToDetail = Driver.merge(addTodoTap, todoItemSelected)

        return Output(
            title: .just("To-Do's"),
            todoItems: todoItems,
            navigateToDetail: navigateToDetail)
    }
}
