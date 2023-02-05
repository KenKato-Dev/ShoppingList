//
//  AppendViewModel.swift
//  ShoppingList
//
//  Created by 加藤研太郎 on 2023/01/28.
//

import Foundation

enum StateOfAppendViewModel {
    case appended
    case error
    case tappedFull
}

final class AppendViewModel {
    @Published private(set) var count: Int = 0
    @Published private(set) var array: [String] = ["", "", "", "", ""]
    @Published private(set) var state: StateOfAppendViewModel?
    private let model: ShoppingListModel

    init(model: ShoppingListModel) {
        self.model = model
    }

    func didEditTextField(_ row: Int, _ textContents: String) {
        array[row] = textContents
    }

    func didTapAppendButton() {
        let filledArray = array.filter { !$0.isEmpty }
        let items: [Item] = filledArray.map { Item(itemName: $0, isFavorited: false, isBought: false) }
        model.post(items) { result in
            switch result {
            case .success:
                self.state = .appended
            case let .failure(error):
                print(error.localizedDescription)
                self.state = .error
            }
        }
    }

    func didTapAddCellButton() {
        if count < 5 {
            count += 1
        } else {
            count = 5
            state = .tappedFull
        }
    }
}
