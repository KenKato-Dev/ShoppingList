//
//  ShoppingListModel.swift
//  ShoppingList
//
//  Created by 加藤研太郎 on 2023/01/16.
//

import Foundation

struct Item: Codable, Hashable {
    let itemName: String
    var isFavorited: Bool
    var isBought: Bool
}

final class ShoppingListModel {
    private let userDefaults = UserDefaults()

    func post(_ itemArray: [Item], _ completion: @escaping (Result<Void, Error>) -> Void) {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted

        do {
            let data = try encoder.encode(itemArray)
            userDefaults.set(data, forKey: "postedData")
            completion(.success(()))
        } catch {
            completion(.failure(error))
            print("えんこーどに失敗")
        }
    }

    func fetch(_ completion: @escaping (Result<[Item], Error>) -> Void) {
        let decoder = JSONDecoder()
        guard let postedItem = userDefaults.value(forKey: "postedData") as? Data else { return }
        do {
            let decodedItemArray = try decoder.decode([Item].self, from: postedItem)
            completion(.success(decodedItemArray))
        } catch {
            completion(.failure(error))
            print("デコードに失敗")
        }
    }

    func delete() {}
    // postで代用可能
//    func postToFavorites(){
//
//    }
//    func fetchFromFavorites() {
//
//    }
//    func deleteFromFavorites() {
//
//    }
}
