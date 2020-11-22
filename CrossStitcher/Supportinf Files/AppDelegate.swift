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

    lazy var applicationDocumentDirectory: URL = {
        // THe directory the application uses to store Core Data Store file
        // This code uses a directory named "ru.isoftdv.CrossStitcher" in the application's Support directory
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls.first! as URL
    }()


    /*A URL pointing to the specified ubiquity container, or nil if the container could not be located or if iCloud storage is unavailable for the current user or device.

    You use this method to determine the location of your app’s ubiquity container directories and to configure your app’s initial iCloud access. The first time you call this method for a given ubiquity container, the system extends your app’s sandbox to include that container. In iOS, you must call this method at least once before trying to search for cloud-based files in the ubiquity container. If your app accesses multiple ubiquity containers, call this method once for each container. In macOS, you do not need to call this method if you use NSDocument-based objects, because the system then calls this method automatically.

    You can use the URL returned by this method to build paths to files and directories within your app’s ubiquity container. Each app that syncs documents to the cloud must have at least one associated ubiquity container in which to put those files. This container can be unique to the app or shared by multiple apps.

    Important

    Do not call this method from your app’s main thread. Because this method might take a nontrivial amount of time to set up iCloud and return the requested URL, you should always call it from a secondary thread. To determine if iCloud is available, especially at launch time, check the value of the ubiquityIdentityToken property instead.*/
    lazy var ubiquityContainerURL: URL? = {
        /*containerID
        The fully-qualified container identifier for an iCloud container directory. The string you specify must not contain wildcards and must be of the form <TEAMID>.<CONTAINER>, where <TEAMID> is your development team ID and <CONTAINER> is the bundle identifier of the container you want to access.

        The container identifiers for your app must be declared in the com.apple.developer.ubiquity-container-identifiers array of the .entitlements property list file in your Xcode project.

        If you specify nil for this parameter, this method returns the first container listed in the com.apple.developer.ubiquity-container-identifiers entitlement array */
        let url = FileManager.default.url( forUbiquityContainerIdentifier: nil )
        
        return url
    }()
  
    /*In iCloud Drive Documents, when iCloud is available, ubiquityIdentityToken property contains an opaque object representing the identity of the current user. If iCloud is unavailable or there is no logged-in user, the value of this property is nil. Accessing the value of this property is relatively fast, so you can check the value at launch time from your app’s main thread.

    You can use the token in this property, together with the NSUbiquityIdentityDidChange notification, to detect when the user logs in or out of iCloud and to detect changes to the active iCloud account. When the user logs in with a different iCloud account, the identity token changes, and the system posts the notification. If you stored or archived the previous token, compare that token to the newly obtained one using the isEqual(_:) method to determine if the users are the same or different.

    Accessing the token in this property doesn’t connect your app to its ubiquity containers. To establish access to a ubiquity container, call the url(forUbiquityContainerIdentifier:) method. In macOS, you can instead use an NSDocument object, which establishes access automatically.*/
    lazy var ubiquityIdentityToken: (NSCoding & NSCopying & NSObjectProtocol)? = {
        return FileManager.default.ubiquityIdentityToken
    }()
    
    /* Для CloudKit для проверки доступности iCloud необходимо использовать метод accountStatus(completionHandler:)
    Reports whether the current user’s iCloud account can be accessed. */

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
            
            urlForDatbase = self.applicationDocumentDirectory.appendingPathComponent("CrossStitcher.sqllite")
        }
        
        let storeOptions: [String : Any] = [
        NSMigratePersistentStoresAutomaticallyOption:NSNumber(booleanLiteral: true),
        NSInferMappingModelAutomaticallyOption:NSNumber(booleanLiteral: true)]
        
        
        do{
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType,
                                               configurationName: nil,
                                               at: urlForDatbase,
                                               options: [NSMigratePersistentStoresAutomaticallyOption:NSNumber(true), NSInferMappingModelAutomaticallyOption:NSNumber(true)])
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
            container.persistentStoreDescriptions.first?.shouldInferMappingModelAutomatically = true
            container.persistentStoreDescriptions.first?.shouldAddStoreAsynchronously = true
            container.persistentStoreDescriptions.first?.shouldMigrateStoreAutomatically = true
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

