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
    
    func config(with stitch: Stitch){
        var newConfig = defaultContentConfiguration()
        newConfig.text = stitch.name
        
        contentConfiguration = newConfig
    }

}
