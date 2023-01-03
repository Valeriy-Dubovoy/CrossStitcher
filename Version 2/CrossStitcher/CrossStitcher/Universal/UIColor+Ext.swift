//
//  UIColor+Ext.swift
//  CrossStitcher
//
//  Created by Valery Dubovoy on 03.01.2023.
//

import Foundation
import UIKit

extension UIColor {
    static func colorFrom_ARGB_Int(_ rgbValue: Int64) -> UIColor! {
        return UIColor(
            red: CGFloat((Float((rgbValue & 0x00ff0000) >> 16)) / 255.0),
            green: CGFloat((Float((rgbValue & 0x0000ff00) >> 8)) / 255.0),
            blue: CGFloat((Float((rgbValue & 0x000000ff) >> 0)) / 255.0),
            alpha: CGFloat((Float((rgbValue & 0xff000000) >> 24)) / 255.0))
    }
    
    func getIntValue() -> Int64 {
        let components = UnsafeMutablePointer<CGFloat>.allocate(capacity: 4)
        
        components.assign(repeating: 0.0, count: 4)
//        let pRed = components
//        let pGreen = components + 1
//        let pBlue = components + 2
//        let pAlpha = components + 3

        self.getRed(components, green: components + 1, blue: components + 2, alpha: components + 3)
        
        let alpha = Int( components[3] * 255 )
        
        let red = Int( components[0] * 255 )
        let green = Int( components[1] * 255 )
        let blue = Int( components[2] * 255 )
        
        components.deallocate()
        
        
        return Int64( alpha << 24 ) + Int64( red << 16 + green << 8  + blue )

    }
}
