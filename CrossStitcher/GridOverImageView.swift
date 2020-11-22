//
//  GridOverImageView.swift
//  CrossStitcher
//
//  Created by Valery Dubovoy on 04/05/2020.
//  Copyright © 2020 isoftdv.ru. All rights reserved.
//

import UIKit
import Foundation

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
    
    var markedCells: [Int: Int] = [:]{
        didSet{
            setNeedsDisplay()
        }
    }
    

    
    var lineColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
    let gridLineWidth: CGFloat = 2.0
    
    var marker1Color = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
    var marker2Color = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)

    
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

                let yCoord = yForRow(row: row)
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
        
        // разукрасить раскрашенные ячейки
        let cellSize = CGSize(width: gridRect.width / CGFloat(columns), height: gridRect.height / CGFloat(rows))
        
        for keyAndValue in markedCells {
            let column = keyAndValue.key % 10000
            let row = Int( ( keyAndValue.key - column ) / 10000 )
            
            // xForColumn и yForRow дают правую и нижнюю границу, значит уменьгим номера при получении координат
            let startPoint = convertToOriginCoordinates(forScreenPoint: CGPoint(x: xForColumn(column: column - 1), y: yForRow(row: row - 1)))
            
            let path = UIBezierPath()
            path.move(to: startPoint)
            path.addLine(to: CGPoint(x: startPoint.x + cellSize.width, y: startPoint.y))
            path.addLine(to: CGPoint(x: startPoint.x + cellSize.width, y: startPoint.y + cellSize.height))
            path.addLine(to: CGPoint(x: startPoint.x, y: startPoint.y + cellSize.height))
            path.close()
            
            let colorForCell = keyAndValue.value == 1 ? marker1Color : marker2Color
            colorForCell.setFill()
            
            path.fill(with: CGBlendMode.normal, alpha: 0.5)
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
    
    func cellForPoint(point: CGPoint) -> (row: Int, column: Int) {
        //let screenPoint = convertToScreenCoordinates(forPoint: point)
        var column = Int( ( point.x - gridRect.minX ) / gridRect.width * CGFloat(columns) ) + 1
        column = max( min(column, columns), 0 )
        var row = Int( ( point.y - gridRect.minY ) / gridRect.height * CGFloat(rows) ) + 1
        row = max( min( row, rows ), 0 )
        
        return (row: row, column: column)
    }
    
    func changeMark(atCell cell: (row: Int, column: Int), withMark mark: Int) {
        let cellAddress = cell.row * 10000 + cell.column
        if markedCells[cellAddress] != mark {
            markedCells[cellAddress] = mark
        } else {
            markedCells.removeValue(forKey: cellAddress)
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
