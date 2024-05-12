//
//  ImageDatas.swift
//  CrossStitcher
//
//  Created by Valery Dubovoy on 14.03.2021.
//  Copyright © 2021 Nick Walter. All rights reserved.
//

import Foundation
import CoreData


public class ImageDatas: NSManagedObject {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ImageDatas> {
        return NSFetchRequest<ImageDatas>(entityName: "ImageDatas")
    }

    @NSManaged public var previewData: Data?
    @NSManaged public var schemaData: Data?
    @NSManaged public var stitch: CrossStitch?

}
