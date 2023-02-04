//
//  ShoppingListCell.swift
//  ShoppingList
//
//  Created by 加藤研太郎 on 2023/01/18.
//

import UIKit

class ShoppingListCell: UITableViewCell {

    @IBOutlet weak var isBoughtButton: UIButton!
    @IBOutlet weak var isFavoriteButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
//    private var isBought = false {
//        didSet {
//            if isBought == true {
//                isBoughtButton.setImage(UIImage(named: "checkmark.circle"), for: .normal)
//            } else {
//                isBoughtButton.setImage(UIImage(named: "circle"), for: .normal)
//            }
//        }
//    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        isBoughtButton.addAction(.init(handler: { _ in
//            self.isBought.toggle()
        }), for: .touchUpInside)
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state

    }

}
