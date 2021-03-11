//
//  GridCell.swift
//  CrossStitcher
//
//  Created by Valery Dubovoy on 07.03.2021.
//  Copyright © 2021 Nick Walter. All rights reserved.
//

import Foundation

struct GridCell: Hashable, Decodable, Encodable {
    var row: Int
    var column: Int
    
    func asTuple() -> (Int, Int) {
        return (row, column)
    }
    
    func asInt() -> Int {
        return row * 10000 + column
    }
    
    init(row: Int, column: Int) {
        self.column = column
        self.row = row
    }
    
    init(_ fromInt: Int) {
        self.column = fromInt % 10000
        self.row = Int( ( fromInt - column ) / 10000 )
    }
    
    // MARK: Hashable
    static func == (lhs: GridCell, rhs: GridCell) -> Bool {
        return lhs.row == rhs.row && lhs.column == rhs.column
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(row)
        hasher.combine(column)
    }
}
