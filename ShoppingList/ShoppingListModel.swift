//
//  ShoppingListModel.swift
//  ShoppingList
//
//  Created by 加藤研太郎 on 2023/01/16.
//

import Foundation

struct Item {
    let itemName:String
    var isFavorited:Bool
    var isBought:Bool
}

final class ShoppingListModel {
    private let userDefaults = UserDefaults()
    
    func post(_ names:[String]){
        self.userDefaults.set(names, forKey: "names")
    }
    func fetch()->[String]{
        let anyNames = self.userDefaults.array(forKey: "names")
        if let names = anyNames as?[String]{
            return names
        }else{
            print("fetchに失敗")
        }
        return [""]
    }
}
