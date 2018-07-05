//
//  SwipeTableViewController.swift
//  SimpleToDo
//
//  Created by Alex Busol on 7/5/18.
//  Copyright © 2018 Alex Busol. All rights reserved.
//  implementing a super class for the 2 view controllers

import UIKit
import SwipeCellKit

class SwipeTableViewController: UITableViewController, SwipeTableViewCellDelegate {
    var cell: UITableViewCell?
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 80
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SwipeTableViewCell //adding the SwipeCellKit functionality
        
        cell.delegate = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil } //checks if the orientation of the swipe is from the right
   
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            // handle action by updating model with deletion
            self.updateModel(at: indexPath)
            print("Deleted cell")

            
        }
        
      
        // customize the action appearance
        deleteAction.image = UIImage(named: "DeleteIcon") //puts the image in front of the typical red background of delete
        
        return [deleteAction]
        
    }
    
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.expansionStyle = .destructive
        return options
    }
    
    func updateModel(at indexPath: IndexPath) {
        //will be overriden in the subClasses
    }

}
