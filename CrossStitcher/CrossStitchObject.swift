//
//  crossStitchObject.swift
//  DrawNetAboveImage
//
//  Created by Valery Dubovoy on 24/04/2020.
//  Copyright © 2020 isoftdv.ru. All rights reserved.
//

import UIKit

class CrossStitchObject {
    var schemaImage: UIImage?
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
    
    init(withImage img: UIImage?) {
        schemaImage = img
        if let realImage = img {
            gridRect = CGRect(x: 0, y: 0, width: realImage.size.width, height: realImage.size.height)
        }
    }
}
