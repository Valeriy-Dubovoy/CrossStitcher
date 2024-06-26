//
//  UIImageExtension.swift
//  GoKaliningrad
//
//  Created by Valery Dubovoy on 18.12.2021.
//

import UIKit


extension UIImage {
    func resized(withPercentage percentage: CGFloat) -> UIImage? {
        let canvasSize = CGSize(width: size.width * percentage, height: size.height * percentage)
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: canvasSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    func resized(toWidth width: CGFloat) -> UIImage? {
        let canvasSize = CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: canvasSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    func resized(toMaxMesure maxMesure: CGFloat) -> UIImage? {
        if size.width <= maxMesure && size.height <= maxMesure {
            return self
        }
        if size.width > size.height {
            //width = maxMesure
            return resized(withPercentage: maxMesure/size.width)
        } else {
            // height = maxMesure
            return resized(withPercentage: maxMesure/size.height)
        }
    }
}
