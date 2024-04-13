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
            blue: CGFloat((Float((rgbValue & 0x000000ff))) / 255.0),
            alpha: CGFloat((Float((rgbValue & 0xff000000) >> 24)) / 255.0))
    }
    
    func getIntValue() -> Int64 {
//        let components = UnsafeMutablePointer<CGFloat>.allocate(capacity: 4)
//
//        components.assign(repeating: 0.0, count: 4)
//
//        self.getRed(components, green: components + 1, blue: components + 2, alpha: components + 3)
        if let components = self.cgColor.components {
            
            let alpha = Int( components[3] * 255 )
            
            let red = Int( components[0] * 255 )
            let green = Int( components[1] * 255 )
            let blue = Int( components[2] * 255 )
            
            //components.deallocate()
            
            
            return Int64( alpha << 24 ) + Int64( red << 16 + green << 8  + blue )
        }
        
        return 0

    }
    
    var hexString:String? {
        if let components = self.cgColor.components {
            let r = components[0]
            let g = components[1]
            let b = components[2]
            return  String(format: "#%02x%02x%02x", (Int)(r * 255), (Int)(g * 255), (Int)(b * 255))
        }
        return nil
    }

}
