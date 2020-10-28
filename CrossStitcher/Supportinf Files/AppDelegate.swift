//
//  AppDelegate.swift
//  Cross Stitcher
//
//  Created by zappycode on 6/13/18.
//  Copyright © 2018 Nick Walter. All rights reserved.
//

import UIKit
import CoreData
import CloudKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    // MARK: - Life cycle

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    // MARK: - Core Data stack

    lazy var applicationDocumentDirectory: NSURL = {
        // THe directory the application uses to store Core Data Store file
        // This code uses a directory named "ru.isoftdv.CrossStitcher" in the application's Support directory
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls.last! as NSURL
    }()


    lazy var ubiquityContainerURL: NSURL = {
        let url = FileManager.default.url( forUbiquityContainerIdentifier: nil )
        
        return url! as NSURL
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = Bundle.main.url(forResource: "CrossStitcher", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        var coordinator = NSPersistentStoreCoordinator( managedObjectModel: self.managedObjectModel )
        
        var urlForDatbase: URL
        
        do {
            var documentDirectory = try FileManager.default.url(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask, appropriateFor: nil, create: true)
            
            urlForDatbase = documentDirectory.appendingPathComponent("CrossStitcher.sqllite")
        } catch let error {
            NSLog("Error defining document directory for iCloud \(error), \(error.localizedDescription)")
            
            urlForDatbase = self.applicationDocumentDirectory.appendingPathComponent("CrossStitcher.sqllite")!
        }
        
        let storeOptions: [String : Any] = [
        NSMigratePersistentStoresAutomaticallyOption:NSNumber(booleanLiteral: true),
        NSInferMappingModelAutomaticallyOption:NSNumber(booleanLiteral: true)]
        
        
        do{
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: urlForDatbase, options: nil)
        } catch let error {
            //error будет содержать информацию об ошибку - объект, поддерживающий протокол Error(типа NSError)
            // обычно это enum, в котором есть асоциированные данные об ошибке
            NSLog("Error adding persistent store for coordinator \(error), \(error.localizedDescription)")
            
            abort()

            //throws error //здесь происходит передача ошибки выше по вызовам (только если этот метод описан ка throws)
        }
        
        return coordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        var moc = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.mainQueueConcurrencyType)
        moc.persistentStoreCoordinator = self.persistentStoreCoordinator
        return moc
    }()
    
    static var managedObjectContext: NSManagedObjectContext {
        return (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
    }


    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "CrossStitcher")
        
        if container.persistentStoreDescriptions.count > 0{
            container.persistentStoreDescriptions[0].shouldInferMappingModelAutomatically = true
            container.persistentStoreDescriptions[0].shouldAddStoreAsynchronously = true
            container.persistentStoreDescriptions[0].shouldMigrateStoreAutomatically = true
        }

        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    static var persistentContainer: NSPersistentContainer {
        return (UIApplication.shared.delegate as! AppDelegate).persistentContainer
    }

    static var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    // MARK: - Core Data Saving support

    func saveContext () throws {
        /*
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }*/
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                throw error
                //let nserror = error as NSError
                //fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
        
    }
    
    func showAlertMessage(_ messageText: String, withTitle title: String, inView vc:UIViewController ){
        let alert = UIAlertController(title: NSLocalizedString( title, comment: "" ),
                                      message: NSLocalizedString( messageText, comment: "" ),
                                      preferredStyle: .alert)
        
        alert.addAction(
            UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"),
                          style: .default,
                          handler: { _ in NSLog("The \"OK\" alert occured.") }
            )
        )
        vc.present(alert, animated: true, completion: nil)
    }
}

