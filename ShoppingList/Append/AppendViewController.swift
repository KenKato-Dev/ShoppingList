//
//  AppendViewController.swift
//  ShoppingList
//
//  Created by 加藤研太郎 on 2023/01/28.
//

import UIKit
import Combine

final class AppendViewController: UIViewController {
    @IBOutlet weak var appendButton: UIButton!
    @IBOutlet weak var addCellButton: UIButton!
    @IBOutlet weak var memoTable: UITableView!
    @IBOutlet weak var cancelButton: UIButton!
    private var cancellable = Set<AnyCancellable>()
    private let viewModel: AppendViewModel = AppendViewModel(model: ShoppingListModel())
    private var count: Int = 0
    private var array: [String]?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.memoTable.delegate = self
        self.memoTable.dataSource = self
        self.memoTable.reloadData()
        self.binder()
        self.addCellButton.addAction(.init(handler: { _ in
            self.viewModel.didTapAddCellButton()
            self.memoTable.reloadData()
        }), for: .touchUpInside)
        self.appendButton.addAction(.init(handler: { _ in
            self.viewModel.didTapAppendButton()
        }), for: .touchUpInside)
        self.cancelButton.addAction(.init(handler: { _ in
            self.dismiss(animated: true)
        }), for: .touchUpInside)
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    private func binder() {
        self.viewModel.$count.sink { [weak self] count in
            self?.count = count ?? 0
        }.store(in: &cancellable)
        self.viewModel.$array.sink { [weak self] array in
            self?.array = array
        }.store(in: &cancellable)
        self.viewModel.$state
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                guard let state = state else {return}
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

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MemoListCell", for: indexPath) as? AppendTableViewCell
        cell?.listTextField.delegate = self
        guard array!.count > 0 else {return cell!}
        if self.array?[indexPath.row] != nil {
            cell?.fillInText(self.array![indexPath.row])
        }
        return cell!
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 選択時にキーボードを上げる
        let cell = tableView.cellForRow(at: indexPath) as? AppendTableViewCell
        tableView.deselectRow(at: indexPath, animated: false)
        cell?.listTextField.addAction(.init(handler: { _ in
            guard let text = cell?.listTextField.text else {return}
            self.viewModel.didEditTextField(indexPath.row, text)
            self.memoTable.reloadData()
            print(indexPath.row)
        }), for: .editingDidEnd)
        cell?.listTextField.becomeFirstResponder()
    }
}
