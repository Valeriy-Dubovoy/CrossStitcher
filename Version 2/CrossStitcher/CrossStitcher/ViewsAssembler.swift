//
//  ViewsAssembler.swift
//  CrossStitcher
//
//  Created by Valery Dubovoy on 05.02.2024.
//

import UIKit

import UIKit

protocol ViewsAssemblerProtocol {
    static func createStitchListTableViewController() -> UIViewController
    //static func createColorPickerView() -> UIViewController
    //static func createCommentsDetailViewController(comment: Comment?) -> UIViewController

}

class ViewsAssembler: ViewsAssemblerProtocol {
    static func createStitchListTableViewController() -> UIViewController {
        let view = StitchListTableViewController()
        /*
         let networkService = NetworkService()
        let presenter = CommentsPresenter(view: view, networkService: networkService)
        
        view.presenter = presenter
        */
        return view
    }
    
    static func createStitchPropertyEditorViewController(for dbStitchItem: DBStitch?) -> UIViewController {
        let view = StitchEditorTableViewController()
        let presenter = StitchPresenter(view: view, dbStitch: dbStitchItem)
        
        view.presenter = presenter
        return view
    }
    
    static func createColorPickerView(color: UIColor, alfa: CGFloat, sampleImage: UIImage?, completion: @escaping (UIColor, CGFloat) -> Void ) -> UIViewController {
        let view = ColorPickerViewController()//ColorChooserViewController()
        let presenter = ColorPickerPresenter(view: view, sampleImage: sampleImage ?? UIImage(named: "free-icon-embroidery-7076323"), choosenColor: color, alfa: alfa, completion: completion)
        
        view.presenter = presenter
        return view
    }
    
}
