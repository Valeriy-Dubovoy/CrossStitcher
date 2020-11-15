//
//  crossStitchObject.swift
//  DrawNetAboveImage
//
//  Created by Valery Dubovoy on 24/04/2020.
//  Copyright © 2020 isoftdv.ru. All rights reserved.
//

import UIKit

class CrossStitchObject {
    var crossStitchDBObject: CrossStitch? {
        didSet{
            if let crossStitch = crossStitchDBObject {
                if let dataForImg = crossStitch.schemaData {
                    schemaImage = UIImage(data: dataForImg )
                }
                rows = Int(crossStitch.gridRows)
                columns = Int(crossStitch.gridColumns)
                gridRect = CGRect(x: CGFloat(crossStitch.gridRectX),
                                  y: CGFloat(crossStitch.gridRectY),
                                  width: CGFloat(crossStitch.gridRectWidth), height: CGFloat(crossStitch.gridRectHeight))
            }
        }
    }
    
    var schemaImage: UIImage? {
        didSet {
            if let realImage = schemaImage {
                gridRect = CGRect(x: 0, y: 0, width: realImage.size.width, height: realImage.size.height)
            }
        }
    }
    var imageSize: CGSize {
        if let img = schemaImage {
            return img.size
        }
        return CGSize(width: 0, height: 0)
    }
    
    // MARK: grid properties
    var rows: Int = 0
    var columns: Int = 0
    var gridRect: CGRect = CGRect(x: 0, y: 0, width: 0, height: 0)

    /*
    init(withImage img: UIImage?) {
        schemaImage = img
        if let realImage = img {
            gridRect = CGRect(x: 0, y: 0, width: realImage.size.width, height: realImage.size.height)
        }
        self.crossStitchDBObject = nil
    }
    
    init(withCrossStitchDBobject crossStitch:CrossStitch) {
        self.crossStitchDBObject = crossStitch
    }*/
}
