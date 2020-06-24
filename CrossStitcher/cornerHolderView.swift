//
//  gridSizerCornerSquare.swift
//  CrossStitcher
//
//  Created by Valery Dubovoy on 21/06/2020.
//  Copyright © 2020 Nick Walter. All rights reserved.
//

import UIKit

class cornerHolderView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setStandartProperties()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setStandartProperties()
    }
    
    func setStandartProperties() {
        contentMode = .redraw
        isOpaque = false    // прозрачный

        bounds = CGRect(x: 0, y: 0, width: viewSize, height: viewSize)
    }
    
    private let viewSize = 30
    private let lineWidth = 4
    var lineColor = #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1)

    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // обведем рамку
        let path = UIBezierPath()

        let lineOffset = lineWidth / 2
        path.move(to: CGPoint(x: lineOffset,
                              y: lineOffset))        // переместить перо в начальную точку
        path.addLine(to: CGPoint(x: lineOffset,
                                 y: viewSize - lineOffset))    // нарисовать линию
        path.addLine(to: CGPoint(x: viewSize - lineOffset,
                                 y: viewSize - lineOffset))    // нарисовать линию
        path.addLine(to: CGPoint(x: viewSize - lineOffset,
                                 y: lineOffset))    // нарисовать линию
        path.addLine(to: CGPoint(x: lineOffset,
                                 y: lineOffset))    // нарисовать линию

        lineColor.setStroke()
        path.lineWidth = CGFloat(lineWidth)
        //path.fill()                            // отображаем
        path.stroke()
    }

}
