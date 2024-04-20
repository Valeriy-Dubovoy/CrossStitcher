//
//  CellCoordinate.swift
//  CrossStitcher
//
//  Created by Valery Dubovoy on 20.04.2024.
//

import Foundation

struct CellCoordinate {
    let row: Int
    let column: Int
    
    init( index: Int) {
        
        //let cellCoord = Constants.cellCoordinatesFrom(index: index)
        self.row = (index & 0xffff0000)>>16 //cellCoord.row
        self.column = index & 0xffff //cellCoord.column
    }
    
    init( row: Int, column: Int) {
        self.row = row
        self.column = column
    }
    
    var indexOfCell: Int {
        return Constants.indexOf(row: row, column: column)
    }
    
}
