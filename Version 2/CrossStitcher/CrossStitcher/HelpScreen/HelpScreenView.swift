//
//  HelpScreenView.swift
//  CrossStitcher
//
//  Created by Valery Dubovoy on 07.04.2024.
//

import SwiftUI

struct HelpScreenView: View {
    @State var isSecondTapClearCell: Bool = Constants.secondTapClearCell()
    
    private func saveOptions() {
        Constants.setSecondTapClearCell(with: isSecondTapClearCell)
    }
    
    var body: some View {
        ScrollView {
            Text( NSLocalizedString("Options", comment: ""))
                .font(.title)
            
            Toggle(NSLocalizedString("Second tap clear cell", comment: ""), isOn: $isSecondTapClearCell)
                .padding(.horizontal)
                .onChange(of: isSecondTapClearCell, perform: Constants.setSecondTapClearCell(with: ) )
            // Description for option
            Group {
                if isSecondTapClearCell {
                    Text(NSLocalizedString("Second tap clear marker", comment: ""))
                } else {
                    Text(NSLocalizedString("Second tap just mark the cell", comment: ""))
                    
                }
            }
            .font(.footnote)
            .padding(.bottom)

            Text(NSLocalizedString("Overview", comment: ""))
                .font(.title2)
            
           HelpDescriptionView()
            
        }.padding()
    }
}

struct HelpDescriptionView: View {
    var body: some View {
        let htmlString = Constants.helpText(lang: NSLocalizedString("en", comment: ""))
        
        let blocks = divideHTMLtoBlocksWithImages(htmlString: htmlString)

        return VStack{
            ForEach( blocks, id: \.self) { item in
                if item.hasPrefix("<img"), let imageName = extractImageName(imageTag: item), imageName != "" {
                    Image(imageName, label: Text(""))
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } else {
                    Text(html: item)
                }
            }
        }
    }
    
    func divideHTMLtoBlocksWithImages( htmlString: String ) -> [String] {
        let regex = try! NSRegularExpression(pattern: "<img[^>]+>", options: [])
        let range = NSRange(location: 0, length: htmlString.utf16.count)
        let matches = regex.matches(in: htmlString, options: [], range: range)

        var blocks: [String] = []
        var currentPosition = 0

        for match in matches {
            let startIndex = htmlString.index(htmlString.startIndex, offsetBy: match.range.lowerBound)
            let endIndex = htmlString.index(htmlString.startIndex, offsetBy: match.range.upperBound)
            let imgTag = htmlString[startIndex..<endIndex]

            let currentIndex = htmlString.index(htmlString.startIndex, offsetBy: currentPosition)
            let precedingBlock = htmlString[currentIndex..<startIndex]
            blocks.append( String( precedingBlock) )
            blocks.append( String( imgTag ) )

            currentPosition = match.range.upperBound
        }

        let currentIndex = htmlString.index(htmlString.startIndex, offsetBy: currentPosition)
        let trailingBlock = htmlString[currentIndex...]
        blocks.append( String( trailingBlock ) )

        return blocks
    }
    
    func extractImageName( imageTag: String ) -> String {
        // tag = <img="imageName">
        let startIndex = imageTag.index( imageTag.startIndex, offsetBy: 6)
        let endIndex = imageTag.index( imageTag.endIndex, offsetBy: -2)
        let substring = imageTag[startIndex..<endIndex]
        return String(substring)
    }
}

extension Text {
    init(html htmlString: String, // the HTML-formatted string
         raw: Bool = false, // set to true if you don't want to embed in the doc skeleton
         size: CGFloat? = nil, // optional document-wide text size
         fontFamily: String = "-apple-system") { // optional document-wide font family
        let fullHTML: String
        if raw {
            fullHTML = htmlString
        } else {
            var sizeCss = ""
            if let size = size {
                sizeCss = "font-size: \(size)px;"
            }
            fullHTML = """
        <!doctype html>
         <html>
            <head>
              <style>
                body {
                  font-family: \(fontFamily);
                  \(sizeCss)
                }
              </style>
            </head>
            <body>
              \(htmlString)
            </body>
          </html>
        """
        }
        let attributedString = fullHTML.htmlNSAttributedString(size: size ?? 12, color: nil) ?? NSAttributedString()
        
        self.init(attributedString) // uses the NSAttributedString initializer
    }
    
    init(_ attributedString: NSAttributedString) {
        self.init("") // initial, empty Text
        
        // scan the attributed string for distinctly attributed regions
        attributedString.enumerateAttributes(in: NSRange(location: 0, length: attributedString.length),
                                             options: []) { (attrs, range, _) in
            let string = attributedString.attributedSubstring(from: range).string
            var text = Text(string)
            
            // then, read applicable attributes and apply them to the Text
            
            if let font = attrs[.font] as? UIFont {
                // this takes care of the majority of formatting - text size, font family,
                // font weight, if it's italic, etc.
                text = text.font(.init(font))
            }
            
            if let color = attrs[.foregroundColor] as? UIColor {
                text = text.foregroundColor(Color(color))
            }
            
            if let kern = attrs[.kern] as? CGFloat {
                text = text.kerning(kern)
            }
            
            if #available(iOS 14.0, *) {
                if let tracking = attrs[.tracking] as? CGFloat {
                    text = text.tracking(tracking)
                }
            }
            
            if let strikethroughStyle = attrs[.strikethroughStyle] as? NSNumber,
               strikethroughStyle != 0 {
                if let strikethroughColor = (attrs[.strikethroughColor] as? UIColor) {
                    text = text.strikethrough(true, color: Color(strikethroughColor))
                } else {
                    text = text.strikethrough(true)
                }
            }
            
            if let underlineStyle = attrs[.underlineStyle] as? NSNumber,
               underlineStyle != 0 {
                if let underlineColor = (attrs[.underlineColor] as? UIColor) {
                    text = text.underline(true, color: Color(underlineColor))
                } else {
                    text = text.underline(true)
                }
            }
            
            if let baselineOffset = attrs[.baselineOffset] as? NSNumber {
                text = text.baselineOffset(CGFloat(baselineOffset.floatValue))
            }
            
            // append the newly styled subtext to the rest of the text
            self = self + text
        }
    }
}

struct HelpScreenView_Previews: PreviewProvider {
    static var previews: some View {
        HelpScreenView()
    }
}
