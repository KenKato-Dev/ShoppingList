//
//  ShoppingListViewModel.swift
//  ShoppingList
//
//  Created by 加藤研太郎 on 2023/01/16.
//
// Viewが表示するものはViewModelで、このため中の配列に関するところはVMで
// 

import Foundation

final class ShoppingListViewModel{
    @Published private (set) var name:String?
    @Published private (set) var namesArray:[String] = []
    private (set) var isDelete = false
    
    private let model:ShoppingListModel
    
    init(model: ShoppingListModel) {
        self.model = model
    }
    func fetchArray(){
    }
    //ここはarray.count ?? 0

    func displayEditingTextOnFirst(_ name:String){
        self.name = name
        //編集中のTextを1列目に表示する処理
    }
    func didTapAddButton(_ name:String){
        self.namesArray.append(name)
//        print("name:\(names),array:\(self.namesArray)")
        //addButtonの処理
    }
    func didTapDeleteButton(){
        //deleteButtonの処理
        self.isDelete.toggle()
    }
    func deleteAction(_ indexPath:IndexPath){
        self.namesArray.remove(at: indexPath.row)
        
    }
}
