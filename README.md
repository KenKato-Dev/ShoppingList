# 買い物メモアプリ「ShoppingList」
買い物メモアプリ「ShoppingList」はSwiftのみで構成されたサンプルアプリです。MVVMアーキテクチャで構成しており、フレームワークにCombineを用いて非常に簡易ではありますがリアクティブプログラミングを意識して作成しました。  
## 導入
下記コマンドを任意のディレクトリから実行してください。
```  
$ git clone https://github.com/KenKato-Dev/ShoppingList  
  
$ cd ShoppingList  
```  
2. 移動したディレクトリにあるRefmanager1-2.xcodeprojを開いてください。  
3. Xcodeからアプリを実行してください。  
4. Build PhaseにてSwiftLintを実行しており、エラーを起こすことがあります。その際は削除し再度Runを実行してミュレータにて動きをご確認ください。  
## 構成
- MVVM
- Combine

MVVM：  
設計パターンはMVVMを採用しております。構成としては各画面のViewControllerとViewModelを用意し、Modelは共通としています。それぞれの役割は以下の通りです。  
  - ViewController：ViewModelから返された値やイベントをもとに描画処理を担当
  - ViewModel：Viewに表示するデータの保持とViewからの入力やタップなどのイベントを加工を担当  
  - Model：ViewModelからの処理移譲など必要に応じてAPIへのリクエストやfetch、postを実行、UIや画面表示に依存せずロジックを一元管理  
  MVVMパターンの採用は相性が良いとされているRPにて入力等UIイベントをストリームにて管理しやすくなり、慣れると非常に書きやすく明瞭なコードになる設計パターンではと感じております。  
  
Combine：  
Combineフレームワークは用いることで非同期なイベントをストリームにて管理できRxSwiftのようにリアクティブなコードを書ける純正フレームワークと理解しています。  
本サンプルではボタンタップによる描写の変更などで使用しておりますが、持っている機能のごく一部しか使えておらずもっと使いこなせるよう今後も取り組みます。  
## 工夫した点
MVVMパターン＋Combineによる基礎的なストリーム管理：Viewの情報とデータ読み込み状況をEnumにてケース分けし、登録情報とともにこれらを監視しつつ変動があり次第Viewへの描写に反映させるよう記述することでMVVMパターンの書き方やCombineを用いたストリームの基礎的な理解に努めました。  
UITableViewDiffableDataSourceを用いたセル制御：これまで利用していたUITableView Datasourceではなく本クラスを用いることでセルの描写やお気に入り登録情報のみ抽出表示等の際に全体をリロードさせず更新が必要なCell毎に更新表示させることで、コードの記述量の減少やアニメーションの利用など本クラスの特徴や使い方の理解を深めることにつながりました。
