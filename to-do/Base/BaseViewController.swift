//
//  BaseViewController.swift
//  to-do
//
//  Created by YAVUZ OZTURK on 24/11/2020.
//

import UIKit
import RxSwift
import RxCocoa

class BaseViewController: UIViewController, Navigatable, StoryboardInstantiatable {

    let disposeBag = DisposeBag()

    var navigator: Navigator!

    override func viewDidLoad() {

        super.viewDidLoad()

        bindViewModel()
    }

    func bindViewModel() {

    }
}

protocol StoryboardInstantiatable {}

extension StoryboardInstantiatable where Self: BaseViewController {

    static func instantiate() -> Self {

        let storyboardName = "Main"
        let storyboardId = String(describing: self)

        let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
        guard let viewController = storyboard.instantiateViewController(withIdentifier: storyboardId) as? Self else {
            fatalError(storyboardId + " cannot be instantiated via storyboard")
        }

        return viewController
    }
}

extension Reactive where Base: BaseViewController {

    var viewWillAppear: Observable<Void> {
        return methodInvoked(#selector(BaseViewController.viewWillAppear)).map({ _ in })
    }

    var navigate: Binder<Navigator.Segue> {
        return Binder(self.base) { (baseVC, segue) in
            baseVC.navigator.present(segue: segue)
        }
    }

    var pop: Binder<Void> {
        return Binder(self.base) { (baseVC, _) in
            baseVC.navigator.pop(sender: baseVC)
        }
    }
}
