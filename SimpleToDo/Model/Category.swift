//
//  Category.swift
//  SimpleToDo
//
//  Created by Alex Busol on 7/5/18.
//  Copyright © 2018 Alex Busol. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object { //need to subclass object to be able to save data using Realm
    @objc dynamic var categoryName : String = "" //dynamic var - monitors for changes during runtime
    @objc dynamic var categoryColor : String = ""
    let items = List<Item>() //defines the forward relationship from coreData. specifies that each category can have a
    //number of items

}
