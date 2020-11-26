//
//  TodoModel.swift
//  to-do
//
//  Created by YAVUZ OZTURK on 26/11/2020.
//

import Foundation

struct TodoModel {

    let id: String
    var title: String
    var done: Bool

    init(todoObject: TodoObject) {

        self.id = todoObject.id
        self.title = todoObject.title
        self.done = todoObject.done
    }

    init(title: String = "", done: Bool = false) {

        self.id = UUID().uuidString
        self.title = title
        self.done = done
    }
}
