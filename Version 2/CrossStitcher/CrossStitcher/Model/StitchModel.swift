//
//  StitchModel.swift
//  CrossStitcher
//
//  Created by Valery Dubovoy on 26.10.2022.
//

import Foundation
import CoreData
import UIKit

struct StitchModel {
    var stitch: Stitch? {
        didSet {
            if let stitch = stitch {
                name = stitch.name ?? ""
                schemaImage = stitch.schema == nil ? nil : UIImage(data: stitch.schema!)
                previewImage = stitch.preview == nil ? nil : UIImage(data: stitch.preview!)
                rows = stitch.rows
                columns = stitch.columns
                
                markers = [Int: Marker]()
                if let mSet = stitch.markers {
                    for marker in mSet.allObjects {
                        let row = (marker as! Marker).row
                        let column = (marker as! Marker).column
                        let index = Constants.indexOf( row: row, column: column )
                        markers[ index ] = (marker as! Marker)
                    }
                }
            }
        }
    }
    
    mutating func newStitch() {

        let newStitch = Stitch.newObject()
        
        newStitch.name = name
        newStitch.rows = rows
        newStitch.columns = columns
        newStitch.schema = schemaImage?.pngData()
        newStitch.preview = previewImage?.pngData()
        
        stitch = newStitch
    }
    
    mutating func set(name: String) {
        self.name = name
        if let db = stitch {
            db.name = name
        }
    }
    
    mutating func set(rows: Int16) {
        self.rows = rows
        if let db = stitch {
            db.rows = rows
        }
    }

    mutating func set(columns: Int16) {
        self.columns = columns
        if let db = stitch {
            db.columns = columns
        }
    }

    mutating func set(schemaImage: UIImage?) {
        self.schemaImage = schemaImage
        if let db = stitch {
            db.schema = schemaImage == nil ? nil : schemaImage?.pngData()
        }
    }
    
    mutating func set(previewImage: UIImage?) {
        self.previewImage = previewImage
        if let db = stitch {
            db.preview = previewImage == nil ? nil : previewImage?.pngData()
        }
    }
    
    mutating func toggleMarkerAt(row: Int, column: Int, with newMarker: Int) {
        let indexOfMarker = Constants.indexOf(row: row, column: column)
        if let oldMarker = markers[ indexOfMarker ] {
            if oldMarker.marker == newMarker {
                // remove marker
                markers.removeValue(forKey: indexOfMarker)
                AppDelegate.viewContext.delete( oldMarker )
            } else {
                // change marker
                oldMarker.marker = Int16( newMarker )
            }
        } else {
            // create marker
            let newMarkerDBObject = Marker.init(entity: Marker.entity(), insertInto: AppDelegate.viewContext)
            newMarkerDBObject.row = Int16( row )
            newMarkerDBObject.column = Int16( column )
            newMarkerDBObject.marker = Int16( newMarker )
            newMarkerDBObject.stitch = stitch
            
            markers[indexOfMarker] = newMarkerDBObject
        }
    }
    
    mutating func setMarker1Color(markerColor: UIColor) {
        self.markerColor1 = markerColor
        if let db = stitch {
            db.markerColor1 = markerColor.getIntValue()
        }
    }
    
    mutating func setMarker2Color(markerColor: UIColor) {
        self.markerColor2 = markerColor
        if let db = stitch {
            db.markerColor2 = markerColor.getIntValue()
        }
    }

    
    func getName() -> String {
        return name
    }
    func getRows() -> Int16 {
        return rows
    }
    func getColumns() -> Int16 {
        return columns
    }
    func getSchemaImage() -> UIImage? {
        return schemaImage
    }
    func getPreviewImage() -> UIImage? {
        return previewImage
    }
    
    func getMarker(for indexPath: IndexPath) -> Marker? {
        let indexOfMarker = getIndex(of: indexPath)
        
        return markers[ indexOfMarker ]

    }
    

    func getCellDescription(at indexPath: IndexPath) -> CellModel {
        let imageOfCell = getPartOfImage(row: indexPath.row, column: indexPath.section)
        if let marker = getMarker(for: indexPath) {
            return CellModel(image: imageOfCell, isMarked: marker.marker != 0, marker: marker.marker, markerColor: marker.marker == 1 ? markerColor1 : markerColor2)
        }
        
        return CellModel(image: imageOfCell, isMarked: false, marker: 0, markerColor: UIColor.init(white: 0, alpha: 0))
    }
    

    private func getIndex(of indexPath: IndexPath) -> Int {
        return Constants.indexOf(row: indexPath.row, column: indexPath.section)
    }
    
    private var name = ""
    private var schemaImage: UIImage?
    private var previewImage: UIImage?
    private var rows: Int16 = 1
    private var columns: Int16 = 1
    
    private var markers = [Int: Marker]()
    
    private var markerColor1 = #colorLiteral(red: 0.9686274529, green: 0.78039217, blue: 0.3450980484, alpha: 1)
    private var markerColor2 = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
    private var alfaMarker: CGFloat = 0.5

    
    // row and column 0 based
    private func getPartOfImage(row: Int, column: Int) -> UIImage? {
        if let image = schemaImage {
            let width = image.size.width / CGFloat( columns )
            let height = image.size.height / CGFloat( rows )
            
            let startPoint = CGPoint(x: width * CGFloat( column ), y: height * CGFloat( row ))
            if let subImage = image.cgImage?.cropping(to: CGRect(origin: startPoint, size: CGSize(width: width, height: height))) {
                return UIImage(cgImage: subImage)
            }
        }
        return nil
    }

}

// MARK: - Cell

struct CellModel {
    let image: UIImage?
    let isMarked: Bool
    let marker: Int16
    let markerColor: UIColor?
}
