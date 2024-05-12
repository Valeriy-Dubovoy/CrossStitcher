//
//  CrossStitch.swift
//  CrossStitcher
//
//  Created by Valery Dubovoy on 27/06/2020.
//  Copyright © 2020 Nick Walter. All rights reserved.
//

import Foundation
import CoreData
//import UIKit

public class CrossStitch: NSManagedObject {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CrossStitch> {
        return NSFetchRequest<CrossStitch>(entityName: "CrossStitch")
    }
    
    @NSManaged public var gridColor: String?
    @NSManaged public var gridColumns: Int16
    @NSManaged public var gridRectHeight: Float
    @NSManaged public var gridRectWidth: Float
    @NSManaged public var gridRectX: Float
    @NSManaged public var gridRectY: Float
    @NSManaged public var gridRows: Int16
    @NSManaged public var indexField: String?
    @NSManaged public var markedCells: String?
    @NSManaged public var marker1Color: String?
    @NSManaged public var marker2Color: String?
    @NSManaged public var name: String?
    @NSManaged public var images: ImageDatas?
    
    
    func getCrossStitchObject() -> CrossStitchObject {
        let cso = CrossStitchObject()
        cso.crossStitchDBObject = self
        return cso
    }
    
    func updateFromCrossStitchObject(_ crossStitchObject : CrossStitchObject) {
        gridRows = Int16(crossStitchObject.rows)
        gridColumns = Int16(crossStitchObject.columns)
        gridRectX = Float(crossStitchObject.gridRect.minX)
        gridRectY = Float(crossStitchObject.gridRect.minY)
        gridRectWidth = Float(crossStitchObject.gridRect.width)
        gridRectHeight = Float(crossStitchObject.gridRect.height)
        markedCells = crossStitchObject.markedCells
        marker1Color = ColorForDatabase(color: crossStitchObject.marker1Color).name
        marker2Color = ColorForDatabase(color: crossStitchObject.marker2Color).name
        gridColor = ColorForDatabase(color: crossStitchObject.gridColor).name
                
    }
}

