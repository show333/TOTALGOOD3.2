//
//  ReNewPostVC.swift
//  TOTALGOOD
//
//  Created by 平田翔大 on 2022/02/25.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import Nuke

class ReMemoPostVC:UIViewController {
    var postInfoTitle: String?
    var postInfoImage: String?
    var postInfoDoc:String?
    var userId: String?
    var userName: String?
    var userImage: String?
    var userFrontId: String?
    var hexColor:String?
    var fontName:String?
    var backHexColor:String?
    
    
    
    let db = Firestore.firestore()
    
    let textMask : Array = [
        "https://firebasestorage.googleapis.com/v0/b/totalgood-7b3a3.appspot.com/o/TextMask%2Fmouth1.001.png?alt=media&token=bae3c928-485e-464f-ac00-35a97e03d681",//1
        "https://firebasestorage.googleapis.com/v0/b/totalgood-7b3a3.appspot.com/o/TextMask%2Fmouth2.001.png?alt=media&token=8dab1e72-f1d7-4636-b203-37085b6a1a02",//2
        "https://firebasestorage.googleapis.com/v0/b/totalgood-7b3a3.appspot.com/o/TextMask%2Fmouth3.001.png?alt=media&token=453af75e-4578-4fbd-abe7-cc0686a694ee",//3
        "https://firebasestorage.googleapis.com/v0/b/totalgood-7b3a3.appspot.com/o/TextMask%2Fmouth4.001.png?alt=media&token=ffe5efc4-af99-423f-85e9-943c7ed00674",//4
        "https://firebasestorage.googleapis.com/v0/b/totalgood-7b3a3.appspot.com/o/TextMask%2Fmouth5.001.png?alt=media&token=79a71066-96fb-42d0-a6b9-88a9edaea762",//5
        "https://firebasestorage.googleapis.com/v0/b/totalgood-7b3a3.appspot.com/o/TextMask%2Fmouth6.001.png?alt=media&token=0a7254d8-01fd-4db0-82dd-573caecd3be7",//6
        "https://firebasestorage.googleapis.com/v0/b/totalgood-7b3a3.appspot.com/o/TextMask%2Fmouth7.001.png?alt=media&token=6ec61c57-c5f2-4182-b81f-1c94e5830c01",//7
        "https://firebasestorage.googleapis.com/v0/b/totalgood-7b3a3.appspot.com/o/TextMask%2Fmouth8.001.png?alt=media&token=894a2dc4-c3c8-4fe3-94c9-632a76921ad4",//8
        "https://firebasestorage.googleapis.com/v0/b/totalgood-7b3a3.appspot.com/o/TextMask%2Fmouth10.001.png?alt=media&token=bc4d5271-11b0-499b-ad1e-88788329d417",//10
        "https://firebasestorage.googleapis.com/v0/b/totalgood-7b3a3.appspot.com/o/TextMask%2Fmouth12.001.png?alt=media&token=5dd3e8a6-d265-4b1c-92ca-7de64c549de4",//12
        "https://firebasestorage.googleapis.com/v0/b/totalgood-7b3a3.appspot.com/o/TextMask%2Fmouth13.001.png?alt=media&token=a875740c-c522-4087-8b7e-1e4d03ee392c",//13
        "https://firebasestorage.googleapis.com/v0/b/totalgood-7b3a3.appspot.com/o/TextMask%2Fmouth14.001.png?alt=media&token=b73e6cb2-63f7-419a-bca9-4e79255c8cdf",//14
        "https://firebasestorage.googleapis.com/v0/b/totalgood-7b3a3.appspot.com/o/TextMask%2Fmouth15.001.png?alt=media&token=46d8f2b2-feaa-4c38-ad5b-cd7924cf88f7",//15
        "https://firebasestorage.googleapis.com/v0/b/totalgood-7b3a3.appspot.com/o/TextMask%2Fmouth16.001.png?alt=media&token=c5a3ea4a-59aa-41b4-9726-5453e19eca59",//16
        "https://firebasestorage.googleapis.com/v0/b/totalgood-7b3a3.appspot.com/o/TextMask%2Fmouth17.001.png?alt=media&token=486ad9c8-f4ac-441f-ab70-b43feff85d99",//17
        "https://firebasestorage.googleapis.com/v0/b/totalgood-7b3a3.appspot.com/o/TextMask%2Fmouth18.001.png?alt=media&token=b4a4525b-38ee-4842-a191-3fb49ec3b8e0",//18
        "https://firebasestorage.googleapis.com/v0/b/totalgood-7b3a3.appspot.com/o/TextMask%2Fmouth20.001.png?alt=media&token=e0693059-4e99-4378-a5cf-1b19854f30e0",//20
    ]
    
    
    @IBOutlet weak var wordCountLabel: UILabel!
    @IBOutlet weak var sendButton: UIButton!
    
    @IBAction func tappedSendButton(_ sender: Any) {
        reSendMemoFireStore()
//        shareStickerImage()
        self.dismiss(animated: true, completion: nil)
    }


    
    
    @IBOutlet weak var graffitiBackGroundView: UIView!
    
    @IBOutlet weak var commentTextView: UITextView!
    
    @IBOutlet weak var graffitiUserImageView: UIImageView!
    @IBOutlet weak var graffitiUserLabel: UILabel!
    @IBOutlet weak var graffitiContentsImageView: UIImageView!
    @IBOutlet weak var graffitiTitleLabel: UILabel!
    @IBOutlet weak var graffitiLabel: UILabel!
    
    @IBOutlet weak var graffitiImageWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var graffitiImageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var commentTextViewConstraint: NSLayoutConstraint!
    
    
    
    func reSendMemoFireStore() {

        func randomString(length: Int) -> String {
            let characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
            return String((0..<length).map{ _ in characters.randomElement()! })
        }
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let graffitiUserId = userId else {return}
        guard let graffitiUserName = userName else {return}
        guard let graffitiUserImage = userImage else {return}
        guard let graffitiUserFrontId = userFrontId else {return}
        guard let graffitiContentsImage = postInfoImage else {return}
        guard let graffitiTitle = postInfoTitle else {return}
        
        let hexColorString = #colorLiteral(red: 0, green: 1, blue: 0.8712542808, alpha: 1).toHexString()
        let hexBackColorString = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.900812162).toHexString()

        
        let db = Firestore.firestore()
        let memoId = randomString(length: 20)
        let thisisMessage = self.commentTextView.text.trimmingCharacters(in: .newlines)

        
        let memoInfoDic = [
            "message" : thisisMessage as Any,
            "sendImageURL": "",
            "documentId": memoId,
            "createdAt": FieldValue.serverTimestamp(),
            "textMask":textMask.randomElement() ?? "",
            "userId":uid,
            "graffitiUserId":graffitiUserId,
            "graffitiUserFrontId":graffitiUserFrontId,
            "graffitiUserName":graffitiUserName,
            "graffitiUserImage":graffitiUserImage,
            "graffitiTitle":graffitiTitle,
            "graffitiContentsImage":graffitiContentsImage,
            "hexColor": hexColor ?? hexColorString,
            "backHexColor":backHexColor ?? hexBackColorString,
            "textFontName":fontName ?? "",
            "readLog": false,
            "anonymous":false,
            "admin": false,
            "delete": false,
            
        ] as [String: Any]
        
        let myPost = [
            "message" : thisisMessage as Any,
            "sendImageURL": "",
            "documentId": memoId,
            "createdAt": FieldValue.serverTimestamp(),
            "textMask":textMask.randomElement() ?? "",
            "userName":UserDefaults.standard.string(forKey: "userName") ?? "",
            "userImage":UserDefaults.standard.string(forKey: "userImage") ?? "",
            "userFrontId":UserDefaults.standard.string(forKey: "userFrontId") ?? "",
            "userId":uid,
            "graffitiUserId":graffitiUserId,
            "graffitiUserFrontId":graffitiUserFrontId,
            "graffitiUserName":graffitiUserName,
            "graffitiUserImage":graffitiUserImage,
            "graffitiTitle":graffitiTitle,
            "graffitiContentsImage":graffitiContentsImage,
            "hexColor": hexColor ?? hexColorString,
            "backHexColor":backHexColor ?? hexBackColorString,
            "textFontName":fontName ?? "",
            "anonymous":false,
            "admin": false,
            "delete": false,
            
        ] as [String: Any]
        
        db.collection("users").document(uid).collection("Connections").whereField("status", isEqualTo: "accept").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                
                if querySnapshot?.documents.count ?? 0 >= 1{
                    for document in querySnapshot!.documents {
                        print("\(document.documentID) => \(document.data())")
                        let userId = document.data()["userId"] as? String ?? ""
                        db.collection("users").document(userId).collection("TimeLine").document(memoId).setData(memoInfoDic)

                    }
                }
            }
        }
        db.collection("AllOutMemo").document(memoId).setData(memoInfoDic)
//
        db.collection("users").document(uid).collection("TimeLine").document(memoId).setData(memoInfoDic)
//
        db.collection("users").document(uid).collection("MyPost").document(memoId).setData(myPost)
        
    }
    
    
    
    
    
    fileprivate let placeholder: String = "返信コメントを入力" //プレイスホルダー
    fileprivate var maxWordCount: Int = 200 //最大文字数

    
    override func viewDidLoad() {
        super.viewDidLoad()
        let safeAreaWidth = UIScreen.main.bounds.size.width

        graffitiUserLabel.text = userFrontId
        graffitiTitleLabel.text = postInfoTitle
        graffitiTitleLabel.font = UIFont(name:"03SmartFontUI", size:16)
        let transScale = CGAffineTransform(rotationAngle: CGFloat(270))
        graffitiLabel.transform = transScale
        graffitiLabel.font = UIFont(name: fontName ?? "Southpaw", size: safeAreaWidth/8)
        graffitiLabel.text = postInfoTitle
        
        let hexColorString = #colorLiteral(red: 0, green: 1, blue: 0.8712542808, alpha: 1).toHexString()
        let UITextColor = UIColor(hex: hexColor ?? hexColorString)
        graffitiLabel.textColor = UITextColor
        
        let safeAreaHeight = UIScreen.main.bounds.size.height
        
        commentTextViewConstraint.constant = safeAreaHeight/8
        
        graffitiUserImageView.clipsToBounds = true
        graffitiUserImageView.layer.cornerRadius = 25
        
        graffitiContentsImageView.clipsToBounds = true
        graffitiContentsImageView.layer.cornerRadius = 10
        
        graffitiBackGroundView.clipsToBounds = true
        graffitiBackGroundView.layer.cornerRadius = 10
        let hexBackColorString = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.900812162).toHexString()

        graffitiBackGroundView.backgroundColor = UIColor(hex: backHexColor ?? hexBackColorString)
        
        self.commentTextView.delegate = self

        commentTextView.textColor = .gray
        commentTextView.text = placeholder
        
        wordCountLabel.text = "200文字まで"
        
        commentTextView.clipsToBounds = true
        commentTextView.layer.cornerRadius = 8
        
        sendButton.backgroundColor = .gray
        sendButton.clipsToBounds = true
        sendButton.layer.cornerRadius = 5
        
      


        
        if let url = URL(string:userImage ?? "") {
            Nuke.loadImage(with: url, into: graffitiUserImageView)
        } else {
            graffitiUserImageView.image = nil
        }
        
        if let url = URL(string:postInfoImage ?? "") {
            Nuke.loadImage(with: url, into: graffitiContentsImageView)
            graffitiTitleLabel.alpha = 1
            graffitiLabel.alpha = 0
            graffitiImageWidthConstraint.constant = safeAreaWidth/2
            graffitiImageViewHeightConstraint.constant = safeAreaWidth/2
        } else {
            graffitiContentsImageView.image = nil
            graffitiTitleLabel.alpha = 0
            graffitiLabel.alpha = 1
            graffitiImageWidthConstraint.constant = safeAreaWidth/2

            graffitiImageViewHeightConstraint.constant = 0

        }
    }
}

extension ReMemoPostVC : UITextViewDelegate {
    func textView(_ commentTextView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let existingLines = commentTextView.text.components(separatedBy: .newlines)//既に存在する改行数
        let newLines = text.components(separatedBy: .newlines)//新規改行数
        let linesAfterChange = existingLines.count + newLines.count - 1 //最終改行数。-1は編集したら必ず1改行としてカウントされるから。
        return linesAfterChange <= 20 && commentTextView.text.count + (text.count - range.length) <= maxWordCount
    }
    func textViewDidChange(_ commentTextView: UITextView) {
        let existingLines = commentTextView.text.components(separatedBy: .newlines)//既に存在する改行数
        let textwhite = commentTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)//空白、改行のみを防ぐ
        if textwhite.isEmpty {
            sendButton.isEnabled = false
            sendButton.backgroundColor = .gray
        } else {
            sendButton.isEnabled = true
            sendButton.backgroundColor = #colorLiteral(red: 0, green: 1, blue: 0.8712542808, alpha: 1)
        }
        if existingLines.count <= 20 {
            self.wordCountLabel.text = "残り\(maxWordCount - commentTextView.text.count)文字"
        }
    }
    func textViewDidBeginEditing(_ commentTextView: UITextView) {
        if commentTextView.text == placeholder {
            commentTextView.text = nil
            commentTextView.textColor = .darkText
        }
    }
    func textViewDidEndEditing(_ commentTextView: UITextView) {
        if commentTextView.text.isEmpty {
            commentTextView.textColor = .darkGray
            commentTextView.text = placeholder
        }
    }
}

