//
//  CategorySelectControllerTableViewController.swift
//  SimpleToDo
//
//  Created by Alex Busol on 7/5/18.
//  Copyright © 2018 Alex Busol. All rights reserved.
//

import UIKit
//import CoreData
import RealmSwift


class CategorySelectController: SwipeTableViewController { //adopt the required protocol

    
    let realm = try! Realm()
    var categoryArray : Results<Category>? //collection of results
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 80
        loadData() //load all the existing categories when the app loads

    }

    //MARK: - Add new categories
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let textAlert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            print("success adding category")
            
            //------------------ CREATING AND INITIALISING A NEW CATEGORY --------------------
            let tempCategory = Category()
            tempCategory.categoryName = textField.text!
            
            self.saveData(category: tempCategory)
        }
        
        textAlert.addAction(action)
        //the alert will have a text field that the user can fill
        textAlert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Add a new category"
            textField = alertTextField //will hold the text that user has entered
        }
        
        
        present(textAlert, animated: true, completion: nil)
        
    }
    
    //MARK: - TableView Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray?.count  ?? 1  //nil coalescing operator. 1 is returned is caregoryArray is nil.
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath) //taps into the function from the superclass
        
        //basically, the cell returned from the swipetableviewcontroller gets placed here.
        
        cell.textLabel?.text = categoryArray?[indexPath.row].categoryName ?? "No Categories Added Yet"
        
        return cell //now the cell will be rendered on screen
        
    }
    
    //MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) { //runs when a cell is clicked
        //tableView.deselectRow(at: indexPath, animated: true)
        
        //need to trigger the segue to take the user to the items in the category
        
        performSegue(withIdentifier: "goToItemView", sender: self) 
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationViewController = segue.destination as! TBviewController
        
        if let indexPath =  tableView.indexPathForSelectedRow {
            destinationViewController.selectedCategory = categoryArray?[indexPath.row]
        }
    }
    
    //MARK: - Data manipulation methods  (save data and load data)
    
    func saveData(category: Category) {
        do {
            try realm.write {
                realm.add(category)
            }
        } catch {
            print("Error saving Context in category\(error)")
        }
        
        tableView.reloadData() //refreshes the table view to include the new user-added category.
    }
    
    func loadData() {
        
        categoryArray = realm.objects(Category.self)
        
        tableView.reloadData()
    }
    
    override func updateModel(at indexPath: IndexPath) {
                    if let categoryToDelete = self.categoryArray?[indexPath.row]{
            
                            do {
                                try self.realm.write {
                                    self.realm.delete(categoryToDelete)
                                }
                            } catch {
                                print("error deleting an item")
                            }
            
                        }
    }
    
}



/* ----------------------------- OPTIONAL SEACH FUNCTIONALITY----. needs adjusting for REALM
    extension CategorySelectController: UISearchBarDelegate { //can extend the class's functionality this wayinstead of adding the delegate directly to the class
        
        
        func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            let request : NSFetchRequest<Category> = Category.fetchRequest()
            print(searchBar.text) //prints out the text that the user enters in the search bar.
            
            request.predicate  = NSPredicate(format: "categoryName CONTAINS[cd] %@", searchBar.text!) //the string means to look for items whose category names contain searchBar.text!
            //cd makes the search bar insensitive to case and diacrytics
            
            
            //SORT THE DATA WE GET BACK
            
            let sortDescriptor = NSSortDescriptor(key: "categoryName", ascending: true) //sort in alphabetical order
            request.sortDescriptors = [sortDescriptor] //expects an array of sort descriptors, so we are passing an array of one
            
            
            //fetch the search results
            do {
                categoryArray = try context.fetch(request)
            } catch {
                print("error fetching data from the search results \(error)")
            }
            tableView.reloadData()
            
        }
        
        //when the text changed and went down to 0
        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            if searchBar.text?.count == 0 {
                loadData()
                tableView.reloadData()
                
                DispatchQueue.main.async { //select the main thread of exectuion. forces the code inside to run in the foreground.
                    searchBar.resignFirstResponder() //deselects the search bar and dismisses the keyboard.
                }
                
            }
        }
}
*/
