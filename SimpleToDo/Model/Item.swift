//
//  Item.swift
//  SimpleToDo
//
//  Created by Alex Busol on 7/5/18.
//  Copyright © 2018 Alex Busol. All rights reserved.
//

import Foundation
import RealmSwift

class Item: Object {
    @objc dynamic var title : String = "" //need to add dynamic to use variables in realm
    @objc dynamic var isDone : Bool = false
}
