//
//  ShoppingListViewModel.swift
//  ShoppingList
//
//  Created by 加藤研太郎 on 2023/01/16.
//
//

import Foundation
import UIKit

enum StateOfShoppingViewModel: Equatable {
    case loading
    case loaded
    case error(String)
}

enum StateOfTableView {
    case normal
    case favorite
    case delete
}

class ShoppingListViewModel {
    @Published private(set) var items: [Item] = []
    @Published private(set) var state: StateOfShoppingViewModel?
    private(set) var isDelete = false
    private(set) var isFavorite = false
    private let model: ShoppingListModel
    @Published private(set) var stateOfTableView: StateOfTableView?
    init(model: ShoppingListModel) {
        self.model = model
    }

    func fetchArray(_ stateOfTableView: StateOfTableView) {
        state = .loading
        model.fetch { result in
            switch result {
            case let .success(items):
                if stateOfTableView == .normal || stateOfTableView == .delete {
                    self.items = items
                } else if self.stateOfTableView == .favorite {
                    self.items = items.filter { $0.isFavorited }
                }
                self.state = .loaded
            case let .failure(failure):
                print(failure.localizedDescription)
                self.state = .error(failure.localizedDescription)
            }
        }
    }

    func reload(_ tableView: UITableView) {
        fetchArray(.normal)
        tableView.reloadData()
    }

    func didTapIsBought(_ row: Int) {
        items[row].isBought.toggle()
        model.post(items) { result in
            switch result {
            case .success:
                self.fetchArray(self.stateOfTableView ?? .normal)
                print(self.items[row])
            case let .failure(failure):
                print(failure.localizedDescription)
            }
        }
    }

    func didTapIsFavorite(_ row: Int) {
        items[row].isFavorited.toggle()
        model.post(items) { result in
            switch result {
            case .success:
                self.fetchArray(self.stateOfTableView ?? .normal)
                print("didTapF:\(self.items[row])")
            case let .failure(failure):
                print(failure.localizedDescription)
            }
        }
    }

    func didTapFavoriteButton() {
        isFavorite.toggle()
        if isFavorite {
            stateOfTableView = .favorite
            fetchArray(stateOfTableView ?? .normal)
            state = .loaded
        } else {
            stateOfTableView = .normal
            fetchArray(stateOfTableView ?? .normal)
            state = .loaded
        }
    }

    func didTapDeleteButton() {
        isDelete.toggle()
        if isDelete {
            stateOfTableView = .delete
        } else {
            stateOfTableView = .normal
        }
    }

    func deleteAction(_ row: Int) {
        if isDelete {
            items.remove(at: row)
            model.post(items) { result in
                switch result {
                case .success:
                    self.fetchArray(self.stateOfTableView ?? .normal)
                case let .failure(failure):
                    print("エラー発生\(failure.localizedDescription)")
                }
            }
        }
    }

    func setInitialLoadedView() {
        state = .loaded
        fetchArray(stateOfTableView ?? .normal)
    }

    func writeStrikeThroughLine(_ isBought: Bool, _ cellText: String) -> NSMutableAttributedString {
        let attributeString = NSMutableAttributedString(string: cellText)
        if isBought {
            attributeString.addAttribute(
                NSAttributedString.Key.strikethroughStyle,
                value: 1,
                range: NSRange(location: 0, length: attributeString.length)
            )
            return attributeString
        } else {
            attributeString.addAttribute(
                NSAttributedString.Key.strikethroughStyle,
                value: 0,
                range: NSRange(location: 0, length: attributeString.length)
            )

            return attributeString
        }
    }
}
