//
//  StitchProtocols.swift
//  CrossStitcher
//
//  Created by Valery Dubovoy on 04.02.2024.
//

import Foundation
import UIKit

protocol StitchItemDescriptionProtocol {
    //var stitch: StitchProtocol {get}
    var row: Int16 {get}
    var column: Int16 {get}
    var image: UIImage? {get}
    var marker: MarkerTypes? {get}
    
    var markerColor: UIColor? {get}
    var markerAlfa: CGFloat {get}

    func isMarked() -> Bool
    func index() -> Int
}

protocol StitchProtocol {
    var name: String {get set}
    var schemaImage: UIImage? {get set}
    var previewImage: UIImage? {get set}
    var rows: Int16 {get set}
    var startRow: Int16 {get set}
    var columns: Int16 {get set}
    var startColumn: Int16 {get set}
    var lastZoom: CGFloat {get set}
    
    var markers: [Int: DBMarkedItem] {get set}
    
    var markerColor1: UIColor {get set}
    var markerColor2: UIColor {get set}
    var alfaMarker1: CGFloat {get set}
    var alfaMarker2: CGFloat {get set}

    var dbStitch: DBStitch? {get set}
}
