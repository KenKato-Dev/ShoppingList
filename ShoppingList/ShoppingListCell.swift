//
//  ShoppingListCell.swift
//  ShoppingList
//
//  Created by 加藤研太郎 on 2023/01/18.
//

import UIKit

class ShoppingListCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}