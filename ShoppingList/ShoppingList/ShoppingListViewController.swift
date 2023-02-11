//
//  ViewController.swift
//  ShoppingList
//
//  Created by 加藤研太郎 on 2023/01/15.
//

import Combine
import UIKit

class ShoppingListViewController: UIViewController {
    @IBOutlet var appendButton: UIButton!
    @IBOutlet var favoriteButton: UIButton!
    @IBOutlet var shoppingListTableView: UITableView!
    @IBOutlet var deleteButton: UIButton!
    private var items: [Item] = []
    private var cancellable = Set<AnyCancellable>()
    private let viewModel: ShoppingListViewModel = .init(model: ShoppingListModel())
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Int, Item>
    private typealias DataSource = UITableViewDiffableDataSource<Int, Item>
    private var dataSource: DataSource?
    private let identifier = "ShoppingListCell"

    override func viewDidLoad() {
        super.viewDidLoad()
        shoppingListTableView.delegate = self
        self.reload()
        setupBinder()
        appendButton.addAction(.init(handler: { _ in
            self.performSegue(withIdentifier: "ToAppendView", sender: nil)
        }), for: .touchUpInside)
        deleteButton.addAction(.init(handler: { _ in
            self.viewModel.didTapDeleteButton()
        }), for: .touchUpInside)
        favoriteButton.addAction(.init(handler: { _ in
            self.viewModel.didTapFavoriteButton()
        }), for: .touchUpInside)

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.viewModel.reload(shoppingListTableView)
    }
}

extension ShoppingListViewController: UITableViewDelegate { // , UITableViewDataSource
    func tableView(_: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: "削除") { _, _, hander in
            self.viewModel.deleteAction(indexPath.row)
            self.viewModel.fetchArray(self.viewModel.stateOfTableView ?? .normal)
            hander(true)
        }
        let configuration = UISwipeActionsConfiguration(actions: [delete])
        if viewModel.stateOfTableView == .delete {
            configuration.performsFirstActionWithFullSwipe = true
            return configuration
        } else {
            return UISwipeActionsConfiguration()
        }
    }
}

extension ShoppingListViewController {
    private func setupBinder() {
        // viewModelのPublishedをsinkで監視購読し実行
        viewModel.$items.sink { [weak self] items in
            self?.items = items
        }.store(in: &cancellable)
        viewModel.$state
            .dropFirst() // ()内の数までの要素をパブリッシュ化から除外
            .receive(on: DispatchQueue.main)// スケジューラー、ここでいつどこで処理するか決定
            .sink { [weak self] state in
                guard let state = state else { return }
                switch state {
                case .loading:
                    print("state = loading")
                case .loaded:
//                     self?.viewModel.fetchArray(self?.viewModel.stateOfTableView ?? .normal)
                    self?.setButtonImage()
                    self?.apply()
                    print("state = loaded")
                    print(self!.items)
                case let .error(message):
                    self?.showErrorMessageIfNeeded(message)
                    print("state = error")
                }
            }.store(in: &cancellable) //
        viewModel.$stateOfTableView
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] stateOfTableView in
                guard let stateOfTableView = stateOfTableView else {return}
                    switch stateOfTableView {
                    case .normal:
                        self?.setButtonImage()
                        print("normal")
//                        self?.shoppingListTableView.reloadData()
                    case .favorite:
                        self?.setButtonImage()
                        print("favorite")
//                        self?.shoppingListTableView.reloadData()
                    case .delete:
                        self?.setButtonImage()
                        print("delete")
                    }
            }.store(in: &cancellable)
        Task {
//            self.viewModel.setInitialLoadedView()
            self.apply()
//            self.viewModel.reload(shoppingListTableView)
        }
    }

    private func reload() {
        shoppingListTableView.reloadData()
    }

    private func showErrorMessageIfNeeded(_ message: String) {
        let alert = UIAlertController(title: "エラー", message: message, preferredStyle: .alert)
        alert.addAction(.init(title: "閉じる", style: .default))
        present(alert, animated: true)
    }

    private func apply() {
        var snapShot = Snapshot()
        snapShot.appendSections([0])
            snapShot.appendItems(viewModel.items, toSection: 0)
        dataSource?.defaultRowAnimation = .fade
        if let dataSource {
            dataSource.apply(snapShot, animatingDifferences: true)
        } else {
            dataSource = DataSource(
                tableView: shoppingListTableView,
                cellProvider: { [weak self] tableView, indexPath, item in
                    self?.returnCell(tableView, at: indexPath, item)
                }
            )
            dataSource?.applySnapshotUsingReloadData(snapShot)
        }
    }

    private func returnCell(_ tableView: UITableView, at indexPath: IndexPath, _: Item) -> UITableViewCell {
        let identifier = "ShoppingListCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? ShoppingListCell else {return UITableViewCell()}
        //
        cell.nameLabel.text = self.items[indexPath.row].itemName
        cell.nameLabel.attributedText = self.viewModel.writeStrikeThroughLine(self.items[indexPath.row].isBought, (cell.nameLabel.text)!)

        cell.setIsBoughtImage(self.items[indexPath.row].isBought)
        cell.setIsFavoriteImage(self.items[indexPath.row].isFavorited)
        cell.isBoughtButton.addAction(.init(handler: { _ in
            //
            guard let text =  cell.nameLabel.text else {return}
            //
            self.viewModel.didTapIsBought(indexPath.row)
            cell.setIsBoughtImage(self.items[indexPath.row].isBought)
            cell.nameLabel.attributedText = self.viewModel.writeStrikeThroughLine(self.items[indexPath.row].isBought, text)
//            print("状態：\(cell?.nameLabel.attributedText)")
        }), for: .touchUpInside)
        cell.isFavoriteButton.addAction(.init(handler: { _ in
            self.viewModel.didTapIsFavorite(indexPath.row)
            cell.setIsFavoriteImage(self.items[indexPath.row].isFavorited)

        }), for: .touchUpInside)
//        cell.didTapIsFavorite = self.viewModel.didTapIsFaborite2(indexPath.row)

        return cell
    }

    private func setButtonImage() {
        if viewModel.stateOfTableView  == .normal {
            favoriteButton.setImage(UIImage(systemName: "star"), for: .normal)
            favoriteButton.tintColor = .tintColor
            deleteButton.tintColor = .tintColor
        } else if viewModel.stateOfTableView == .favorite {
            favoriteButton.setImage(UIImage(systemName: "star.fill"), for: .normal)
            favoriteButton.tintColor = .yellow
            deleteButton.tintColor = .tintColor
        } else if viewModel.stateOfTableView == .delete {
            favoriteButton.setImage(UIImage(systemName: "star"), for: .normal)
            favoriteButton.tintColor = .tintColor
            deleteButton.tintColor = .red
        }
    }
}
