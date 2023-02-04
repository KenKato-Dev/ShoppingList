//
//  ViewController.swift
//  ShoppingList
//
//  Created by 加藤研太郎 on 2023/01/15.
//

import UIKit
import Combine

class ShoppingListViewController: UIViewController {

    @IBOutlet weak var appendButton: UIButton!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var shoppingListTableView: UITableView!
    @IBOutlet weak var deleteButton: UIButton!
    private var array: [Item] = []
    private var cancellable = Set<AnyCancellable>()
    private let viewModel: ShoppingListViewModel = ShoppingListViewModel(model: ShoppingListModel())
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Int, Item>
    private typealias DataSource = UITableViewDiffableDataSource<Int, Item>
    private var dataSource: DataSource?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.shoppingListTableView.delegate = self
        self.shoppingListTableView.dataSource = self

        self.setupBinder()
        self.appendButton.addAction(.init(handler: { _ in
            self.performSegue(withIdentifier: "ToAppendView", sender: nil)
        }), for: .touchUpInside)
        self.deleteButton.addAction(.init(handler: { _ in
            self.viewModel.didTapDeleteButton()
        }), for: .touchUpInside)
    }

}
extension ShoppingListViewController: UITextFieldDelegate {

}
extension ShoppingListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.array.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = shoppingListTableView.dequeueReusableCell(withIdentifier: "ShoppingListCell", for: indexPath) as? ShoppingListCell else {fatalError("Cell表示に失敗")}

        cell.nameLabel.text = self.array[indexPath.row].itemName
//        cell.nameLabel.text = self.array[indexPath.row]
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        print("\(indexPath.row)番目のcellがタップされました")
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if self.viewModel.state == .delete {
            return true
        } else {
            return false
        }
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        switch editingStyle {
//        case .delete:
//            self.array.remove(at: indexPath.row)
//            shoppingListTableView.beginUpdates()
//            shoppingListTableView.deleteRows(at: [indexPath], with: .automatic)
//            shoppingListTableView.endUpdates()
//        case.insert, .none:
//            break
//        }
    }
}
extension ShoppingListViewController {
    private func setupBinder() {
        // viewModelのPublishedをsinkで監視購読し実行
        self.viewModel.$array.sink { [weak self] array in
                self?.array = array
        }.store(in: &cancellable)

        self.viewModel.$state
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                guard let state = state else {return}
                switch state {
                case .loaded:
                    self?.reload()
                case .error(let message):
                    self?.showErrorMessageIfNeeded(message)
                case .favorite:
                    // favorite表示
                    print("state = favorite")
                case .delete:
                    // deleteモード

                    print("state = delete")
                }
            }.store(in: &cancellable)
        Task {
            await viewModel.fetchArray()
        }
    }
    private func reload() {
//        guard let refreshControl = shoppingListTableView.refreshControl else {return}
//        shoppingListTableView.setContentOffset(CGPoint(x: 0, y: shoppingListTableView.contentOffset.y - refreshControl.frame.height), animated: true)
//        refreshControl.beginRefreshing()
        self.shoppingListTableView.reloadData()
    }
    private func showErrorMessageIfNeeded(_ message: String) {
        let alert = UIAlertController(title: "エラー", message: message, preferredStyle: .alert)
        alert.addAction(.init(title: "閉じる", style: .default))
        present(alert, animated: true)
    }
}
