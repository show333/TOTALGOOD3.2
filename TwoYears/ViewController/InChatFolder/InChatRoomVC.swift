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
import Nuke
import TTTAttributedLabel

class InChatRoomVC:UIViewController{
    
    var teamRoomDic : Team?
    var ChatRoomInfo = [ChatsInfo]()
    var userInfo : [UserInfo] = []

    @IBOutlet weak var backGroundImageView: UIImageView!
    @IBOutlet weak var inChatTableView: UITableView!
    
    private let cellId = "cellId"
    private let accessoryHeight: CGFloat = 90
    private var safeAreaBottom: CGFloat {
        self.view.safeAreaInsets.bottom
    }
    private var tableViewContentInset:UIEdgeInsets = .init(top: 0, left: 0, bottom: 0, right: 0)
    private var tableViewIndicaterInset:UIEdgeInsets = .init(top: 0, left: 0, bottom: 0, right: 0)
    
    private lazy var chatInputAccessoryView: ChatInputAccessoryView = {
        let view = ChatInputAccessoryView()
        view.frame = .init(x: 0, y: 0, width: view.frame.width, height: 70)
        view.delegate = self
        return view
    }()
    
    let db = Firestore.firestore()
    

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
//        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        inChatTableView.alpha = 0.9
//        inChatTableView.backgroundView?.alpha = 0
//        inChatTableView.backgroundColor = .white
        setSwipeBack()
        setupNotification()
        
        if let url = URL(string:"https://firebasestorage.googleapis.com/v0/b/totalgood-7b3a3.appspot.com/o/backGroound%2Fsplashbackground.jpeg?alt=media&token=4c2fd869-a146-4182-83aa-47dd396f1ad6") {
            Nuke.loadImage(with: url, into: backGroundImageView)
        } else {
            backGroundImageView.image = nil
        }
        inChatTableView.delegate = self
        inChatTableView.dataSource = self
        inChatTableView.register(UINib(nibName: "ChatRoomTableViewCell", bundle: nil), forCellReuseIdentifier: cellId)
        
        inChatTableView.contentInset = tableViewContentInset
        inChatTableView.scrollIndicatorInsets = tableViewIndicaterInset
        inChatTableView.keyboardDismissMode = .interactive
        inChatTableView.transform = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: 0)
        
        fetchFireStore()
        
    }
    
    
    func fetchUserInfo(){
        guard let teamId = teamRoomDic?.teamId else { return }
        db.collection("Team").document(teamId).collection("MembersId").document("membersId")
            .addSnapshotListener { documentSnapshot, error in
                guard let document = documentSnapshot else {
                    print("Error fetching document: \(error!)")
                    return
                }
                guard let data = document.data() else {
                    print("Document data was empty.")
                    return
                }
                print("Current data: \(data)")
                let userIdArray = data["userId"] as! Array<String>
                print("ドドド",self.userInfo)
                print("アイア背負fじゃせ",userIdArray)
                
                self.userInfo.removeAll()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    
                    userIdArray.forEach{
                        self.getUserProfile(userId: $0)
                    }
                }
            }
    }
    func getUserProfile(userId:String){
        db.collection("users").document(userId).collection("Profile").document("profile").getDocument { (document, error) in
            if let document = document, document.exists {
                let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                print("Document data: \(dataDescription)")
                let userInfoDic = UserInfo(dic: document.data()!)
                self.userInfo.append(userInfoDic)
                
            } else {
                print("Document does not exist")
            }
        }
    }
    
    
    
    private func fetchFireStore() {
        guard let teamId = teamRoomDic?.teamId else { return }
        db.collection("Team").document(teamId).collection("ChatRoom").addSnapshotListener{ [self] ( snapshots, err) in
            if let err = err {
                print("メッセージの取得に失敗、\(err)")
                return
            }
            snapshots?.documentChanges.forEach({ (Naruto) in
                switch Naruto.type {
                case .added:
                    let dic = Naruto.document.data()
                    let chatsInfo = ChatsInfo(dic: dic)

//                    let date: Date = rarabai.zikokudosei.dateValue()
//                    let momentType = moment(date)

//                    if blockList[rarabai.userId] == true {
//
//                    } else {
//                        if momentType >= moment() - 14.days {
//                            if rarabai.admin == true {
//                            }
//                            self.animals.append(rarabai)
//                        }
//                    }

                    self.ChatRoomInfo.append(chatsInfo)
                    print("dイックs",chatsInfo)
//                    print("でぃく",dic)
//                    print("ららばい",rarabai)
                    self.ChatRoomInfo.sort { (m1, m2) -> Bool in
                        let m1Date = m1.createdAt.dateValue()
                        let m2Date = m2.createdAt.dateValue()
                        return m1Date > m2Date
                    }
                    self.inChatTableView.reloadData()
//                    self.inChatTableView.scrollToRow(at: IndexPath(row:self.ChatRoomInfo.count - 1,section: 0), at: .bottom, animated: true)
                    
                case .modified, .removed:
                    print("noproblem")
                }
            })
        }
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
            
            
            let top = keyboardFrame.height - safeAreaBottom
            let bottom = inChatTableView.contentOffset.y
            var moveY =  -(top - inChatTableView.contentOffset.y)
            if inChatTableView.contentOffset.y != -60 { moveY += 60}
            
            print(bottom)
            
            
            let contentInset = UIEdgeInsets(top: top, left: 0, bottom: 0, right: 0)
            inChatTableView.contentInset = contentInset
            inChatTableView.scrollIndicatorInsets = contentInset
            inChatTableView.contentOffset = CGPoint(x: 0, y: moveY - 60)
        }
    }
    
    @objc func keyboardWillHide() {
        print("keyboardWillHide")
        inChatTableView.contentInset = tableViewContentInset
        inChatTableView.scrollIndicatorInsets = tableViewIndicaterInset
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
        return ChatRoomInfo.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = inChatTableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! ChatRoomTableViewCell
        let width = UIScreen.main.bounds.size.width
        
        cell.sendImageView.image = nil
        cell.userImage.image = nil
        cell.myBackView.backgroundColor = nil
        cell.backView.backgroundColor = nil
        
        cell.myDateLabel.text = ""
        cell.dateLabel.text = ""
        cell.imageDateLabel.text = ""
        cell.myImageDateLabel.text = ""
        
        cell.myBackView.backgroundColor = nil
        
        cell.chatRoomInfo = ChatRoomInfo[indexPath.row]
        
        cell.transform = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: 0)
        
        cell.messageLabel.text = ChatRoomInfo[indexPath.row].message
        cell.myMessageLabel.text = ChatRoomInfo[indexPath.row].message
        
        cell.backView.backgroundColor = .tertiarySystemGroupedBackground
        cell.myBackView.backgroundColor = #colorLiteral(red: 0, green: 1, blue: 0.8712542808, alpha: 1)
        
        cell.Imageheight.constant = 0
        
  

        
        let messageDate = ChatRoomInfo[indexPath.row].createdAt.dateValue()
        let messageMoment = moment(messageDate)
        let dateformatted = messageMoment.format("MM/dd hh:mm")
        cell.dateLabel.text = dateformatted
        cell.myDateLabel.text = dateformatted
        cell.imageDateLabel.text = dateformatted
        cell.myImageDateLabel.text = dateformatted
        
        
        
        
        let uid = Auth.auth().currentUser?.uid
        
        userGetInfo(userId: ChatRoomInfo[indexPath.row].userId,cell: cell)
        
        
        if ChatRoomInfo[indexPath.row].userId != uid{
            cell.myBackView.alpha = 0
            cell.myMessageLabel.alpha = 0
            cell.myDateLabel.alpha = 0
            cell.myImageDateLabel.alpha = 0
            
            cell.backView.alpha = 1
            cell.messageLabel.alpha = 1
            cell.userImage.alpha = 1
            cell.userNameLabel.alpha = 1
            
            cell.imageRightConstraint.constant = width/4
            cell.imageLeftConstraint.constant = 50
            
            if ChatRoomInfo[indexPath.row].sendImageURL != "" {
                if let url = URL(string: ChatRoomInfo[indexPath.row].sendImageURL) {
                    Nuke.loadImage(with: url, into: cell.sendImageView!)
                    cell.Imageheight.constant = width*0.55
                    cell.backView.backgroundColor = .clear
                    cell.myBackView.backgroundColor = .clear
                    cell.myImageDateLabel.alpha = 0
                    cell.imageDateLabel.alpha = 1
                    cell.dateLabel.alpha = 0
                    cell.myDateLabel.alpha = 0
                }
            } else {
                cell.myImageDateLabel.alpha = 0
                cell.imageDateLabel.alpha = 0
                cell.dateLabel.alpha = 1
                cell.myDateLabel.alpha = 0
            }
        } else {
            cell.backView.alpha = 0
            cell.userNameLabel.alpha = 0
            cell.messageLabel.alpha = 0
            cell.dateLabel.alpha = 0
            cell.userImage.alpha = 0
            cell.imageDateLabel.alpha = 0
            
            cell.myBackView.alpha = 1
            cell.myMessageLabel.alpha = 1
            
            
            cell.imageRightConstraint.constant = 8
            cell.imageLeftConstraint.constant = width/4 + 42
            
            if ChatRoomInfo[indexPath.row].sendImageURL != "" {
                if let url = URL(string: ChatRoomInfo[indexPath.row].sendImageURL) {
                    Nuke.loadImage(with: url, into: cell.sendImageView!)
                    cell.Imageheight.constant = width*0.55
                    cell.backView.backgroundColor = .clear
                    cell.myBackView.backgroundColor = .clear
                    cell.myImageDateLabel.alpha = 1
                    cell.imageDateLabel.alpha = 0
                    cell.dateLabel.alpha = 0
                    cell.myDateLabel.alpha = 0
                }
            } else {
                cell.myImageDateLabel.alpha = 0
                cell.imageDateLabel.alpha = 0
                cell.dateLabel.alpha = 0
                cell.myDateLabel.alpha = 1
            }
        }
        
        
        
        return cell
    }
    
    func userGetInfo(userId:String,cell:ChatRoomTableViewCell){
        db.collection("users").document(userId).collection("Profile").document("profile").addSnapshotListener { documentSnapshot, error in
              guard let document = documentSnapshot else {
                print("Error fetching document: \(error!)")
                return
              }
              guard let data = document.data() else {
                print("Document data was empty.")
                return
              }
//            cell.userImage.image = UIImage(named:data["userImage"] as! String)!
            print("愛絵あいあい")
            let userImage = document["userImage"] as? String ?? ""
            cell.userNameLabel.text = document["userName"] as? String ?? ""
            if let url = URL(string:userImage) {
                Nuke.loadImage(with: url, into: cell.userImage)
            } else {
                cell.userImage.image = nil
            }

              print("Current data: \(data)")
            }

//        db.collection("users").document()
        
        
    }
}
extension InChatRoomVC: ChatInputAccessoryViewDelegate{
    func tappedSendButton(text: String) {
        addMessageToFirestore(text: text)
    }
    private func addMessageToFirestore(text: String) {
        chatInputAccessoryView.removeText()
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let teamId = teamRoomDic?.teamId else { return }
        
        func randomString(length: Int) -> String {
            let characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
            return String((0..<length).map{ _ in characters.randomElement()! })
        }
        let documentId = randomString(length: 20)
                    let docData = [
                        "createdAt": FieldValue.serverTimestamp(),
                        "message": text,
                        "userId": uid,
                        "teamId": teamRoomDic?.teamId as Any,
                        "documentId" : documentId,
                        "admin": false,
                        "sendImageURL": "",
                    ] as [String: Any]
        
        db.collection("Team").document(teamId).collection("ChatRoom").document(documentId).setData(docData)
        
    }
}

extension UIView {
    
    func setSwipeBack() {
        let target = ViewController()?.navigationController?.value(forKey: "_cachedInteractionController")
        let recognizer = UIPanGestureRecognizer(target: target, action: Selector(("handleNavigationTransition:")))
        self.InChatRoomVC()?.view.addGestureRecognizer(recognizer)
    }
    
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