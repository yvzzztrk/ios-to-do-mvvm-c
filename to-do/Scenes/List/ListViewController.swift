//
//  ListViewController.swift
//  to-do
//
//  Created by YAVUZ OZTURK on 24/11/2020.
//

import UIKit
import RxSwift
import RxCocoa

class ListViewController: BaseViewController {

    var viewModel: ListViewModel!

    @IBOutlet private weak var tableView: UITableView!

    private let addToDoBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: nil)

    override func viewDidLoad() {

        super.viewDidLoad()

        self.navigationItem.rightBarButtonItem = addToDoBarButtonItem
    }

    override func bindViewModel() {

        super.bindViewModel()

        let input = ListViewModel.Input(viewWillAppear: rx.viewWillAppear,
                                        todoItemSelected: tableView.rx.modelSelected(TodoModel.self),
                                        addTodoTapped: addToDoBarButtonItem.rx.tap)
        let output = viewModel.transform(input: input)

        output.title
            .drive(rx.title)
            .disposed(by: disposeBag)

        output.todoItems
            .asDriver(onErrorJustReturn: [])
            .drive(tableView.rx.items) ({ (tableView, row, item) in

                let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell")!

                cell.configure(with: item)

                return cell
            })
            .disposed(by: disposeBag)

        output.navigateToDetail
            .map({ [weak self] (todoItem) -> Navigator.Segue in

                guard let strongSelf = self else { return Navigator.EmptySegue }
                let viewModel = DetailViewModel(provider: strongSelf.viewModel.provider, todoItem: todoItem)
                return (scene: .detail(viewModel: viewModel), sender: strongSelf, transition: .navigation)
            })
            .drive(rx.navigate)
            .disposed(by: disposeBag)

    }
}

extension UITableViewCell {

    func configure(with item: TodoModel) {

        textLabel?.text = item.title
        accessoryType = item.done ? .checkmark : .none

        textLabel?.numberOfLines = 0
    }
}

