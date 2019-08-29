//
//  profileViewController.swift
//  Espo
//
//  Created by 金田祐作 on 2019/08/26.
//  Copyright © 2019 金田祐作. All rights reserved.
//

import UIKit
import FirebaseAuth

class profileViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    //プロフィール画像
    @IBOutlet weak var profileImageView: UIImageView!
    //名前投稿用テキストフィールド
    @IBOutlet weak var userNameTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        getProfile()
    }

    // ローカルで持っているprofile情報を反映
    func getProfile() {
        // 画像情報
        if let profImage = UserDefaults.standard.object(forKey: "profileImage") {
            // NSData型に変換
            let dataImage = NSData(base64Encoded: profImage as! String, options: .ignoreUnknownCharacters)
            // さらにUIImage型に変換
            let decodedImage = UIImage(data: dataImage! as Data)
            // profileImageViewに代入
            profileImageView.image = decodedImage
        } else {
            // なければアイコン画像をいれておく
            profileImageView.image = #imageLiteral(resourceName: "人物アイコン")
        }
        // 名前情報
        if let profName = UserDefaults.standard.object(forKey: "userName") as? String {
            // userNameTextFieldへ代入
            userNameTextField.text = profName
        } else {
            // なければ匿名としておく
            userNameTextField.text = "名無しさん"
        }
    }


    // プロフィール写真変更用のアクションシート
    @IBAction func changeProfPhoto(_ sender: Any) {
        //アクションシートを定義
        let alert = UIAlertController(title: "選択してください", message: nil, preferredStyle: .actionSheet)

       // カメラ機能
        let openCamera = UIAlertAction(title: "カメラ", style: .default, handler: {(action: UIAlertAction) in
        })

       //アルバム
        let openPhotos = UIAlertAction(title: "アルバム", style: .default, handler: {(action: UIAlertAction) in self.cameraAction(sourceType: .photoLibrary)
        })
      //キャンセル
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel)
        // アラートの追加
        alert.addAction(openCamera)
        alert.addAction(openPhotos)
        alert.addAction(cancelAction)
        // 表示
        present(alert, animated: true)
    }

    // カメラ・フォトライブラリへの遷移処理
    func cameraAction(sourceType: UIImagePickerController.SourceType) {
        // カメラ・フォトライブラリが使用可能かチェック
        if UIImagePickerController.isSourceTypeAvailable(sourceType) {

            // インスタンス作成
            let cameraPicker = UIImagePickerController()
            // ソースタイプの代入
            cameraPicker.sourceType = sourceType
            // デリゲートの接続
            cameraPicker.delegate = self
            // 画面遷移
            self.present(cameraPicker, animated: true)
        }
    }

    // 画像が選択された時に呼ばれる
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // 所得できた画像情報の存在確認
        if let pickedImage = info[.originalImage] as? UIImage {
            profileImageView.contentMode = .scaleToFill
            profileImageView.image = pickedImage
        }
        // pickerは閉じる
        picker.dismiss(animated: true)
    }

    //決定
    @IBAction func save(_ sender: Any) {
        var data: NSData = NSData()
        // imageの存在確認
        if let image = profileImageView.image {
            // クオリティを10パーセントに下げる
            data = image.jpegData(compressionQuality: 0.1)! as NSData
        }
        let base64String = data.base64EncodedString(options: .lineLength64Characters) as String

        let userName = userNameTextField.text

        // アプリ内に保存
        // プロフ画像
        UserDefaults.standard.set(base64String, forKey: "profileImage")
        // ユーザー名
        UserDefaults.standard.set(userName, forKey: "userName")
        // 遷移
        dismiss(animated: true)
    }

    // ログアウト処理
    @IBAction func logOut(_ sender: Any) {
        // ログアウト処理
        try! Auth.auth().signOut()
        // storyboardのfileの特定
        let storyboard: UIStoryboard = UIStoryboard(name: "Login", bundle: nil)
        // 移動先のvcをインスタンス化
        let vc = storyboard.instantiateViewController(withIdentifier: "Login")
        // 遷移処理
        self.present(vc, animated: true)
    }
    // キーボードを閉じる処理
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if userNameTextField.isFirstResponder {
            userNameTextField.resignFirstResponder()
        }
    }
}
