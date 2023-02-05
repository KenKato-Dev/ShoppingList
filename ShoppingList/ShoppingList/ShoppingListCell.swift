//
//  ShoppingListCell.swift
//  ShoppingList
//
//  Created by 加藤研太郎 on 2023/01/18.
//

import UIKit

class ShoppingListCell: UITableViewCell {
    @IBOutlet var isBoughtButton: UIButton!
    @IBOutlet var isFavoriteButton: UIButton!
    @IBOutlet var nameLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func setIsBoughtImage(_ isBought: Bool) {
        if isBought {
            isBoughtButton.setImage(UIImage(systemName: "checkmark.circle"), for: .normal)
            isBoughtButton.imageView?.tintColor = .red
        } else {
            isBoughtButton.setImage(UIImage(systemName: "circle"), for: .normal)
            isBoughtButton.tintColor = .darkGray
        }
    }

    func setIsFavoriteImage(_ isFavorite: Bool) {
        if isFavorite {
            isFavoriteButton.setImage(UIImage(systemName: "star.fill"), for: .normal)
            isFavoriteButton.tintColor = .yellow
        } else {
            isFavoriteButton.setImage(UIImage(systemName: "star"), for: .normal)
            isFavoriteButton.tintColor = .yellow
        }
    }
}
