//
//  LoginViewController.swift
//  Espo
//
//  Created by 金田祐作 on 2019/08/23.
//  Copyright © 2019 金田祐作. All rights reserved.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    //eメールアドレス入力
    @IBOutlet weak var email: UITextField!
    //パスワード入力
    @IBOutlet weak var password: UITextField!
    //新規アカウント登録
    @IBAction func registAccount(_ sender: Any) {
        guard let email = email.text, let password = password.text else {
       // 省略
            return
        }
        // 以下追加
        // エラーがnilでない=エラーが発生しているとき
        // 新規アカウント作成
        Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
            if let error = error {
                // エラー時の処理
            // エラーアラートの表示
            self.showErrorAlert(error: error)
            } else {
                // 成功した場合の処理
                print("新規作成成功")
                // タイムラインへ遷移
                self.toTimeLine()
            }
        })
    }
    //ログインボタン
    @IBAction func loginButton(_ sender: Any) {
        guard let email = email.text, let password = password.text else {
            return
    }
        // FirebaseAuthのログイン処理
        Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
            if let error = error {
                print("ログイン失敗")
                // エラーアラートの表示
                self.showErrorAlert(error: error)
            } else {
                // 認証成功
                print("ログイン成功")
                // タイムラインへ遷移
                self.toTimeLine()
            }
        })
    }

    // エラーが返ってきた場合のアラート
    func showErrorAlert(error: Error?) {
        let alert = UIAlertController(title: "エラー", message: error?.localizedDescription, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .cancel)
        alert.addAction(okAction)
        // 表示
        self.present(alert, animated: true)
    }

    // タイムラインへ遷移
    func toTimeLine() {
        // storyboardのfileの特定
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        // 移動先のvcをインスタンス化(ここの"Main"はStoryboardId。"Main"は起動時に設定されています。)
        let vc = storyboard.instantiateViewController(withIdentifier: "Main")
        // 遷移処理
        self.present(vc, animated: true)
        
    }
    // キーボードを閉じる処理
    // タッチされたかを判断
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // キーボードが開いていたら
        if (email.isFirstResponder) {
            // 閉じる
            email.resignFirstResponder()
        }
        if (password.isFirstResponder) {
            password.resignFirstResponder()
        }
    }
}
