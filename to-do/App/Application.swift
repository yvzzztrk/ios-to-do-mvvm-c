//
//  Application.swift
//  to-do
//
//  Created by YAVUZ OZTURK on 24/11/2020.
//

import Foundation
import UIKit

class Application: NSObject {

    static let shared: Application = .init()

    let navigator: Navigator = .default
    let provider: RealmProvider = RealmProvider()

    private override init() {

        super.init()
    }

    func start(in window: UIWindow?) {

        guard let window = window else { return }

        let viewModel = ListViewModel(provider: provider)
        let segue: Navigator.Segue = (scene: .list(viewModel: viewModel),
                                      sender: nil,
                                      transition: .root(in: window))
        navigator.present(segue: segue)
    }
}
