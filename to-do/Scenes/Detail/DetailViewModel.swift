//
//  DetailViewModel.swift
//  to-do
//
//  Created by YAVUZ OZTURK on 25/11/2020.
//

import RxSwift
import RxCocoa

class DetailViewModel: BaseViewModel {

    var todoItem: TodoModel?

    init(provider: RealmProvider, todoItem: TodoModel?) {

        self.todoItem = todoItem
        super.init(provider: provider)
    }
}

extension DetailViewModel: ViewModelType {

    struct Input {

        let textChanged: Observable<String?>
        let doneTodoTapped: ControlEvent<Void>
        let deleteTodoTapped: ControlEvent<Void>
        let doneTodoEnabled: Binder<Bool>
        let deleteTodoEnabled: Binder<Bool>
    }

    struct Output {

        let todoItemTitle: Driver<String?>
    }

    func transform(input: Input) -> Output {

        Observable.just(todoItem)
            .map({ $0 != nil })
            .bind(to: input.doneTodoEnabled, input.deleteTodoEnabled)
            .disposed(by: disposeBag)

        let textChanged = input.textChanged
            .distinctUntilChanged()
            .flatMap({ (text) -> Observable<String> in

                guard let text = text else { return .empty() }
                return .just(text)
            })

        let create = textChanged
            .filter({ $0 != "" })
            .flatMapLatest({ [weak self] (text) -> Observable<TodoModel> in

                guard let strongSelf = self else { return .empty() }
                guard strongSelf.todoItem == nil else { return .empty() }

                strongSelf.todoItem = TodoModel()
                strongSelf.todoItem!.title = text

                return .just(strongSelf.todoItem!)
            })
            .share()

        create
            .bind(to: provider.rx.create)
            .disposed(by: disposeBag)

        create
            .map({ _ in true })
            .bind(to: input.doneTodoEnabled, input.deleteTodoEnabled)
            .disposed(by: disposeBag)

        textChanged
            .flatMapLatest({ [weak self] (text) -> Observable<TodoModel> in

                guard let strongSelf = self else { return .empty() }
                guard var todoItem = strongSelf.todoItem else { return .empty() }

                todoItem.title = text

                return .just(todoItem)
            })
            .bind(to: provider.rx.update)
            .disposed(by: disposeBag)

        input.doneTodoTapped
            .withLatestFrom(input.textChanged)
            .flatMapLatest({ [weak self] (text) -> Observable<TodoModel> in

                guard let strongSelf = self else { return .empty() }
                guard var todoItem = strongSelf.todoItem else { return .empty() }
                guard let text = text else { return .empty() }

                todoItem.done = !todoItem.done
                todoItem.title = text

                return .just(todoItem)
            })
            .bind(to: provider.rx.update)
            .disposed(by: disposeBag)

        input.deleteTodoTapped
            .flatMapLatest({ [weak self] () -> Observable<String> in

                guard let strongSelf = self else { return .empty() }
                guard let todoItem = strongSelf.todoItem else { return .empty() }

                return .just(todoItem.id)
            })
            .bind(to: provider.rx.delete)
            .disposed(by: disposeBag)

        return Output(todoItemTitle: .just(todoItem?.title))
    }
}
