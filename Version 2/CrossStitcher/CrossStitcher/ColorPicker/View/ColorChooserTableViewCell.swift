//
//  ColorChooserTableViewCell.swift
//  CrossStitcher
//
//  Created by Valery Dubovoy on 02.03.2024.
//

import UIKit

class ColorChooserTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBOutlet weak var colorView: UIView!
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        var content = self.defaultContentConfiguration()
        content.image = UIImage(systemName: "arrow.right.to.line")
        
        self.contentConfiguration = content
    }
    
    func configWith(color: UIColor, isSelected: Bool){
        self.colorView.backgroundColor = color
    }
}
