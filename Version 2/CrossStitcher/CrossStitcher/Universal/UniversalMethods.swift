//
//  UniversalMethods.swift
//  CrossStitcher
//
//  Created by Valery Dubovoy on 28.10.2022.
//

import Foundation
import UIKit

struct UniversalSystem {
    static func showAlertMessage(_ messageText: String, withTitle title: String, inView vc:UIViewController ){
        let alert = UIAlertController(title: NSLocalizedString( title, comment: "" ),
                                      message: NSLocalizedString( messageText, comment: "" ),
                                      preferredStyle: .alert)
        
        alert.addAction(
            UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"),
                          style: .default,
                          handler: { _ in NSLog("The \"OK\" alert occured.") }
            )
        )
        vc.present(alert, animated: true, completion: nil)
    }

}
