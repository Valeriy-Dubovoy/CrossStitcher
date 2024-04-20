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
    
    // TODO: remove
    static func cellCoordinatesFrom(index: Int) -> CellCoordinate {
        return CellCoordinate(row: (index & 0xffff0000)>>16, column: index & 0xffff)
    }
    
   // MARK: User settings
    static func secondTapClearCell() -> Bool {
        return UserDefaults.standard.bool(forKey: UserSettingsKeys.secondTapClearCell.rawValue )
    }
    
    static func setSecondTapClearCell(with value: Bool) -> Void {
        UserDefaults.standard.set(value, forKey: UserSettingsKeys.secondTapClearCell.rawValue )
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
    
    // MARK: Help
    static func helpText( lang: String? ) -> String {
        if lang == "ru" {
            return """
<h1>Заголовок стиля 1</h1>
<p style="font-size: 1.5em;">Текст 1,5 размера <strong  style="color: #aaafff;">выделение цветом</strong> после выделения</p>
<p>The <strong>visual editor</strong> on the right and the <strong>source editor</strong> on the left are linked together and the changes are reflected in the other one as you type!</p>
<p>А дальше картинка</p>
<img="free-icon-embroidery-7076323">

"""
        }
        
        return """
<h2>Welcome To The Best Online HTML Web Editor!</h2>
<p style="font-size: 1.5em;">You can <strong style="background-color: #317399; padding: 0 5px; color: #fff;">type your text</strong> directly in the editor or paste it from a Word Doc, PDF, Excel etc.</p>
<p style="font-size: 1.5em;">The <strong>visual editor</strong> on the right and the <strong>source editor</strong> on the left are linked together and the changes are reflected in the other one as you type! <img="free-icon-embroidery-7076323"></p>
<table class="editorDemoTable">
<tbody>
<tr>
<td><strong>Name</strong></td>
<td><strong>City</strong></td>
<td><strong>Age</strong></td>
</tr>
<tr>
<td>John</td>
<td>Chicago</td>
<td>23</td>
</tr>
<tr>
<td>Lucy</td>
<td>Wisconsin</td>
<td>19</td>
</tr>
<tr>
<td>Amanda</td>
<td>Madison</td>
<td>22</td>
</tr>
</tbody>
</table>
<p>This is a table you can experiment with.</p>
"""
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
