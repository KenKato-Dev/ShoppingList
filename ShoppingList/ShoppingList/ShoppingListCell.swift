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
    var didTapIsFavorite: (() -> Void)?
    var didTapBoughtButton: (() -> Void)?
    private(set) var isFaborite = false

    override func awakeFromNib() {
        super.awakeFromNib()

        isFavoriteButton.addAction(.init(handler: { [weak self] _ in
            self?.didTapIsFavorite?()
        }), for: .touchUpInside)
        isBoughtButton.addAction(.init(handler: { [weak self] _ in
            self?.didTapBoughtButton?()
        }), for: .touchUpInside)
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
        } else {
            isFavoriteButton.setImage(UIImage(systemName: "star"), for: .normal)
        }
    }
}
