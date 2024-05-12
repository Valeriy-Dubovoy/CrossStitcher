//
//  CrossStitchListViewCell.swift
//  CrossStitcher
//
//  Created by Valery Dubovoy on 08.03.2021.
//  Copyright © 2021 Nick Walter. All rights reserved.
//

import UIKit

class CrossStitchListViewCell: UITableViewCell {

    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var imgView: UIImageView!
    
    func configureWith(name: String?, imageData: Data?) {
        nameLabel.text = name
        if let previewData = imageData, let img = UIImage(data: previewData ) {
            imgView.image = img
            imgView.clipsToBounds = true
            imgView.layer.cornerRadius = 10
        } else {imgView.image = nil}

    }
    
/*
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
 */

}
