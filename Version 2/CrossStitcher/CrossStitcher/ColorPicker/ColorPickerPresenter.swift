//
//  ColorPickerPresenter.swift
//  CrossStitcher
//
//  Created by Valery Dubovoy on 25.02.2024.
//

import Foundation
import UIKit

class ColorPickerPresenter: ColorPickerPresenterProtocol {
    
    weak var view: ColorPickerViewProtocol?
    var color: UIColor
    var image: UIImage?
    var alfa: CGFloat
    var doneAction: (UIColor, CGFloat) -> Void? 

    required init(view: ColorPickerViewProtocol, sampleImage: UIImage?, choosenColor: UIColor, alfa: CGFloat,  completion: @escaping (UIColor, CGFloat) -> Void) {
        self.view = view
        self.image = sampleImage
        self.color = choosenColor
        self.alfa = min( max(alfa, 0), 1 )
        self.doneAction = completion
    }
    
    func choose(color: UIColor) {
        self.color = color
        view?.setCurrentColor(with: color)
    }
    
    func choose(alfa: CGFloat ) {
        
        self.alfa = alfa
        view?.setAlfa(with: alfa)
    }
    
    func viewDidLoad() {
        view?.setSampleImage(with: image)
        view?.setCurrentColor(with: color)
        view?.setAlfa(with: alfa)
    }
}
