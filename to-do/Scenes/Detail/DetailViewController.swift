//
//  DetailViewController.swift
//  to-do
//
//  Created by YAVUZ OZTURK on 25/11/2020.
//

import UIKit
import RxSwift
import RxCocoa

class DetailViewController: BaseViewController {

    var viewModel: DetailViewModel!

    @IBOutlet private weak var textView: UITextView!

    private let doneToDoBarButtonItem = UIBarButtonItem(systemItem: .done)
    private let deleteToDoBarButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: nil)

    override func viewDidLoad() {

        super.viewDidLoad()

        self.navigationItem.rightBarButtonItems = [deleteToDoBarButtonItem, doneToDoBarButtonItem]
    }

    override func viewDidAppear(_ animated: Bool) {

        super.viewDidAppear(animated)
        textView.becomeFirstResponder()
    }

    override func bindViewModel() {

        super.bindViewModel()

        let input = DetailViewModel.Input(textChanged: textView.rx.text.asObservable(),
                                          doneTodoTapped: doneToDoBarButtonItem.rx.tap,
                                          deleteTodoTapped: deleteToDoBarButtonItem.rx.tap,
                                          doneTodoEnabled: doneToDoBarButtonItem.rx.isEnabled,
                                          deleteTodoEnabled: deleteToDoBarButtonItem.rx.isEnabled)
        
        let output = viewModel.transform(input: input)

        doneToDoBarButtonItem.rx.tap.asDriver().drive(rx.pop).disposed(by: disposeBag)
        deleteToDoBarButtonItem.rx.tap.asDriver().drive(rx.pop).disposed(by: disposeBag)

        output.todoItemTitle.drive(textView.rx.text).disposed(by: disposeBag)
    }
}
