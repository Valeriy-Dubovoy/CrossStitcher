//
//  ImageCollectionViewCell.swift
//  ImagePuzzleViaCollectionView
//
//  Created by Valery Dubovoy on 12.05.2022.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    
    var image: UIImage? {
        didSet {
            imageView.image = image
        }
    }
    
    func setMarkerColor(color: UIColor, alfa: CGFloat) {
        viewForMarkerColor.backgroundColor = color
        viewForMarkerColor.alpha = alfa
    }
    
    lazy var imageView: UIImageView = {
        let iv = UIImageView.init(frame: self.frame)
        iv.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(iv)
        NSLayoutConstraint.activate([
            iv.topAnchor.constraint(equalTo: self.topAnchor),
            iv.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            iv.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            iv.trailingAnchor.constraint(equalTo: self.trailingAnchor)])

        return iv
    }()
    
    private lazy var viewForMarkerColor: UIView = {
        let v = UIView.init(frame: self.frame)
        
        v.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(v)
        NSLayoutConstraint.activate([
            v.topAnchor.constraint(equalTo: self.topAnchor),
            v.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            v.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            v.trailingAnchor.constraint(equalTo: self.trailingAnchor)])

        return v

    }()
    /*
    
    lazy var label: UILabel = {
        let iv = UILabel.init(frame: self.frame)
        iv.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(iv)
        NSLayoutConstraint.activate([
            iv.topAnchor.constraint(equalTo: self.topAnchor),
            iv.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            iv.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            iv.trailingAnchor.constraint(equalTo: self.trailingAnchor)])

        return iv
    }()
     */
    
}
