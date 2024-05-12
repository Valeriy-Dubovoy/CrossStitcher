//
//  ColorForDatabase.swift
//  CrossStitcher
//
//  Created by Valery Dubovoy on 08.03.2021.
//  Copyright © 2021 Nick Walter. All rights reserved.
//

import Foundation
import UIKit

struct ColorForDatabase: Encodable, Decodable {
    var red: CGFloat = 0.0
    var green: CGFloat = 0.0
    var blue: CGFloat = 0.0
    var alpha: CGFloat = 0.0
    
    var name: String? {
        let encoder = JSONEncoder()
        //encoder.outputFormatting = .prettyPrinted

        let data = try? encoder.encode(self)
        if data != nil {
            return String(data: data!, encoding: .utf8) ?? nil
        }
        return nil
    }
    
    init(color: UIColor) {
        color.getRed(UnsafeMutablePointer<CGFloat>(&self.red),
                     green: UnsafeMutablePointer<CGFloat>(&self.green),
                     blue: UnsafeMutablePointer<CGFloat>(&self.blue),
                     alpha: UnsafeMutablePointer<CGFloat>(&self.alpha))
    }
    
    init(fromCodableString: String) {
        let decoder = JSONDecoder()
        if let decodableString = fromCodableString.data(using: .utf8) {
            if let newStruct = try? decoder.decode(ColorForDatabase.self, from: decodableString) {
                self.red = newStruct.red
                self.green = newStruct.green
                self.blue = newStruct.blue
                self.alpha = newStruct.alpha
            }
        }

    }
    
    func color() -> UIColor {
        return UIColor(displayP3Red: self.red, green: self.green, blue: self.blue, alpha: self.alpha)
    }
}
