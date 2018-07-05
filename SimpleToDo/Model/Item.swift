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
    @objc dynamic var dateCreated : Date?
    
    var parentItem = LinkingObjects(fromType: Category.self, property: "items") //defines an inverse relationship from Core Data. links Item back to the Category class.
    
    
}
