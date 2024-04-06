//
//  FetchedResultsTableViewController.swift
//  CrossStitcher
//
//  Created by Valery Dubovoy on 26/06/2020.
//  Copyright © 2020 Nick Walter. All rights reserved.
//

import UIKit
import CoreData

class FetchedResultsTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {

    var moc: NSManagedObjectContext!
   
    public var fetchedResultController: NSFetchedResultsController<NSFetchRequestResult>?{
        didSet{
            if self.fetchedResultController != nil {
                self.performFetch()
            } else {
                self.tableView.reloadData()
            }
            self.moc = self.fetchedResultController?.managedObjectContext
        }
    }
    
    private var oldTitle = ""
    
//MARK: - NSFetchedResultsControllerDelegate
    public func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
       
    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
           
        switch type {
        case .insert: tableView.insertSections([sectionIndex], with: .fade)
        case .delete: tableView.deleteSections([sectionIndex], with: .fade)
        default: break
        }
    }
       
    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {


        switch type {
        case .insert: tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete: tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update: tableView.reloadRows(at: [indexPath!], with: .fade)
        case .move:
           tableView.deleteRows(at: [indexPath!], with: .fade)
           tableView.insertRows(at: [newIndexPath!], with: .fade)
        default: break
        }
    }

    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }

//MARK: - Fetching

    func performFetch()
    {
        if let frc = fetchedResultController {
            do{
                try frc.performFetch()
            }
            catch let error
            {
                NSLog("Error reading for \(String(describing: frc.fetchRequest.entityName)) with error \n\(error.localizedDescription)")
    //                    [self showErrorMessageWithTitle:ERR_MESSAGE_READING_ERROR
    //                                       errorMessage:@""
    //                                              error:error];
            }
        }
        self.tableView.reloadData();
    }


    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        if let frc = fetchedResultController {
            return frc.sections!.count
        }
        return 1
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

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            //tableView.deleteRows(at: [indexPath], with: .fade)
            self.moc.delete(self.fetchedResultController?.object(at: indexPath) as! NSManagedObject) //deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
            
            // TODO
            //[self saveChangesWithErrorTitle:@"Error" errorMessage:ERR_MESSAGE_CANT_DELETE];

        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }


       /*
       // Override to support rearranging the table view.
       override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

       }
       */

       /*
       // Override to support conditional rearranging of the table view.
       override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
           // Return false if you do not want the item to be re-orderable.
           return true
       }
       */

       /*
       // MARK: - Navigation

       // In a storyboard-based application, you will often want to do a little preparation before navigation
       override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
           // Get the new view controller using segue.destination.
           // Pass the selected object to the new view controller.
       }
       */
    // MARK: - view ICloud support
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(persistantStoreDidChange), name: NSNotification.Name.NSPersistentStoreCoordinatorStoresDidChange, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(persistantStoreWillChange), name: NSNotification.Name.NSPersistentStoreCoordinatorStoresWillChange, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(recieveICloudChanges), name: NSNotification.Name.NSManagedObjectContextObjectsDidChange, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.NSPersistentStoreCoordinatorStoresDidChange, object: nil)

        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.NSPersistentStoreCoordinatorStoresWillChange, object: nil) // moc.persistentStoreCoordinator

        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextObjectsDidChange, object: nil) // moc.persistentStoreCoordinator
    }
    
    @objc func persistantStoreDidChange(notification: Notification){
        self.navigationItem.title = self.oldTitle
        // reanable UI and fetch data
        self.navigationItem.rightBarButtonItem?.isEnabled = true    // разблокируем кнопку добавления
        // reload data
        //self.tableView.reloadData()
        
    }
    
    @objc func persistantStoreWillChange( notification: Notification) {
        self.navigationItem.title = NSLocalizedString("iCloud in progress", comment: "iCloud in progress")

        // changes in progress, disable UI here
        self.navigationItem.rightBarButtonItem?.isEnabled = false    // подавляем кнопку добавления

        // и срочно записываем свои изменения в базу
        if (self.moc.hasChanges) {
            //self.moc performBlock:^{
                // we had to save changes
            
                // and drop any managed object references
                //self.moc.reset();
                //}
        }

        // save changes
    }
    
    @objc func recieveICloudChanges( notification: Notification) {
        moc.perform({
            self.moc.mergeChanges(fromContextDidSave: notification)
            // reload data
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        })
        
        /* образец как можно организовать ввод строк с помощью Alert
        let title = NSLocalizedString("New object", comment: "")
        let message = NSLocalizedString("Input object name", comment: "")
        let inputStringAlert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        inputStringAlert.addTextField(configurationHandler: nil)

        inputStringAlert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { (alertAction: UIAlertAction) in
            if let nameOfObject = inputStringAlert.textFields?.first?.text {
                // можкм использовать nameOfObject
            }
                NSLog("The \"OK\" alert occured.")
            }))
        inputStringAlert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Default cancel action"), style: .cancel, handler: nil))
        self.present(inputStringAlert, animated: true, completion: nil)
        */
    }
}
