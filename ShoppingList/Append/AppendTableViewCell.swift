//
//  AppendTableViewCell.swift
//  ShoppingList
//
//  Created by 加藤研太郎 on 2023/01/28.
//

import UIKit

final class AppendTableViewCell: UITableViewCell {

    @IBOutlet weak var listTextField: TextFieldSub!
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        listTextField.text =  ""
    }
    func fillInText(_ text: String) {
        listTextField.text = text
    }
}
extension AppendTableViewCell: UITextFieldDelegate {
    internal func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
