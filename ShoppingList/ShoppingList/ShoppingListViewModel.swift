//
//  ShoppingListViewModel.swift
//  ShoppingList
//
//  Created by 加藤研太郎 on 2023/01/16.
//
// Viewが表示するものはViewModelで、このため中の配列に関するところはVMで
// 

import Foundation

enum StateOfShoppingViewModel: Equatable {
case loaded
case error(String)
case favorite
case delete
}
class ShoppingListViewModel {
    @Published private (set) var array: [Item] = []
    @Published private (set) var state: StateOfShoppingViewModel?
    private (set) var isDelete = false
    private let model: ShoppingListModel
    init(model: ShoppingListModel) {
        self.model = model
    }
    func fetchArray() {
        self.model.fetch { result in
            switch result {
            case .success(let items):
                self.state = .loaded
                self.array = items
                print(items)
            case .failure(let failure):
                self.state = .error(failure.localizedDescription)
            }
        }
    }
    func didTapFavoriteButton() {
        self.state = .favorite

    }
    func didTapDeleteButton() {
        self.state = .delete
    }
    func deleteAction(_ row: Int) {
        // ここに配列から削除処理を追加
        self.array.remove(at: row)
        self.model.post(self.array) { result in
            switch result {
            case .success:
                self.fetchArray()
            case .failure(let failure):
                self.state = .error(failure.localizedDescription)
                // ポスト処理失敗を記載
            }
        }
    }
}
