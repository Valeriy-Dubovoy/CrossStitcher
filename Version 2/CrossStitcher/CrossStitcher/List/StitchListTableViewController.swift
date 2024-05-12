//
//  StitchListTableViewController.swift
//  CrossStitcher
//
//  Created by Valery Dubovoy on 26.10.2022.
//

import UIKit
import CoreData
import SwiftUI

class StitchListTableViewController: FetchedResultsTableViewController {
    
    //var presenter:

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let request: NSFetchRequest<DBStitch> = DBStitch.fetchRequest()
        request.sortDescriptors = [
                                   NSSortDescriptor(
                                   key: "name",
                                   ascending: true,
                                   selector: #selector(NSString.localizedCaseInsensitiveCompare(_:))
                                   )
                                ]
        //request.predicate = NSPredicate(format: "any tweets.text contains[c] %@", mention!)
        let frc = NSFetchedResultsController<DBStitch>(
            fetchRequest: request,
            managedObjectContext: AppDelegate.viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil
            ) as? NSFetchedResultsController<NSFetchRequestResult>
        
        frc?.delegate = self
        fetchedResultController = frc
        
        tableView.reloadData()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "stitchCell", for: indexPath) as! StitchTableViewCell
        
        if let object = fetchedResultController?.object(at: indexPath) as? DBStitch {
            cell.config(with: object)
        }

        return cell
    }



    // MARK: - Navigation

    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool{
        if identifier == "show stitcher" {
            if let cell = sender as? UITableViewCell,  let indexPath = self.tableView.indexPath(for: cell){
                
                let object = fetchedResultController?.object(at: indexPath) as? DBStitch
                if (object?.schema) == nil {
                    return false
                }
            }
        }
        return true
    }
    
    @IBSegueAction func showHelpSegue(_ coder: NSCoder) -> UIViewController? {
        let helpScreen = HelpScreenView()
        let hc = UIHostingController(coder: coder, rootView: helpScreen)
        
        //hc?.sizingOptions = .preferredContentSize
        return hc
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "addStitch":
                let dest = segue.destination as? UINavigationController
                if let vc = dest?.viewControllers[0] as? SchemaViewControllerProtocol {
                    let presenter = StitchPresenter(view: vc, dbStitch: nil, doAfterSave: nil)
                    vc.presenter = presenter
                }
        case "editStitch":
            if let cell = sender as? UITableViewCell,  let indexPath = self.tableView.indexPath(for: cell){
                
                let object = fetchedResultController?.object(at: indexPath) as? DBStitch
                let dest = segue.destination as? UINavigationController
                if let vc = dest?.viewControllers[0] as? SchemaViewControllerProtocol {
                    let presenter = StitchPresenter(view: vc, dbStitch: object, doAfterSave: nil)
                    vc.presenter = presenter
                }
            }
        case "show stitcher":
            if let cell = sender as? UITableViewCell,  let indexPath = self.tableView.indexPath(for: cell){
                
                let object = fetchedResultController?.object(at: indexPath) as? DBStitch
//                let dest = segue.destination as? UINavigationController
//                if let vc = dest?.viewControllers[0] as? SchemaViewController {
                if let vc = segue.destination as? SchemaViewController {
                    let presenter = StitchPresenter(view: vc, dbStitch: object, doAfterSave: nil)
                    vc.presenter = presenter
                }
            }
                
        case "showHelp":
                //let vc = segue.destination as? UIHostingController
                break

        default:
            break
        }
    }

}
