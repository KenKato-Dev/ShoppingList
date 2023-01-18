//
//  ShoppingListViewModel.swift
//  ShoppingList
//
//  Created by 加藤研太郎 on 2023/01/16.
//

import Foundation

final class ShoppingListViewModel{
    @Published var name:String?
    @Published var namesArray:[String]?
    private (set) var isDelete = false
    
    private let model:ShoppingListModel
    
    init(model: ShoppingListModel) {
        self.model = model
    }
    func fetchArray(){
    }
    func numberOfRows() -> Int{
        if let namesArray = namesArray{
            if namesArray.count == 0{
                return 0
            }
            else{
                return namesArray.count
            }
        }else{
            return 0
        }
        //cellの数を変換
    }
    func cellForRowAt(indexPath:IndexPath) -> String{
        //cell中身を描写
        if let namesArray = namesArray{
            return namesArray[indexPath.row]
        }else{
            return "読み込みに失敗"
        }
        
    }
    func displayEditingTextOnFirst(_ name:String){
        self.name = name
        //編集中のTextを1列目に表示する処理
    }
    func didTapAddButton(_ names:[String]){
        self.namesArray = names
//        print("name:\(names),array:\(self.namesArray)")
        //addButtonの処理
    }
    func didTapDeleteButton(){
        //deleteButtonの処理
        self.isDelete.toggle()
    }
}
