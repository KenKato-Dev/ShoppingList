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
    private var array: [Item] = []
    private var cancellable = Set<AnyCancellable>()
    private let viewModel: ShoppingListViewModel = .init(model: ShoppingListModel())
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Int, Item>
    private typealias DataSource = UITableViewDiffableDataSource<Int, Item>
    private var dataSource: DataSource?

    override func viewDidLoad() {
        super.viewDidLoad()
        shoppingListTableView.delegate = self
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
        viewModel.fetchArray()
    }
}

extension ShoppingListViewController: UITextFieldDelegate {}

extension ShoppingListViewController: UITableViewDelegate { // , UITableViewDataSource

    func tableView(_: UITableView, didSelectRowAt _: IndexPath) {
    }

    func tableView(_: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: "削除") { _, _, hander in
            self.viewModel.deleteAction(indexPath.row)
            self.viewModel.fetchArray()
            hander(true)
        }
        let configuration = UISwipeActionsConfiguration(actions: [delete])
        if viewModel.state == .delete {
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
        viewModel.$items.sink { [weak self] array in
            self?.array = array
        }.store(in: &cancellable)

        viewModel.$state
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                guard let state = state else { return }
                switch state {
                case .loaded:
                    self?.viewModel.fetchArray()
                    self?.setButtonImage()
                    self?.apply()
                    print("state = loaded")
                case let .error(message):
                    self?.showErrorMessageIfNeeded(message)
                    print("state = error")
                case .favorite:
                    // favorite表示

                    self?.setButtonImage()
                    self?.apply()
                    print("state = favorite")
                case .delete:
                    // deleteモード
                    self?.setButtonImage()
                    self?.deleteButton.tintColor = .red
                    self?.apply()
                    print("state = delete")
                }
            }.store(in: &cancellable)
        Task {
            self.viewModel.setInitialLoadedView()
            print(self.viewModel.state)
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
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? ShoppingListCell
        var item = viewModel.items[indexPath.row]
        cell?.nameLabel.text = item.itemName
        cell?.isBoughtButton.addAction(.init(handler: { _ in
            self.viewModel.didTapIsBought(&item.isBought)
            cell?.setIsBoughtImage(item.isBought)
        }), for: .touchUpInside)
        cell?.isFavoriteButton.addAction(.init(handler: { _ in
            self.viewModel.didTapIsFavorite(&item.isFavorited)
            cell?.setIsFavoriteImage(item.isFavorited)
        }), for: .touchUpInside)
        return cell!
    }

    private func setButtonImage() {
        if viewModel.state == .loaded {
            favoriteButton.setImage(UIImage(systemName: "star"), for: .normal)
            favoriteButton.tintColor = .tintColor
            deleteButton.tintColor = .tintColor
        } else if viewModel.state == .favorite {
            favoriteButton.setImage(UIImage(systemName: "star.fill"), for: .normal)
            favoriteButton.tintColor = .yellow
            deleteButton.tintColor = .tintColor
        } else if viewModel.state == .delete {
            favoriteButton.setImage(UIImage(systemName: "star"), for: .normal)
            favoriteButton.tintColor = .tintColor
            deleteButton.tintColor = .red
        }
    }
}
