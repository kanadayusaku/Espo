//
//  ViewController.swift
//  Espo
//
//  Created by 金田祐作 on 2019/08/23.
//  Copyright © 2019 金田祐作. All rights reserved.
//

import UIKit
import FirebaseFirestore


class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,UIImagePickerControllerDelegate, UINavigationControllerDelegate

{
    // Firestoreのインスタンス化
    let db = Firestore.firestore()

    //リフレッシュのインスタンス化
    let refreshControl = UIRefreshControl()
    // 投稿情報を全て格納
    var items = [NSDictionary]()

    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self

        // refreshControlに文言を追加
        refreshControl.attributedTitle = NSAttributedString(string: "更新中")
        // アクションを指定
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        // tableViewに追加
        tableView.addSubview(refreshControl)
       //メソッド呼び出し
        fetch()
        // リロード
        tableView.reloadData()
    }

    // 更新
    @objc func refresh() {
        // 初期化
        items = [NSDictionary]()
        // 情報を取得
        fetch()
        // tableViewをリロード
        tableView.reloadData()
        // リフレッシュを止める
        refreshControl.endRefreshing()
    }

    // データの取得
    func fetch() {
        // getで全件取得
        db.collection("user").getDocuments() {(querySnapshot, err) in
            // tempItemsという変数を一時的に作成
            var tempItems = [NSDictionary]()
            // for文で回し`item`に格納
            for item in querySnapshot!.documents {
                // item内のデータをdictという変数に入れる
                let dict = item.data()
                // dictをtempItemsに入れる
                tempItems.append(dict as NSDictionary)
            }
            // tempItemsをitems(クラスの変数として定義した)に入れる
            self.items = tempItems
            // リロード
            self.tableView.reloadData()
        }
    }


    // カメラを開くボタン
    @IBAction func openCamera(_ sender: Any) {
        cameraAction(sourceType: .camera)
    }

    // アルバムボタン
    @IBAction func openPhotos(_ sender: Any) {
        cameraAction(sourceType: .photoLibrary)
    }

     // プロフィールボタン
    @IBAction func profile(_ sender: Any) {
        // 対象のstoryboardファイルを選択
        let storyboard: UIStoryboard = UIStoryboard(name: "Profile", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "Profile")
        // 遷移処理
        self.present(vc, animated: true)
    }

    // セルの数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    // セルの設定
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        // 選択不可にする
        cell.selectionStyle = .none

        // itemsの中からindexpathのrow番目を取得
        let dict = items[(indexPath as NSIndexPath).row]

        // 表示情報は４つ。①プロフィール情報、②ユーザー名、③投稿画像、④コメント

        // ①プロフィール画像
        print(type(of: cell.viewWithTag(1)))
        let profileImageView = cell.viewWithTag(1) as! UIImageView
        // 画像情報
        let profImage = dict["profileImage"]
        // NSData型に変換
        let dataProfImage = NSData(base64Encoded: profImage as! String, options: .ignoreUnknownCharacters)
        // さらにUIImage型に変換
        let decadedProfImage = UIImage(data: dataProfImage! as Data)
        // profileImageViewへ代入
        profileImageView.image = decadedProfImage

        // ②ユーザー名
        let userNameLabel = cell.viewWithTag(2) as! UILabel
        userNameLabel.text = dict["userName"] as? String

        // ③投稿画像
        let postImageView = cell.viewWithTag(3) as! UIImageView
        // 画像情報
        let postImage = dict["postImage"]
        // NSData型に変換
        let dataPostImage = NSData(base64Encoded: postImage as! String, options: .ignoreUnknownCharacters)
        // さらにUIImage型に変換
        let decadedPostImage = UIImage(data: dataPostImage! as Data)
        // postImageViewへ代入
        postImageView.image = decadedPostImage

        // ④コメント
        let commentTextView = cell.viewWithTag(4) as! UITextView
        commentTextView.text = dict["comment"] as? String
        print(commentTextView)
        print(cell)


        // ファボボタン
        let favButton = cell.viewWithTag(5) as! UIButton
/*
        let favNumber = dict["favNumber"] ?? 0
        print(favNumber)
*/
        favButton.setTitle("☆", for: .normal)
        favButton.addTarget(self, action: #selector(pushFavButton(_:)), for: UIControl.Event.touchUpInside)

        return cell
    }

    // カメラ・フォトライブラリへの遷移処理
    func cameraAction(sourceType: UIImagePickerController.SourceType) {
        // カメラ・フォトライブラリが使用可能かチェック
        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
            // インスタンス化
            let cameraPicker = UIImagePickerController()
            // ソースタイプの代入
            cameraPicker.sourceType = sourceType
            // デリゲートの接続
            cameraPicker.delegate = self
            // 画面遷移
            self.present(cameraPicker, animated: true)
        }
    }

    // 写真が選択された時に呼ばれる
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // 取得できた画像情報の存在確認とUIImage型へキャスト。pickedImageという定数に格納
        if let pickedImage = info[.originalImage] as? UIImage {
            // 投稿画面への遷移処理
            let storyboard: UIStoryboard = UIStoryboard(name: "Post", bundle: nil)
            guard let vc = storyboard.instantiateViewController(withIdentifier: "Post") as? PostViewController else {
                print("投稿画面への遷移失敗")
                return
            }
            // 画像の受け渡し
            vc.willPostImage = pickedImage
            // 画面遷移
            picker.pushViewController(vc, animated: true)
        }
    }

   //ファボボタンを追加
    @objc func pushFavButton(_ sender: UIButton) {
        sender.setTitle("★", for: .normal)
    }
}


