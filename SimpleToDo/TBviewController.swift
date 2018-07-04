//
//  ViewController.swift
//  SimpleToDo
//
//  Created by Alex Busol on 7/4/18.
//  Copyright © 2018 Alex Busol. All rights reserved.
//

import UIKit

class TBviewController: UITableViewController { //change the subclass to uitableViewController to link it to the table viewC in the mainStoryboard.

    let itemArray = ["Find Mike", "Buy Eggos", "Use superpowers"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    //MARK - Create TableView Data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count //will create as many cells in the table view as there are cells in the itemArray
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        
        cell.textLabel?.text = itemArray[indexPath.row]
        
        return cell
    }
    
    //MARK - Create table view delegate methods. ADD CHECKMARKS ON CLICKED ITEMS. ANIMATE THE SELECTED ROW
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(itemArray[indexPath.row])
        if (tableView.cellForRow(at: indexPath)?.accessoryType == .checkmark) { //points to a cell that is currently selected.
            tableView.cellForRow(at: indexPath)?.accessoryType = .none //removes the checkmark if the cell already has one.
        } else {
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark //adds a checkmark to the cell that was clicked
        }
        tableView.deselectRow(at: indexPath, animated: true) //makes the cells flash gray and then go back to white after being clicked.
        
        
        //at this point, we already have a very simple toDo app.
    }
    
    
}

