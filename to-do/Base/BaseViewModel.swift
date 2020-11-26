//
//  BaseViewModel.swift
//  to-do
//
//  Created by YAVUZ OZTURK on 24/11/2020.
//

import RxSwift

protocol ViewModelType {

    associatedtype Input
    associatedtype Output

    func transform(input: Input) -> Output
}

class BaseViewModel {

    let disposeBag = DisposeBag()
    let provider: RealmProvider

    init(provider: RealmProvider) {

        self.provider = provider
    }
}

