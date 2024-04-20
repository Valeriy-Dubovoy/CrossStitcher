//
//  CellDescription.swift
//  CrossStitcher
//
//  Created by Valery Dubovoy on 20.04.2024.
//

import Foundation
import UIKit

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
