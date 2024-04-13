//
//  StitchTableViewCell.swift
//  CrossStitcher
//
//  Created by Valery Dubovoy on 26.10.2022.
//

import UIKit

class StitchTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func config(with stitch: DBStitch){
        var newConfig = defaultContentConfiguration()
        newConfig.text = stitch.name
        if let imgData = stitch.preview, let img = UIImage(data: imgData) {
            let size = img.size
            let targetSize = CGSize(width: 50, height: 50)
            
            let widthRatio  = targetSize.width  / size.width
            let heightRatio = targetSize.height / size.height
            
            // Figure out what our orientation is, and use that to form the rectangle
            var newSize: CGSize
            if(widthRatio > heightRatio) {
                newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
            } else {
                newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
            }
            
            // This is the rect that we've calculated out and this is what is actually used below
            let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
            
            // Actually do the resizing to the rect using the ImageContext stuff
            UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
            img.draw(in: rect)
            let previewImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
                        
            newConfig.image = previewImage
        }
        
        contentConfiguration = newConfig
    }

}
