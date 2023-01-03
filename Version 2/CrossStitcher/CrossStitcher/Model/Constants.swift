//
//  Constants.swift
//  CrossStitcher
//
//  Created by Valery Dubovoy on 26.10.2022.
//

import Foundation

struct Constants {
    static let indexMultyplicator = 10000
    
    static func indexOf(row: Int16, column: Int16) -> Int {
        //return Int( row ) * indexMultyplicator + Int( column )
        return Int(row)<<16 + Int(column)
    }
    
    static func indexOf(row: Int, column: Int) -> Int {
        //return Int( row ) * indexMultyplicator + Int( column )
        return row << 16 + column
    }
}

enum MarkerTypes: Int, CaseIterable {
    case type1 = 1
    case type2 = 2
}
