//
//  ViewController.swift
//  SimpleToDo
//
//  Created by Alex Busol on 7/4/18.
//  Copyright © 2018 Alex Busol. All rights reserved.
//

import UIKit

class TBviewController: UITableViewController { //change the subclass to uitableViewController to link it to the table viewC in the mainStoryboard.

    var itemArray = [ItemClass]() //array of objects of ItemClass
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist") //creates our own plist at the app's location.
    
    //let defaults = UserDefaults.standard - cant user with custom datatypes
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       
        
        let newItem = ItemClass()
        newItem.title = "Find Mike"
        itemArray.append(newItem)
        
        let newItem2 = ItemClass()
        newItem2.title = "Find Mike"
        itemArray.append(newItem2)
        
        let newItem3 = ItemClass()
        newItem3.title = "Find Mike"
        itemArray.append(newItem3)
        
        //USER DEFAULTS rejects custom data types.
        //need to think of anyther way of storing data on the device.
        
        
//        if let items = defaults.array(forKey: "ToDoListArray") as? [ItemClass] { //make sure that the storage instance exists
//            itemArray = items //when the app is done loading, we retrieve the information from the previous session
//        }
        // Do any additional setup after loading the view, typically from a nib.
        
        loadData()
    }

    //MARK - Create TableView Data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int ) -> Int {
        return itemArray.count //will create as many cells in the table view as there are cells in the itemArray
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        
        let tempItem = itemArray[indexPath.row]
        
        cell.textLabel?.text = tempItem.title
        
        if tempItem.isDone == true {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
       
        return cell
    }
    
    //MARK - Create table view delegate methods. ADD CHECKMARKS ON CLICKED ITEMS. ANIMATE THE SELECTED ROW
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(itemArray[indexPath.row])
        
        itemArray[indexPath.row].isDone = !itemArray[indexPath.row].isDone //toggles between true and false every time the table cell is pressed
        saveData()
        
        //-------------NO LONGER USED BECAUSE WE ARE USING CUSTOM DATATYPE NOW-----------------
        /*
        if (tableView.cellForRow(at: indexPath)?.accessoryType == .checkmark) { //points to a cell that is currently selected.
            tableView.cellForRow(at: indexPath)?.accessoryType = .none //removes the checkmark if the cell already has one.
        } else {
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark //adds a checkmark to the cell that was clicked
        }
        
        */
        tableView.deselectRow(at: indexPath, animated: true) //makes the cells flash gray and then go back to white after being clicked.
        //at this point, we already have a very simple toDo app.
    }
    
    //MARK - create add new items functionality
    //created IBaction from main.storyboard.
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        //want to show a popup with a text field where the user can write
        //his reminder text
        var textField = UITextField()
        let textAlert = UIAlertController(title: "Add a new toDo item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            print("success")
            
            let tempItem = ItemClass()
            tempItem.title = textField.text!
            self.itemArray.append(tempItem) //text property of the text field is never going to be nil.
            
//            self.defaults.set(self.itemArray, forKey: "ToDoListArray") //saves the item in the persistance storage (UserDefaults) --no longer works with custom datatypess
            
            self.saveData()
        }
        
    
        //the alert will have a text field that the user can fill
        textAlert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField //will hold the text that user has entered
        }
            
            textAlert.addAction(action)
            present(textAlert, animated:true, completion: nil)
            
        }
   
    func saveData() {
        let encoder = PropertyListEncoder()
        do {
            let data = try encoder.encode(itemArray)
            try data.write(to: dataFilePath! )
        } catch {
            print("Error encoding item Array")
        }
        
        tableView.reloadData() //refreshes the table view to include the new user-added item.
    }
    
    func loadData() {
        do {
            if let data = try? Data(contentsOf: dataFilePath!) {
            let decoder = PropertyListDecoder()
            try itemArray = decoder.decode([ItemClass].self, from: data)
            }
        } catch {
            print("error decoding data")

        }
    }
}



