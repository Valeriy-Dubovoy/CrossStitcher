//
//  CrossStitch.swift
//  CrossStitcher
//
//  Created by Valery Dubovoy on 27/06/2020.
//  Copyright © 2020 Nick Walter. All rights reserved.
//

import UIKit
import CoreData

class CrossStitch: NSManagedObject {

    func getCrossStitchObject() -> CrossStitchObject {
        let cso = CrossStitchObject()
        cso.crossStitchDBObject = self
        return cso
    }
    
    func updateFromCrossStitchObject(_ crossStitchObject : CrossStitchObject, inViewContorller vc: UIViewController) {
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

        // save changes
        do {
            try (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
        } catch {
            (UIApplication.shared.delegate as? AppDelegate)?.showAlertMessage("Saving error", withTitle: "Error", inView: vc)
        }

    }
}
