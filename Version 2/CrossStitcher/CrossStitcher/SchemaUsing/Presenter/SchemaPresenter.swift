//
//  SchemaPresenter.swift
//  CrossStitcher
//
//  Created by Valery Dubovoy on 04.02.2024.
//

import Foundation
import UIKit

protocol SchemaViewControllerProtocol: AnyObject {
    var presenter: SchemaViewControllerPresenterProtocol! {get set}
}

protocol SchemaViewControllerPresenterProtocol: AnyObject, StitchProtocol {
    //var stitchItem: StitchProtocol {get set}
    var currentTool: Tools {get set}
    
    
    init(view: SchemaViewControllerProtocol, dbStitch: DBStitch?)
    
    func saveProperties()
    func getCellDescriptionFor( cellCoord: CellCoordinate ) -> StitchItemDescriptionProtocol
    func setCurrentTool( newToolNumber: Int16 )
    func tapOnCellAt( cellCoord: CellCoordinate ) -> StitchItemDescriptionProtocol
    func getColorFor(markerType: MarkerTypes?) -> UIColor?
    func getAlfaFor(markerType: MarkerTypes?) -> CGFloat
    func replaceMarker1ToMarker2() -> [Int]
}

class StitchPresenter : SchemaViewControllerPresenterProtocol {
    // MARK: Stitch protocol
    internal var dbStitch: DBStitch?
    //var stitchItem: StitchProtocol

    var name: String
    var schemaImage: UIImage?
    var previewImage: UIImage?
    var rows: Int16
    var startRow: Int16
    var columns: Int16
    var startColumn: Int16
    var lastZoom: CGFloat
    var markers: [Int : DBMarkedItem]
    var markerColor1: UIColor
    var markerColor2: UIColor
    var alfaMarker1: CGFloat
    var alfaMarker2: CGFloat
    
    // MARK: submissive
    weak var view: SchemaViewControllerProtocol?
    
    // MARK: Presenter
    var currentTool: Tools
    
    required init(view: SchemaViewControllerProtocol, dbStitch: DBStitch?) {
        self.view   = view
        self.dbStitch = dbStitch
        
        self.currentTool = Tools.marker1
        
        if let dbStitch = dbStitch {
            self.name = dbStitch.name ?? ""
            self.schemaImage = dbStitch.schema == nil ? nil : UIImage(data: dbStitch.schema!)
            self.previewImage = dbStitch.preview == nil ? nil : UIImage(data: dbStitch.preview!)
            self.rows = dbStitch.rows
            self.startRow = dbStitch.startRow
            self.columns = dbStitch.columns
            self.startColumn = dbStitch.startColumn
            self.lastZoom = dbStitch.lastZoom == 0 ? 1.0 : CGFloat( dbStitch.lastZoom )
            self.markerColor1 = UIColor.colorFrom_ARGB_Int(dbStitch.markerColor1)
            self.markerColor2 = UIColor.colorFrom_ARGB_Int(dbStitch.markerColor2)
            self.alfaMarker1 = dbStitch.alfaMarker1 == 0 ? 0.5 : CGFloat( dbStitch.alfaMarker1 )
            self.alfaMarker2 = dbStitch.alfaMarker2 == 0 ? 0.5 : CGFloat( dbStitch.alfaMarker2 )
            
            markers = [Int: DBMarkedItem]()
            if let mSet = dbStitch.markers {
                for marker in mSet.allObjects {
                    let row = (marker as! DBMarkedItem).row
                    let column = (marker as! DBMarkedItem).column
                    let index = Constants.indexOf( row: row, column: column )
                    markers[ index ] = (marker as! DBMarkedItem)
                }
            }
        } else {
            self.name = NSLocalizedString("New stitch", comment: "")
            self.schemaImage = nil
            self.previewImage = nil
            self.rows = 1
            self.startRow = 1
            self.columns = 1
            self.startColumn = 1
            self.lastZoom = 1.0
            self.markerColor1 = Constants.marker1Color()
            self.markerColor2 = Constants.marker2Color()
            self.alfaMarker1 = 0.5
            self.alfaMarker2 = 0.5
            
            markers = [Int: DBMarkedItem]()
        }
    }
    
    func saveProperties() {
        if dbStitch == nil {
            dbStitch = DBStitch.newObject()
        }
        
        dbStitch?.name = self.name
        dbStitch?.rows = self.rows
        dbStitch?.startRow = self.startRow
        dbStitch?.columns = self.columns
        dbStitch?.startColumn = self.startColumn
        dbStitch?.alfaMarker1 = Float(self.alfaMarker1)
        dbStitch?.alfaMarker2 = Float(self.alfaMarker2)
        dbStitch?.markerColor1 = self.markerColor1.getIntValue()
        dbStitch?.markerColor2 = self.markerColor2.getIntValue()
        dbStitch?.schema = self.schemaImage?.pngData()
        dbStitch?.preview = self.previewImage?.pngData()
        dbStitch?.lastZoom = Float(self.lastZoom)
        
    }
    
    func getColorFor(markerType: MarkerTypes?) -> UIColor? {
        switch markerType {
            case .type1:
                return self.markerColor1
            case .type2:
                return self.markerColor2
            default:
                break
        }
        return nil
    }
    
    func getAlfaFor(markerType: MarkerTypes?) -> CGFloat {
        switch markerType {
            case .type1:
                return self.alfaMarker1
            case .type2:
                return self.alfaMarker2
            default:
                break
        }
        return 0.0
    }
    
   func getCellDescriptionFor( cellCoord: CellCoordinate )  -> StitchItemDescriptionProtocol {
        let image = getPartOfImage(row: cellCoord.row, column: cellCoord.column )
        let index = getIndex(of: cellCoord)
        let dmMarkerItem = markers[index]
        let marker = MarkerTypes(rawValue: dmMarkerItem?.marker ?? 0 )
        let color = getColorFor(markerType: marker)
        let alfa = getAlfaFor(markerType: marker)
        
        let cellDescription = CellDescription(row: Int16(cellCoord.row),
                                             column: Int16(cellCoord.column),
                                             image: image,
                                             marker: marker,
                                             markerColor:  color,
                                             markerAlfa: alfa)
        return cellDescription
    }
    
    func setCurrentTool( newToolNumber: Int16 ) {
        self.currentTool = Tools(rawValue: newToolNumber ) ?? .marker1
    }
    
    func tapOnCellAt( cellCoord: CellCoordinate ) -> StitchItemDescriptionProtocol {
//        let index = getIndex(of: indexPath)
//        let marker = markers[index]

        let cellDescription = getCellDescriptionFor(cellCoord: cellCoord)
        
        switch currentTool {
            case .marker1, .marker2:
                if let cellMarker = cellDescription.marker {
                    if cellMarker.rawValue == currentTool.rawValue {
                        // в зависимости от настроек очищать или нет
                        if Constants.secondTapClearCell() {
                            removeMarkerFor(index: cellDescription.index())
                        }
                    } else {
                        // для ячейки указан другой маркер. Установим текущий
                        setMarker(markerValue: currentTool.rawValue, forCell: cellDescription)
                        //markers[ cellDescription.index()] = MarkerTypes(rawValue: currentTool.rawValue )
                    }
                } else {
                    // для ячейки не указан маркер. Установим текущий
                    setMarker(markerValue: currentTool.rawValue, forCell: cellDescription)
                    //markers[ cellDescription.index()] = MarkerTypes(rawValue: currentTool.rawValue )
                }
            case .eraser:
                removeMarkerFor(index: cellDescription.index())
        }
        return cellDescription
   }
    
    private func removeMarkerFor( index: Int ) {
        guard let dbMarkerItem = markers[index] else {return}
        
        AppDelegate.viewContext.delete( dbMarkerItem )
        markers.removeValue(forKey: index)
    }
    
    private func setMarker(markerValue: Int16, forCell cell: StitchItemDescriptionProtocol) {
        let indexOfMarker = cell.index()
        
        if let dbMarkedItem = markers[ indexOfMarker ] {
            dbMarkedItem.marker = markerValue
        } else {
            // create marker
            let newMarkerDBObject = DBMarkedItem.init(entity: DBMarkedItem.entity(), insertInto: AppDelegate.viewContext)
            newMarkerDBObject.row = cell.row
            newMarkerDBObject.column = cell.column
            newMarkerDBObject.marker = markerValue
            newMarkerDBObject.stitch = dbStitch
            
            markers[indexOfMarker] = newMarkerDBObject
        }
    }
    
    func replaceMarker1ToMarker2() -> [Int] {
        var cellsForUpdate = [Int]()
        
        let marker1Items = markers.filter { item in
            item.value.marker == Tools.marker1.rawValue
        }
        
        for item in marker1Items {
            cellsForUpdate.append(item.key)
            item.value.marker   = Tools.marker2.rawValue
        }
        
        return cellsForUpdate
    }
    
    
    // MARK: private methods
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
    
    private func getIndex(of cellCoord: CellCoordinate) -> Int {
        return Constants.indexOf(row: cellCoord.row, column: cellCoord.column)
    }

}


struct CellDescription: StitchItemDescriptionProtocol {
    let row: Int16
    let column: Int16
    let image: UIImage?
    let marker: MarkerTypes?
    
    func isMarked() -> Bool {
        return marker != nil
    }
    func index() -> Int {
        return Constants.indexOf(row: row, column: column)
    }
    
    let markerColor: UIColor?
    let markerAlfa: CGFloat
}

struct CellCoordinate {
    let row: Int
    let column: Int
}
