//
//  CS_DataModel.swift
//  CrossStitcher
//
//  Created by Valery Dubovoy on 22/10/2020.
//  Copyright © 2020 Nick Walter. All rights reserved.
//

import UIKit
import CoreData

class CS_DataModel: NSObject {

    var managedObjectContext: NSManagedObjectContext?
    var managedObjectModel: NSManagedObjectModel?

    var iCloudIsInUse = false


    //+ (MainDataSource *) sharedInstance;
    //- (void) initWithCompletionBlock:(CallBackHandler)callBackBlock;
    //- (BOOL) saveChangesWithErrorTitle: (NSString *) errorTitle errorMessage: (NSString *) errorMessage viewController: (UIViewController *) viewController;

    //- (BOOL) saveChanges: (NSError**) error;

    //- (void) showAlertWithTitle: (NSString *) title message: (NSString *) message defaultButtonTitle: (NSString *) defaultButtonTitle;

    // MARK: - Initalization

    /*+ (MainDataSource *)sharedInstance;
    {
        // structure used to test whether the block has completed or not
        static dispatch_once_t onceToken = 0;
        
        // initialize sharedObject as nil (first call only)
        __strong static id _sharedObject = nil;
        
        // executes a block object once and only ones for lifetime of an application
        dispatch_once( &onceToken, ^{
            _sharedObject = [[self alloc] init];
        });
        
        // retuns the same object each time
        return _sharedObject;
    }*/

    // MARK: - Methods
/*
    func шnitWithCompletionBlock(_ {()})
    {
        self.iCloudIsInUse = NO;
       
        NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
        
        
        self.managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        self.managedObjectContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy;
        
        [self.managedObjectContext setPersistentStoreCoordinator:coordinator];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            NSPersistentStoreCoordinator *psc = [[self managedObjectContext] persistentStoreCoordinator];
            
            // по умолчанию работаем в директории для документов
            NSURL *documentsDirectory = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
            
            NSURL *container = [self ubiquityContainerURL];
            
            //необходимо еще задать опции для PersistentStore в словаре (Dictinary)
            NSDictionary *storeOptions;
            
            if (container != nil) {
                // Continue with iCloud
                self.iCloudIsInUse = YES;

                // We'll store database into subfolder of container, that ends ".nosync"
                // So the Database won't pass to iCloud, just only transaction log
                /*NSURL *databaseDirectory = [container URLByAppendingPathComponent:@"database.nosync" isDirectory:YES];
                
                BOOL isDir;
                
                if ([[NSFileManager defaultManager] fileExistsAtPath:[databaseDirectory absoluteString]
                                                         isDirectory:&isDir] && isDir) {
                    
                    documentsDirectory = databaseDirectory;
                } else {
                    
                    BOOL success = [[NSFileManager defaultManager] createDirectoryAtURL:databaseDirectory withIntermediateDirectories:YES attributes:nil error:nil];
                    if (success) {
                        documentsDirectory = databaseDirectory;
                    } else {
                        [self showAlertWithTitle:@"Error" message:@"Can't create iCloud storage. Use local storage" defaultButtonTitle:@"OK"];
                        
                    }
                }*/
                storeOptions = @{
                                 NSPersistentStoreUbiquitousContentNameKey: @"bibliography",
                                 //NSPersistentStoreUbiquitousContentURLKey: container,  // - path to transaction log
                                 NSMigratePersistentStoresAutomaticallyOption:[NSNumber numberWithBool:YES],
                                 NSInferMappingModelAutomaticallyOption:[NSNumber numberWithBool:YES]
                                };
            } else {
                // iCloud is not available
                storeOptions = @{
                                 NSMigratePersistentStoresAutomaticallyOption:[NSNumber numberWithBool:YES],
                                 NSInferMappingModelAutomaticallyOption:[NSNumber numberWithBool:YES]
                                };
            };
            
            NSURL *storeURL = [documentsDirectory URLByAppendingPathComponent:@"CoreData.sqlite"];

            NSError *error = nil;
            NSPersistentStore *store = [psc addPersistentStoreWithType:NSSQLiteStoreType
                                                         configuration:nil
                                                                   URL:storeURL
                                                               options:storeOptions
                                                                 error:&error];
            if (!store) {
                NSString *fullMessage = [NSString stringWithFormat:@"%@:\n%@", NSLocalizedString(@"ERR_INIT_STORAGE", nil),  [error localizedDescription]];
                [self showAlertWithTitle:NSLocalizedString(@"ERR_DBOPEN", nil) message:fullMessage defaultButtonTitle:NSLocalizedString(@"OK", nil)];
                
                NSLog(@"Failed to initalize persistent store: %@\n%@", [error localizedDescription], [error userInfo]);
                abort();
                //A more user facing error message may be appropriate here rather than just a console log and an abort
            }
            if (!callBackBlock) {
                //If there is no callback block we can safely return
                return;
            }
            //The callback block is expected to complete the User Interface and therefore should be presented back on the main queue so that the user interface does not need to be concerned with which queue this call is coming from.
            dispatch_sync(dispatch_get_main_queue(), ^{
                callBackBlock();
            });
        });
        return;
    }*/
}
