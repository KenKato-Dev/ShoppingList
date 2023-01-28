//
//  ViewController.swift
//  ShoppingList
//
//  Created by 加藤研太郎 on 2023/01/15.
//

import UIKit
import Combine

class ShoppingListViewController: UIViewController {

    @IBOutlet weak var shoppingListTableView: UITableView!
    @IBOutlet weak var deleteButton: UIButton!
    private var array:[String] = []
    private var cancellable = Set<AnyCancellable>()
    private let viewModel:ShoppingListViewModel = ShoppingListViewModel(model: ShoppingListModel())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.shoppingListTableView.delegate = self
        self.shoppingListTableView.dataSource = self
        self.setupBinder()
        self.shoppingListTableView.reloadData()
        self.nameTextField.addAction(.init(handler: { _ in
            guard let name = self.nameTextField.text else{return}
            self.viewModel.displayEditingTextOnFirst(name)
//            self.shoppingListTableView.reloadData() //いらない、.editingChangedなだけでcellの数は変わらず
        }), for: .editingChanged)
        self.addButton.addAction(.init(handler: { _ in
            //addbutton処理
            guard let name = self.nameTextField.text else{return}
            self.array.append(name)
            self.viewModel.didTapAddButton(name)
            self.nameTextField.text = ""
            self.shoppingListTableView.reloadData()
        }), for: .touchUpInside)
        self.deleteButton.addAction(.init(handler: { _ in
            self.viewModel.didTapDeleteButton()
        }), for: .touchUpInside)
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    private func setupBinder(){
        //viewModelのPublishedをsinkで監視購読し実行
        self.viewModel.$namesArray.sink { [weak self] namesArray in
                self?.array = namesArray
        }.store(in: &cancellable)
        
        self.viewModel.$name.sink { [weak self] name in
            if let name = name{
                self?.navigationItem.title = name
            }else{
            }
        }.store(in: &cancellable)
    }
}
extension ShoppingListViewController:UITextFieldDelegate{
    
}
extension ShoppingListViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.viewModel.namesArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = shoppingListTableView.dequeueReusableCell(withIdentifier: "ShoppingListCell", for: indexPath) as? ShoppingListCell else {fatalError("Cell表示に失敗")}
        cell.nameLabel.text = self.viewModel.namesArray[indexPath.row]
//        cell.nameLabel.text = self.array[indexPath.row]
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("\(indexPath.row)番目のcellがタップされました")
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        self.viewModel.isDelete
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle{
        case .delete:
            self.array.remove(at: indexPath.row)
            shoppingListTableView.beginUpdates()
            shoppingListTableView.deleteRows(at: [indexPath], with: .automatic)
            shoppingListTableView.endUpdates()
        case.insert, .none:
            break
        }
    }
    
    
}
// 消去機能、お気に入り
