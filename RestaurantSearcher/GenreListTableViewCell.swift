//
//  GenreListTableViewCell.swift
//  RestaurantSearcher
//
//  Created by YoNa on 2021/05/08.
//

import UIKit



class GenreListTableViewCell: UITableViewCell {

    @IBOutlet weak var checkmarkImageView: UIImageView!
    @IBOutlet weak var genreNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
