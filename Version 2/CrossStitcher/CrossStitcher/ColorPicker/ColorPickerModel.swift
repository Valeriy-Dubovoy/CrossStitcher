//
//  ColorPickerModel.swift
//  CrossStitcher
//
//  Created by Valery Dubovoy on 25.02.2024.
//

import Foundation
import UIKit

protocol ColorPickerPresenterProtocol: AnyObject {
    var color: UIColor {get set}
    var image: UIImage? {get}
    
    var doneAction: ( UIColor, CGFloat ) -> Void? {get}
    
    init(view: ColorPickerViewProtocol, sampleImage: UIImage?, choosenColor: UIColor, alfa: CGFloat, completion: @escaping ( UIColor, CGFloat ) -> Void)
    
    func choose(color: UIColor) -> Void
    func choose(alfa: CGFloat ) -> Void
    func viewDidLoad()
}

protocol ColorPickerViewProtocol: AnyObject {
    //var presenter: ColorPickerPresenterProtocol {get}
    
    func setSampleImage( with image: UIImage?)
    func setCurrentColor( with color: UIColor)
    func setAlfa( with alfa: CGFloat)
}
