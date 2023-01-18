//
//  ViewController.swift
//  ShoppingList
//
//  Created by 加藤研太郎 on 2023/01/15.
//

import UIKit
import Combine

class ShoppingListViewController: UIViewController {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var shoppingListTableView: UITableView!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    private var array:[String] = []
    private var cancellable = Set<AnyCancellable>()
    private let viewModel:ShoppingListViewModel = ShoppingListViewModel(model: ShoppingListModel())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.nameTextField.delegate = self
        self.shoppingListTableView.delegate = self
        self.shoppingListTableView.dataSource = self
        self.setupBinder()
        self.shoppingListTableView.reloadData()
        self.nameTextField.addAction(.init(handler: { _ in
            guard let name = self.nameTextField.text else{return}
            self.viewModel.displayEditingTextOnFirst(name)
            self.shoppingListTableView.reloadData()
        }), for: .editingChanged)
        self.addButton.addAction(.init(handler: { _ in
            //addbutton処理
            guard let name = self.nameTextField.text else{return}
            self.array.append(name)
            self.viewModel.didTapAddButton(self.array)
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
        //viewModelのPublishedをsinkで監視購読
        self.viewModel.$namesArray.sink { [weak self] namesArray in
            if let namesArray = namesArray{
                self?.array = namesArray
            }
        }.store(in: &cancellable)
        
        self.viewModel.$name.sink { [weak self] name in
            if let name = name{
//                print("name:\(name)")
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
//        self.viewModel.numberOfRows()
        self.viewModel.numberOfRows()
//        self.array.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = shoppingListTableView.dequeueReusableCell(withIdentifier: "ShoppingListCell", for: indexPath) as? ShoppingListCell else {fatalError("Cell表示に失敗")}
        cell.nameLabel.text = self.viewModel.cellForRowAt(indexPath: indexPath)
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
