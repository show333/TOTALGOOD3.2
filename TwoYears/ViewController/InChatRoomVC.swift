//
//  InChatRoomVC.swift
//  TOTALGOOD
//
//  Created by 平田翔大 on 2021/12/08.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import SwiftMoment

class InChatRoomVC:UIViewController{
    
    
    
    @IBOutlet weak var inChatTableView: UITableView!
    
    private let cellId = "cellId"
    
    private let accessoryHeight: CGFloat = 90
    private var safeAreaBottom: CGFloat {
        self.view.safeAreaInsets.bottom
    }
    private lazy var chatInputAccessoryView: ChatInputAccessoryView = {
        let view = ChatInputAccessoryView()
        view.frame = .init(x: 0, y: 0, width: view.frame.width, height: 10000)
        view.delegate = self
        return view
    }()
    
    @IBAction func button(_ sender: Any) {
        chatInputAccessoryView.alpha = 1
        chatInputAccessoryView.chatTextView.becomeFirstResponder()
        print("a")
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        setupNotification()
        chatInputAccessoryView.alpha = 0
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        

        inChatTableView.delegate = self
        inChatTableView.dataSource = self
        inChatTableView.register(UINib(nibName: "ChatRoomTableViewCell", bundle: nil), forCellReuseIdentifier: cellId)
        
        inChatTableView.keyboardDismissMode = .interactive

    }
    
    @objc public func dismissKeyboard() {
        view.endEditing(true)
    }
    private func setupNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    @objc func keyboardWillShow(notification: NSNotification) {
        print("keyboardWillShow")
        
        guard let userInfo = notification.userInfo else { return }
        if let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue {
            if keyboardFrame.height <= accessoryHeight { return }
            let top = keyboardFrame.height - safeAreaBottom - 48
            let bottom = inChatTableView.contentOffset.y
            let moveY =  inChatTableView.contentOffset.y
            print(bottom)
            let contentInset = UIEdgeInsets(top: 0, left: 0, bottom: top, right: 0)
            inChatTableView.contentInset = contentInset
            inChatTableView.scrollIndicatorInsets = contentInset
            inChatTableView.contentOffset = CGPoint(x: 0, y: moveY + top)
        }
    }
    @objc func keyboardWillHide() {
        print("keyboardWillHide")
        self.tabBarController?.tabBar.isHidden = false
        inputAccessoryView?.alpha = 0
        inChatTableView.contentInset = .init(top: 0, left: 0, bottom: 0, right: 0)
        inChatTableView.scrollIndicatorInsets = .init(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    override var inputAccessoryView: UIView? {
        get {
            return chatInputAccessoryView
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
}



extension InChatRoomVC:UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = inChatTableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! ChatRoomTableViewCell
        cell.messageLabel.text = "a"
        return cell
    }
}
extension InChatRoomVC: ChatInputAccessoryViewDelegate{
    func tappedSendButton(text: String) {
        addMessageToFirestore(text: text)
    }
    private func addMessageToFirestore(text: String) {
        chatInputAccessoryView.removeText()
        func randomString(length: Int) -> String {
            let characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
            return String((0..<length).map{ _ in characters.randomElement()! })
        }
//
//        let randomUserId = randomString(length: 8)
//        let chatRoomDocId = dragons!.documentId
//        let userteamname = dragons!.userteamname
//        guard let uid = Auth.auth().currentUser?.uid else { return }
//        func comment(randomuserId: String,commentId: String) {
//            let docData = [
//                "createdAt": FieldValue.serverTimestamp(),
//                "message": text,
//                "userId": uid,
//                "documentId": chatRoomDocId,
//                "comentId" : commentId,
//                "admin": false,
//                "randomUserId": randomuserId,
//                "userBrands": userMyBrands!,
//                "sendImageURL": "",
//                "teamname": userteamname,
//            ] as [String: Any]
//
//            DB.document(chatRoomDocId).collection("messages").document(commentId).setData(docData) { (err) in
//                if let err = err {
//                    print("メッセージ情報の保存に失敗しました。ss\(err)")
//                    return
//                }
//                print("成功！")
        //            }
        //        }
        //
        //
        //        self.DB.document(chatRoomDocId).collection("messages").whereField("userId", isEqualTo: uid).getDocuments() { [self] (querySnapshot, err) in
        //            if let err = err {
        //                print("Error getting documents: \(err)")
        //            } else {
        //                print("クエリースナップショットカウント！",querySnapshot!.documents.count)
        //                if querySnapshot!.documents.count == 0 {
        //                    let commentId = uid+"comentId"
        //                    comment(randomuserId: "",commentId: commentId)
        //                    DB.document(chatRoomDocId).collection("members").document(uid).setData(["randomUserId": randomUserId], merge: true)
        //                    DB.document(chatRoomDocId).setData([uid: true], merge: true)
        //                    Firestore.firestore().collection("users").document(uid).setData(["The_earliest":true], merge: true)
        //                } else if querySnapshot!.documents.count == 1 {
        //                    print("ln")
        //                    DB.document(chatRoomDocId).collection("members").document(uid).getDocument { (document, error) in
        //                        if let document = document, document.exists {
        //                            let randomUserId = document["randomUserId"] as? String ?? "unknown"
        //
        //                            print(randomUserId,"aaaaaaaaa")
        //                            print("aaaa")
        //                            let comentId = randomString(length: 15)
        //                            comment(randomuserId: randomUserId, commentId: comentId)
        //                            DB.document(chatRoomDocId).collection("messages").document(uid+"comentId").updateData(["randomUserId":randomUserId])
        //                        }
        //                    }
        //                } else if querySnapshot!.documents.count >= 2 {
        //
        //                    DB.document(chatRoomDocId).collection("members").document(uid).getDocument { (document, error) in
        //                        if let document = document, document.exists {
        //                            let randomUserId = document["randomUserId"] as? String ?? "unknown"
        //
        //                            let comentId = randomString(length: 15)
        //                            comment(randomuserId: randomUserId, commentId: comentId)
        //                        }
        //                    }
        //                }
        //            }
        //            self.DB.document(chatRoomDocId).setData(["createdLatestAt": FieldValue.serverTimestamp()],merge: true)
        //            self.DB.document(chatRoomDocId).updateData(["messagecount": FieldValue.increment(Int64(1))])
//        }
    }
}

extension UIView {
    func InChatRoomVC() -> UIViewController? {
        var ChatRoomtableViewResponder: UIResponder? = self
        while true {
            guard let ChatRoomtableViewCellResponder = ChatRoomtableViewResponder?.next else { return nil }
            if let viewController = ChatRoomtableViewCellResponder as? UIViewController {
                return viewController
            }
            ChatRoomtableViewResponder = ChatRoomtableViewCellResponder
        }
    }
    func InChatRoomVC<T: UIView>(type: T.Type) -> T? {
        var ChatRoomTableViewResponder: UIResponder? = self
        while true {
            guard let ChatRoomTableViewCellResponder = ChatRoomTableViewResponder?.next else { return nil }
            if let view = ChatRoomTableViewCellResponder as? T {
                return view
            }
            ChatRoomTableViewResponder = ChatRoomTableViewCellResponder
        }
    }
}
