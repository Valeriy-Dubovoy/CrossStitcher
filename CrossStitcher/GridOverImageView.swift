//
//  GridOverImageView.swift
//  CrossStitcher
//
//  Created by Valery Dubovoy on 04/05/2020.
//  Copyright © 2020 isoftdv.ru. All rights reserved.
//

import UIKit

class GridOverImageView: UIView {
    var zoomScale: CGFloat = 1 {
        didSet {
            //print("scale changed")
            //setNeedsDisplay()
            //setNeedsLayout()
        }
    }
    
    var contentOffset: CGPoint = CGPoint(x: 0, y: 0){
        didSet {
            //print("offset changed")
            //setNeedsDisplay()
            //setNeedsLayout()
        }
    }
    
    var image: UIImage?{
        didSet {
            frame = CGRect(x: 0, y: 0, width: zoomedSize.width, height: zoomedSize.height)
            setNeedsDisplay()
            setNeedsLayout()}
    }
    
    var originalSize: CGSize {
        if let img = image {
            return img.size //CGSize(width: img.size.width, height: img.size.height)
            
        } else {return CGSize()}
    }
    var zoomedSize: CGSize {
        return CGSize(width: originalSize.width * zoomScale, height: originalSize.height * zoomScale)
    }

    // MARK: grid properties
    var rows: Int = 0 {
        didSet{
            setNeedsDisplay()
        }
    }
    var columns: Int = 0 {
        didSet{
            setNeedsDisplay()
        }
    }
    
    var gridRect: CGRect = CGRect(x: 0, y: 0, width: 0, height: 0) {
        didSet{
            setNeedsDisplay()
        }
    }
    
    var lineColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
    let gridLineWidth: CGFloat = 2.0
    
    
    override func draw(_ rect: CGRect) {
        //print("I'm drawing ...")
        // вывести картинку
        if let img = image {
            img.draw(in: CGRect(x: 0, y: 0, width: originalSize.width, height: originalSize.height))
        }
        
        // наложить сетку (со смещением)
        if rows > 0, gridRect.height > 0 {
            for row in 0...rows {
                let path = UIBezierPath()

                let yCoord = yForRow(row: row)//: CGFloat = (gridRect.minY + gridRect.height / CGFloat(rows) * CGFloat(row)) * zoomScale
                path.move(to: convertToOriginCoordinates(forScreenPoint: CGPoint(x: gridRect.minX * zoomScale,
                                      y: yCoord)) )       // переместить перо в начальную точку
                path.addLine(to: convertToOriginCoordinates(forScreenPoint: CGPoint(x: gridRect.maxX * zoomScale,
                                         y: yCoord)) )   // нарисовать линию
                lineColor.setStroke()
                path.lineWidth = row % 10 == 0 ? gridLineWidth * 2.0 : gridLineWidth
                //path.fill()                            // отображаем
                path.stroke()
            }
        }
        
        if columns > 0, gridRect.width > 0 {
             for column in 0...columns {
                 let path = UIBezierPath()

                 let xForRow = xForColumn(column: column)
                 path.move(to: convertToOriginCoordinates(forScreenPoint: CGPoint(x: xForRow,
                                       y: gridRect.minY * zoomScale)) )       // переместить перо в начальную точку
                 path.addLine(to: convertToOriginCoordinates(forScreenPoint: CGPoint(x: xForRow,
                                          y: gridRect.maxY * zoomScale)) )   // нарисовать линию
                 path.lineWidth = column % 10 == 0 ? gridLineWidth * 2.0 : gridLineWidth
                 //path.fill()                            // отображаем
                 path.stroke()
             }
         }
    }
    
    func yForRow(row : Int) -> CGFloat {
        return (gridRect.minY + gridRect.height / CGFloat(rows) * CGFloat(row)) * zoomScale
    }
    
    func xForColumn(column: Int) -> CGFloat {
        return (gridRect.minX + gridRect.width / CGFloat(columns) * CGFloat(column)) * zoomScale
    }
    
    func convertToScreenCoordinates(forPoint point: CGPoint) -> CGPoint {
        let screenPoint = CGPoint(x: point.x * self.zoomScale, y: point.y * self.zoomScale)
        
        return screenPoint
    }
    
    func convertToOriginCoordinates(forScreenPoint point: CGPoint) -> CGPoint {
        switch zoomScale {
        case 0: return point
        case 1: return point
        default:
            return CGPoint(x: point.x / zoomScale, y: point.y / zoomScale)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentMode = .redraw
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        contentMode = .redraw
    }
    
}
