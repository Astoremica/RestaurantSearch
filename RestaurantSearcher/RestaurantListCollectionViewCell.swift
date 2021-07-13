//
//  CollectionViewCell.swift
//  RestaurantSearcher
//
//  Created by YoNa on 2021/05/08.
//

import UIKit

class RestaurantListCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var restaurantNameLabel: UILabel!
    @IBOutlet weak var genreNameLabel: UILabel!
    @IBOutlet weak var openLabel: UILabel!
    @IBOutlet weak var closeLabel: UILabel!
    @IBOutlet weak var accessLabel: UILabel!
    @IBOutlet weak var thumbnailImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
