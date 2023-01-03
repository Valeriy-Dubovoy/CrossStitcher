//
//  StitchExtentions.swift
//  CrossStitcher
//
//  Created by Valery Dubovoy on 28.10.2022.
//

import Foundation
import CoreData

extension Stitch {
    
    static public override func entity() -> NSEntityDescription {
        let description = NSEntityDescription.entity(forEntityName: entityName(), in: AppDelegate.viewContext)!
        
        return description
   }
    
    static func entityName() -> String {
        return "Stitch"
    }
    
    static func entityDescription() -> NSEntityDescription {
        let description = NSEntityDescription.entity(forEntityName: entityName(), in: AppDelegate.viewContext)!
        
        return description
    }
    
    static func newObject() -> Stitch {
        return NSEntityDescription.insertNewObject(forEntityName: entityName(), into: AppDelegate.viewContext) as! Stitch
    }
}
