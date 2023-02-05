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
    @Published private(set) var items: [Item] = []
    @Published private(set) var state: StateOfShoppingViewModel?
    private(set) var isDelete = false
    private(set) var isFavorite = false
    private let model: ShoppingListModel

    init(model: ShoppingListModel) {
        self.model = model
    }

    func fetchArray() {
        model.fetch { result in
            switch result {
            case let .success(items):
//                self.state = .loaded
                self.items = items
                print(items)
            case let .failure(failure):
                print(failure.localizedDescription)
                self.state = .error(failure.localizedDescription)
            }
        }
    }

    func didTapIsBought(_ isBought: inout Bool) {
        isBought.toggle()
    }

    func didTapIsFavorite(_ isFavorite: inout Bool) {
        isFavorite.toggle()
    }

    func filterFavorites() {
        items = items.filter { $0.isFavorited }
    }

    func didTapFavoriteButton() {
        isFavorite.toggle()
        if isFavorite {
            state = .favorite
            filterFavorites()
        } else {
            state = .loaded
        }
    }

    func didTapDeleteButton() {
        isDelete.toggle()
        if isDelete {
            state = .delete
        } else {
            state = .loaded
        }
    }

    func deleteAction(_ row: Int) {
        // ここに配列から削除処理を追加
        if isDelete {
            items.remove(at: row)
            model.post(items) { result in
                switch result {
                case let .success(success):
                    self.fetchArray()
                case let .failure(failure):
                    print("エラー発生\(failure.localizedDescription)")
                }
            }
        }
    }

    func setInitialLoadedView() {
        state = .loaded
        fetchArray()
    }
}
