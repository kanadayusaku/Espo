//
//  PostViewController.swift
//  Espo
//
//  Created by 金田祐作 on 2019/08/26.
//  Copyright © 2019 金田祐作. All rights reserved.
//

import UIKit
import FirebaseFirestore

class PostViewController: UIViewController {

    // Firestoreのインスタンス化
    let db = Firestore.firestore()

    // pickerで選択した写真を受け取る変数
    var willPostImage: UIImage = UIImage()

    //プロフィール写真
    @IBOutlet weak var profileImageView: UIImageView!
    //プロフィール名
    @IBOutlet weak var profileNameLabel: UILabel!
   //コメント
    @IBOutlet weak var commentTextView: UITextView!
    //投稿用写真
    @IBOutlet weak var postImageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad() // pickerで選択した画像を投稿用写真へ反映
        postImageView.image = willPostImage
        getProfile()
    }


    //投稿
    @IBAction func postAll(_ sender: Any) {
        // ①各情報を定数化
        // 投稿する情報は４つ。名前・コメント・投稿画像・プロフィール画像
        // 名前
        let userName = profileNameLabel.text
        // コメント
        let comment = commentTextView.text

        // 投稿画像
        var postImageData: NSData = NSData()
        if let postImage = postImageView.image {
            // クオリティを10パーセントに下げる
            postImageData = postImage.jpegData(compressionQuality: 0.1)! as NSData
        }
        // 送信するためにbase64Stringという形式に変換
        let base64PostImage = postImageData.base64EncodedString(options: .lineLength64Characters) as String
        // プロフィール画像
        var profileImageData: NSData = NSData()
        if let profileImage = profileImageView.image {
            profileImageData = profileImage.jpegData(compressionQuality: 0.1)! as NSData
        }
     let base64ProfileImage = profileImageData.base64EncodedString(options: .lineLength64Characters) as String

        // ②Firestoreに飛ばす箱を用意
        let user: NSDictionary = ["userName": userName ?? "" , "comment": comment ?? "", "postImage": base64PostImage, "profileImage": base64ProfileImage]

        // ③userごとFirestoreへpost
        db.collection("user").addDocument(data: user as! [String : Any])

        // ④画面を消す
        self.dismiss(animated: true)
          }

    // キーボードを閉じる処理
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if commentTextView.isFirstResponder {
            commentTextView.resignFirstResponder()
        }
    }


    // ローカルで持っているprofile情報を反映
    func getProfile() {
        // 画像情報があればprofImageに格納
        if let profImage = UserDefaults.standard.object(forKey: "profileImage") {
            // あればprofImageを投稿用のprofImageViewに格納
            // NSData型に変換
            let dataImage = NSData(base64Encoded: profImage as! String, options: .ignoreUnknownCharacters)
            // さらにUIImage型に変換
            let decodedImage = UIImage(data: dataImage! as Data)
            // profileImageViewに代入
            profileImageView.image = decodedImage

        } else {
            // なければアイコン画像をprofImageViewに格納

            profileImageView.image = #imageLiteral(resourceName: "人物アイコン") // (resourceName: "人物アイコン")
        }



        // 名前情報があればprofNameに格納
        if let profName = UserDefaults.standard.object(forKey: "userName") as? String {
            // profileNameLabelへ代入
            profileNameLabel.text = profName
        } else {
            // なければ匿名としておく
            profileNameLabel.text = "名無しさん"
        }
    }
}
