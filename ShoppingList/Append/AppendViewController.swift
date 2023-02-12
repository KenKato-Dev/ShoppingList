//
//  AppendViewController.swift
//  ShoppingList
//
//  Created by 加藤研太郎 on 2023/01/28.
//

import Combine
import UIKit

final class AppendViewController: UIViewController {
    @IBOutlet var appendButton: UIButton!
    @IBOutlet var addCellButton: UIButton!
    @IBOutlet var memoTable: UITableView!
    @IBOutlet var cancelButton: UIButton!
    private var cancellable = Set<AnyCancellable>()
    private let viewModel: AppendViewModel = .init(model: ShoppingListModel())
    private var count: Int = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        memoTable.delegate = self
        memoTable.dataSource = self
        memoTable.reloadData()
        binder()
        addCellButton.addAction(.init(handler: { _ in
            self.viewModel.didTapAddCellButton()
            self.memoTable.reloadData()
        }), for: .touchUpInside)
        appendButton.addAction(.init(handler: { _ in
            self.viewModel.didTapAppendButton()
        }), for: .touchUpInside)
        cancelButton.addAction(.init(handler: { _ in
            self.dismiss(animated: true)
        }), for: .touchUpInside)
    }

    override func touchesBegan(_: Set<UITouch>, with _: UIEvent?) {
        view.endEditing(true)
    }

    private func binder() {
        viewModel.$count.sink { [weak self] count in
            self?.count = count
        }.store(in: &cancellable)
        viewModel.$state
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                guard let state = state else { return }
                switch state {
                case .appended:
                    print("ポストに成功")
                    self?.dismiss(animated: true)
                case .error:
                    print("error発生")
                case .tappedFull:
                    print("上限です")
                }
            }.store(in: &cancellable)
    }
}

extension AppendViewController: UITextFieldDelegate {
    internal func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension AppendViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MemoListCell", for: indexPath) as? AppendTableViewCell
        cell?.listTextField.delegate = self
        cell?.fillInText(viewModel.array[indexPath.row])
        cell?.didEditingEnd = {
            guard let text = cell?.listTextField.text else { return }
            self.viewModel.didEditTextField(indexPath.row, text)
            self.memoTable.reloadData()
            print(indexPath.row)
        }
        return cell!
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as? AppendTableViewCell
        tableView.deselectRow(at: indexPath, animated: false)
        cell?.listTextField.becomeFirstResponder()
    }
}
