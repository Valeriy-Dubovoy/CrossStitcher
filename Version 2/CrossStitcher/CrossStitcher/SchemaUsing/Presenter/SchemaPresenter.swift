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
    
    func updateUndoButtonStatus()
}

protocol SchemaViewControllerPresenterProtocol: AnyObject, StitchProtocol {
    //var stitchItem: StitchProtocol {get set}
    var currentTool: Tools {get set}
    var history: History {get}
    
    init(view: SchemaViewControllerProtocol, dbStitch: DBStitch?)
    
    func saveProperties()
    func getCellDescriptionFor( cellCoord: CellCoordinate ) -> StitchItemDescriptionProtocol
    func setCurrentTool( newToolNumber: Int16 )
    func tapOnCellAt( cellCoord: CellCoordinate ) -> StitchItemDescriptionProtocol
    func getColorFor(markerType: MarkerTypes?) -> UIColor?
    func getAlfaFor(markerType: MarkerTypes?) -> CGFloat
    func replaceMarker1ToMarker2() -> [Int]
    func undoAction() -> [Int]
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
       let index = cellCoord.indexOfCell
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
    
    func getCellDescriptionFor( index: Int )  -> StitchItemDescriptionProtocol {
        let cellCoord = CellCoordinate(index: index)
        
        return getCellDescriptionFor(cellCoord: cellCoord)
    }
    
    func setCurrentTool( newToolNumber: Int16 ) {
        self.currentTool = Tools(rawValue: newToolNumber ) ?? .marker1
    }
    
    func tapOnCellAt( cellCoord: CellCoordinate ) -> StitchItemDescriptionProtocol {

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
        removeMarkerFor(index: index, withoutHistory: false)
    }
    
    private func removeMarkerFor( index: Int, withoutHistory: Bool ) {
        guard let dbMarkerItem = markers[index] else {return}

        if !withoutHistory {
            let historyStep = HistoryItem(id: index, oldTool: dbMarkerItem.marker, newTool: nil)
            history.addStep(action: historyStep)
            view?.updateUndoButtonStatus()
        }

        AppDelegate.viewContext.delete( dbMarkerItem )
        markers.removeValue(forKey: index)
        
    }
    
    private func setMarker(markerValue: Int16, forCell cell: StitchItemDescriptionProtocol) {
        setMarker(markerValue: markerValue, forCell: cell, withoutHistory: false)
    }
    
    private func setMarker(markerValue: Int16, forCell cell: StitchItemDescriptionProtocol, withoutHistory: Bool) {
        let indexOfMarker = cell.index()
        
        if !withoutHistory {
            let historyStep = HistoryItem(id: indexOfMarker, oldTool: cell.marker?.rawValue, newTool: markerValue)
            history.addStep(action: historyStep)
            view?.updateUndoButtonStatus()
        }

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
        
        var historySteps = [HistoryItem]()
        
        for item in marker1Items {
            cellsForUpdate.append(item.key)
            item.value.marker   = Tools.marker2.rawValue
            
            historySteps.append( HistoryItem(id: item.key, oldTool: Tools.marker1.rawValue, newTool: Tools.marker2.rawValue))
        }
        
        history.steps.append(historySteps)
        view?.updateUndoButtonStatus()
        
        return cellsForUpdate
    }
    
    
    // MARK: History
    var history = History()
    // mae undo, return cells for update
    func undoAction() -> [Int] {
        var cellsForUpdate = [Int]()
        
        guard let stepActions = history.steps.last else {return cellsForUpdate}
        
        //let stepActions = history.steps.last
        for action in stepActions {
            cellsForUpdate.append(action.id)
            
            if action.oldTool == nil {
                removeMarkerFor(index: action.id, withoutHistory: true)
            } else {
                setMarker(markerValue: action.oldTool!, forCell: getCellDescriptionFor(index: action.id), withoutHistory: true)
            }
            
        }
        
        // remove step
        history.steps.removeLast()
        view?.updateUndoButtonStatus()
        
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
    
}




