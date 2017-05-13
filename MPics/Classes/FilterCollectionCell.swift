//
//  FilterCollectionCell.swift
//  Pods
//
//  Created by Moin Pansare on 12/05/17.
//
//

import UIKit

class FilterCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var myImageView: UIImageView!
    
    var myImage : UIImage = UIImage(){
        didSet{
            self.myImageView.image = nil;
            self.myImageView.layer.cornerRadius = 5;
            self.myImageView.image = myImage;
            self.myImageView.clipsToBounds = true;
            self.myImageView.layer.shadowColor = UIColor.black.cgColor;
            self.myImageView.layer.shadowOffset = CGSize(width: 3.0, height: 3.0);
            self.myImageView.layer.shadowRadius = 5;
        }
    }
}
