//
//  SchemaCollectionViewDelegateProtocol.swift
//  CrossStitcher
//
//  Created by Valery Dubovoy on 03.01.2023.
//

import Foundation
import UIKit

protocol SchemaCollectionViewDelegate {
    func configureCell(cell: ImageCollectionViewCell, for indexPath: IndexPath)
    
    func didSelectCell(at indexPath: IndexPath)
}
