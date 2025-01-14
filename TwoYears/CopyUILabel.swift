//
//  CopyUILabel.swift
//  TOTALGOOD
//
//  Created by 平田翔大 on 2021/04/17.
//
import Foundation
import UIKit
import TTTAttributedLabel

//class CopyUILabel: UILabel{
//
//    /// - Parameter recognizer: UIGestureRecognizer
//    @objc func handleLongPressGesture(_ recognizer: UIGestureRecognizer)
//    {
//        guard recognizer.state == .recognized else { return }
//
//        if let recognizerView = recognizer.view, let recognizerSuperView = recognizerView.superview, recognizerView.becomeFirstResponder() {
//            let menuController = UIMenuController.shared
//            if #available(iOS 13.0, *) {
//                menuController.showMenu(from: recognizerSuperView, rect: recognizerView.frame)
//            } else {
//                menuController.setTargetRect(recognizerView.frame, in: recognizerSuperView)
//                menuController.setMenuVisible(true, animated: true)
//            }
//        }
//    }
//}

class CopyUILabel: UILabel {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.copyInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.copyInit()
    }

    func copyInit() {
        self.isUserInteractionEnabled = true
        self.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(CopyUILabel.showMenu(sender:))))
    }

    @objc func showMenu(sender:AnyObject?) {
        self.becomeFirstResponder()
        let contextMenu = UIMenuController.shared
        if !contextMenu.isMenuVisible {
            contextMenu.setTargetRect(self.bounds, in: self)
            contextMenu.setMenuVisible(true, animated: true)
        }
    }

    override func copy(_ sender: Any?) {
        let pasteBoard = UIPasteboard.general
        pasteBoard.string = text
        let contextMenu = UIMenuController.shared
        contextMenu.setMenuVisible(false, animated: true)
    }

    override var canBecomeFirstResponder: Bool {
        return true
    }

    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return action == #selector(UIResponderStandardEditActions.copy)
    }
}
