//
//  Constants.swift
//  CrossStitcher
//
//  Created by Valery Dubovoy on 26.10.2022.
//

import Foundation
import UIKit

struct Constants {
    
    static func indexOf(row: Int16, column: Int16) -> Int {
        return Int(row)<<16 + Int(column)
    }
    
    static func indexOf(row: Int, column: Int) -> Int {
        return row << 16 + column
    }
    
    static func cellCoordinatesFrom(index: Int) -> CellCoordinate {
        return CellCoordinate(row: (index & 0xffff0000)>>16, column: index & 0xffff)
    }
    
   // MARK: User settings
    static func secondTapClearCell() -> Bool {
        return UserDefaults.standard.bool(forKey: UserSettingsKeys.secondTapClearCell.rawValue )
    }
    
    enum UserSettingsKeys: String {
        case secondTapClearCell = "secondTapClearCell"
    }
    
    static func marker1Color() -> UIColor {
        return  #colorLiteral(red: 0.9686274529, green: 0.78039217, blue: 0.3450980484, alpha: 1)
    }
    
    static func marker2Color() -> UIColor {
        return  #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
    }
    
}

enum MarkerTypes: Int16, CaseIterable {
    case type1 = 1
    case type2 = 2
}

enum Tools: Int16, CaseIterable {
    case marker1 = 1
    case marker2 = 2
    case eraser = 3
}
