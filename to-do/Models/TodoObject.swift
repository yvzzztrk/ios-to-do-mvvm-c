//
//  TodoObject.swift
//  to-do
//
//  Created by YAVUZ OZTURK on 25/11/2020.
//

import Foundation
import RealmSwift

class TodoObject: Object {

    @objc dynamic var id: String = ""
    @objc dynamic var title: String = ""
    @objc dynamic var done: Bool = false
    @objc dynamic var lastEditDate: Date = Date()

    convenience init(id: String, title: String, done: Bool = false, lastEditDate: Date = Date()) {

        self.init()

        self.id = id
        self.title = title
        self.done = done
        self.lastEditDate = lastEditDate
    }

    override class func primaryKey() -> String? {
        return "id"
    }

    func model() -> TodoModel {
        return TodoModel(todoObject: self)
    }
}
