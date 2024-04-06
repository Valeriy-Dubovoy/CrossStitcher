//
//  StitchExtentions.swift
//  CrossStitcher
//
//  Created by Valery Dubovoy on 28.10.2022.
//

import Foundation
import CoreData

extension DBStitch {
    
    static public override func entity() -> NSEntityDescription {
        let description = NSEntityDescription.entity(forEntityName: entityName(), in: AppDelegate.viewContext)!
        
        return description
   }
    
    static func entityName() -> String {
        return "DBStitch"
    }
    
    static func entityDescription() -> NSEntityDescription {
        let description = NSEntityDescription.entity(forEntityName: entityName(), in: AppDelegate.viewContext)!
        
        return description
    }
    
    static func newObject() -> DBStitch {
        return NSEntityDescription.insertNewObject(forEntityName: entityName(), into: AppDelegate.viewContext) as! DBStitch
    }
}

extension DBMarkedItem {
    static func entityName() -> String {
        return "DBMarkedItem"
    }
    
    static func newObject() -> DBMarkedItem {
        return NSEntityDescription.insertNewObject(forEntityName: entityName(), into: AppDelegate.viewContext) as! DBMarkedItem
    }

}
