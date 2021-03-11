//
//  csListTableViewController.swift
//  CrossStitcher
//
//  Created by Valery Dubovoy on 24/06/2020.
//  Copyright © 2020 Nick Walter. All rights reserved.
//

import UIKit
import CoreData

class csListTableViewController: FetchedResultsTableViewController {
/*
    var container: NSPersistentContainer? = AppDelegate.persistentContainer
        //(UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
    {
        didSet { updateUI() }
    }
 */
    //override var fetchedResultController: NSFetchedResultsController<CrossStitch>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let request: NSFetchRequest<CrossStitch> = CrossStitch.fetchRequest()
        request.sortDescriptors = [
                                   NSSortDescriptor(
                                   key: "name",
                                   ascending: true,
                                   selector: #selector(NSString.localizedCaseInsensitiveCompare(_:))
                                   )
                                ]
        //request.predicate = NSPredicate(format: "any tweets.text contains[c] %@", mention!)
        let frc = NSFetchedResultsController<CrossStitch>(
            fetchRequest: request,
            managedObjectContext: AppDelegate.managedObjectContext,
            sectionNameKeyPath: nil,
            cacheName: nil
            ) as? NSFetchedResultsController<NSFetchRequestResult>
        
        frc?.delegate = self
        fetchedResultController = frc
        
        tableView.reloadData()
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "crossStitch cell", for: indexPath) as! CrossStitchListViewCell

        if let object = fetchedResultController?.object(at: indexPath) as? CrossStitch {
            cell.configureWith(name: object.name, imageData: object.imageData)
        }

        return cell
    }
    
    private func updateUI() {
        /*
        if let context = container?.viewContext {
            let request: NSFetchRequest<CrossStitch> = CrossStitch.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(
                                        key: "indexField",
                                        ascending: true,
                                        selector: #selector(NSString.localizedCaseInsensitiveCompare(_:))
                                        ),
                                       NSSortDescriptor(
                                       key: "name",
                                       ascending: true,
                                       selector: #selector(NSString.localizedCaseInsensitiveCompare(_:))
                                       )
                                    ]
            //request.predicate = NSPredicate(format: "any tweets.text contains[c] %@", mention!)
            fetchedResultController = NSFetchedResultsController<CrossStitch>(
                fetchRequest: request,
                managedObjectContext: context,
                sectionNameKeyPath: "indexField",
                cacheName: nil
                ) as? NSFetchedResultsController<NSFetchRequestResult>
            
            fetchedResultController?.delegate = self
            try? fetchedResultController?.performFetch()
            tableView.reloadData()
        }
        */
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    // MARK: - Navigation
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool{
        if identifier == "show stitcher" {
            if let cell = sender as? UITableViewCell,  let indexPath = self.tableView.indexPath(for: cell){
                
                let object = fetchedResultController?.object(at: indexPath) as! CrossStitch?
                if (object?.schemaData) == nil {
                    return false
                }
            }
        }
        return true
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        switch segue.identifier {
        //case "addItem":
            /*let navigationVC = segue.destination as? UINavigationController
            if let csEditorVC = navigationVC?.viewControllers[0] as? csEditorTableViewController {
                
                csEditorVC.edittingItem
            }*/
        case "editItem":
            if let cell = sender as? UITableViewCell,  let indexPath = self.tableView.indexPath(for: cell){
                
                let object = fetchedResultController?.object(at: indexPath)
                let navigationVC = segue.destination as? UINavigationController
                if let editorVC = navigationVC?.viewControllers[0] as? csEditorTableViewController {
                    editorVC.edittingItem = object as! CrossStitch?
                }
            }

        case "show stitcher":
            if let cell = sender as? UITableViewCell,  let indexPath = self.tableView.indexPath(for: cell){
                
                if let object = fetchedResultController?.object(at: indexPath) as? CrossStitch,
                    let editorVC = segue.destination as? crossStitchViewController {
                    
                    editorVC.csDBObject = object
                    editorVC.navigationItem.title = object.name
                }
            }
        default:
            break
        }
    }


}

extension csListTableViewController
{
    /*
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int
    {
        return fetchedResultController?.sections?.count ?? 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if let sections = fetchedResultController?.sections, sections.count > 0 {
            return sections[section].numberOfObjects
        } else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        if let sections = fetchedResultController?.sections, sections.count > 0 {
            return sections[section].name
        } else {
            return nil
        }
    }
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]?
    {
        fetchedResultController?.sectionIndexTitles
    }
    
    override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int
    {
        return fetchedResultController?.section(forSectionIndexTitle: title, at: index) ?? 0
    }

    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return false
    }
 */
}
