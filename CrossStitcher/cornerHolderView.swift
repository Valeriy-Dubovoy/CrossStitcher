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
    
    private let viewSize: CGFloat = 30.0
    @IBInspectable private let lineWidth: CGFloat = 4.0
    @IBInspectable var lineColor = #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1)

    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        
        // обведем рамку
        let path = UIBezierPath()

        let lineOffset = lineWidth / 2
        let halfOfView = viewSize / 2
        path.addArc(withCenter: CGPoint(x: halfOfView, y: halfOfView), radius: halfOfView - lineOffset, startAngle: 0, endAngle: CGFloat.pi * 2, clockwise: true)
        
        lineColor.setStroke()
        path.lineWidth = CGFloat(lineWidth)
        //path.fill()                            // отображаем
        path.stroke()
    }

    internal func drawRingFittingInsideView(rect: CGRect)->() {
        let hw:CGFloat = lineWidth/2
        let circlePath = UIBezierPath(ovalIn: rect.insetBy(dx: hw,dy: hw) )

        let shapeLayer = CAShapeLayer()
            shapeLayer.path = circlePath.cgPath
            shapeLayer.fillColor = UIColor.clear.cgColor
            shapeLayer.strokeColor = lineColor.cgColor
        shapeLayer.lineWidth = lineWidth
        layer.addSublayer(shapeLayer)
    }
}

