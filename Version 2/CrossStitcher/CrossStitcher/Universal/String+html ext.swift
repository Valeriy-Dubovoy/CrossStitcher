//
//  String+html ext.swift
//  CrossStitcher
//
//  Created by Valery Dubovoy on 07.04.2024.
//

import Foundation
import UIKit

extension String {
    
    func htmlNSAttributedString(size: CGFloat, color: UIColor?) -> NSAttributedString? {
        let htmlTemplate = """
        <!doctype html>
        <html>
          <head>
            <style>
              body {
                \(color == nil ? "": "color: \(color!.hexString!);")
                
                font-family: -apple-system;
                font-size: \(size)px;
              }
            </style>
          </head>
          <body>
            \(self)
          </body>
        </html>
        """

        guard let data = htmlTemplate.data(using: .utf8) else {
            return nil
        }

        guard let attributedString = try? NSAttributedString(
            data: data,
            options: [.documentType: NSAttributedString.DocumentType.html],
            documentAttributes: nil
            ) else {
            return nil
        }

        return attributedString
    }
    
    func htmlNSAttributedString() -> NSAttributedString? {
//        guard let data = self.data(using: .utf8) else {
//            return nil
//        }
//
//        return try? NSAttributedString(
//            data: data,
//            options: [.documentType: NSAttributedString.DocumentType.html],
//            documentAttributes: nil
//        )
        let htmlTemplate = """
        <!doctype html>
        <html>
          <head>
            <style>
              body {
                font-family: -apple-system;
                font-size: 12px;
              }
            </style>
          </head>
          <body>
            \(self)
          </body>
        </html>
        """

        guard let data = htmlTemplate.data(using: .utf8) else {
            return nil
        }

        guard let attributedString = try? NSAttributedString(
            data: data,
            options: [.documentType: NSAttributedString.DocumentType.html],
            documentAttributes: nil
            ) else {
            return nil
        }

        return attributedString
    }
}
