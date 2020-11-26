//
//  RealmProvider.swift
//  to-do
//
//  Created by YAVUZ OZTURK on 24/11/2020.
//

import Foundation
import RealmSwift
import RxSwift
import RxCocoa

class RealmProvider {

    private let realm: Realm

    init(test: Bool = false) {

        realm = test ? try! Realm(configuration: Realm.Configuration(inMemoryIdentifier: "to-doTests")) : try! Realm()
    }

    func list() -> Results<TodoObject> {

        let sortProperties = [SortDescriptor(keyPath: "done", ascending: true), SortDescriptor(keyPath: "lastEditDate", ascending: false)]

        return realm.objects(TodoObject.self).sorted(by: sortProperties)
    }

    func detail(id: String) -> TodoObject? {

        let predicate = NSPredicate(format: "id = %@", id)
        return realm.objects(TodoObject.self).filter(predicate).first
    }

    func create(model: TodoModel) {

        let object = TodoObject(id: model.id, title: model.title, done: model.done)
        try! realm.write({
            realm.add(object)
        })
    }

    func update(model: TodoModel) {

        try! realm.write {
            if let object = realm.objects(TodoObject.self).filter("id = %@", model.id).first {

                object.title = model.title
                object.done = model.done
                object.lastEditDate = Date()
            }
        }
    }

    func delete(id: String) {

        try! realm.write {
            if let object = realm.objects(TodoObject.self).filter("id = %@", id).first {

                realm.delete(object)
            }
        }
    }
}

// MARK: - Reactive Extensions

extension RealmProvider: ReactiveCompatible {}

extension Reactive where Base: RealmProvider {

    var list: Observable<[TodoModel]> {

        return Observable<[TodoModel]>.create({ [weak control = self.base] observer in

            guard let control = control else {
                observer.on(.completed)
                return Disposables.create()
            }

            let list: [TodoModel] = control.list().map({ $0.model() })

            observer.on(.next(list))
            observer.on(.completed)

            return Disposables.create()
        })
    }

    var create: Binder<TodoModel> {
        return Binder(self.base) { (provider, model) in
            provider.create(model: model)
        }
    }

    func detail(id: String) -> Observable<TodoModel?> {

        return Observable<TodoModel?>.create({ [weak control = self.base] observer in

            guard let control = control else {
                observer.on(.completed)
                return Disposables.create()
            }

            let model: TodoModel? = control.detail(id: id)?.model() ?? nil

            observer.on(.next(model))
            observer.on(.completed)

            return Disposables.create()
        })
    }

    var update: Binder<TodoModel> {
        return Binder(self.base) { (provider, model) in
            provider.update(model: model)
        }
    }

    var delete: Binder<String> {
        return Binder(self.base) { (provider, id) in
            provider.delete(id: id)
        }
    }
}
