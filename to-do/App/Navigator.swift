//
//  Navigator.swift
//  to-do
//
//  Created by YAVUZ OZTURK on 24/11/2020.
//

import UIKit

protocol Navigatable {
    var navigator: Navigator! { get set }
}

class Navigator {

    typealias Segue = (scene: Scene, sender: UIViewController?, transition: Transition)

    static let `default` = Navigator()

    enum Scene {

        case none
        case list(viewModel: ListViewModel)
        case detail(viewModel: DetailViewModel)
    }

    enum Transition {

        case root(in: UIWindow)
        case navigation
    }

    static let EmptySegue: Segue = (scene: .none, sender: nil, transition: .navigation)

    // MARK: -

    func pop(sender: UIViewController?) {
        sender?.navigationController?.popViewController(animated: true)
    }

    func present(segue: Segue) {
        present(scene: segue.scene, sender: segue.sender, transition: segue.transition)
    }

    // MARK: -

    private func get(scene: Scene) -> UIViewController? {

        switch scene {
        case .none:

            return nil

        case .list(let viewModel):

            let vc = ListViewController.instantiate()
            vc.viewModel = viewModel
            return vc

        case .detail(let viewModel):

            let vc = DetailViewController.instantiate()
            vc.viewModel = viewModel
            return vc
        }
    }

    private func present(scene: Scene, sender: UIViewController?, transition: Transition = .navigation) {

        if let target = get(scene: scene) {
            present(target: target, sender: sender, transition: transition)
        }
    }

    private func present(target: UIViewController, sender: UIViewController?, transition: Transition) {

        injectNavigator(in: target)

        switch transition {
        case .root(let window):

            window.rootViewController = UINavigationController(rootViewController: target)
            window.makeKeyAndVisible()

            return
        default: break
        }

        guard let sender = sender else {
            fatalError("You need to pass in a sender for .navigation")
        }

        switch transition {
        case .navigation:

            if let nav = sender.navigationController {

                nav.pushViewController(target, animated: true)
            }
        default: break
        }
    }

    private func injectNavigator(in target: UIViewController) {
        // view controller
        if var target = target as? Navigatable {
            target.navigator = self
            return
        }

        // navigation controller
        if let target = target as? UINavigationController, let root = target.viewControllers.first {
            injectNavigator(in: root)
        }
    }
}
