//
//  ConversationViewController.swift
//  Higher Chat of Fintech
//
//  Created by Alex Milogradsky on 05/10/2018.
//  Copyright © 2018 Alex Milogradsky. All rights reserved.
//

import UIKit
import CoreData

// MARK: - Identifiers

struct CellID {
    static let cellIdentifierIncoming: String = "MessageCellIncoming"
    static let cellIdentifierOutgoing: String = "MessageCellOutgoing"

    private init() { }
}

struct TitleConfiguration {
    static let fontName: String = "Helvetica"
    static let fontSize: CGFloat = 20
    
    private init() { }
}

class ConversationViewController: UIViewController, ConversationModelDelegate, CAAnimationDelegate {
    // MARK: - IBOutlets

    @IBOutlet weak var chatTableView: UITableView!

    @IBOutlet weak var inputMessageView: UIView!

    @IBOutlet weak var userMessage: UITextView!

    @IBOutlet weak var completedMessage: UIButton!

    @IBOutlet var bottomConstraintOfInputMessageView: NSLayoutConstraint!

    // MARK: - Variables
    var user: Conversation? {
        didSet {
            navigationItem.title = user!.withUser?.userName
        }
    }
    var userDevice: String!
    var conversationID: String!
    private var dataSource: [ConversationCellDisplayModel] = []
    var conversationModel: IConversationModel?
    private var userIsOnline: Bool?
    private var emitterAnimationOnTap: IAnimationWithEmitterLayer?

    weak var conversationsListViewController: ConversationsListViewController?
    fileprivate var fetchedResultsController: NSFetchedResultsController<Message>?
    // MARK: - Messages Container
    fileprivate var messages: [Message] = []
    // MARK: - Placeholder for userMessage

    fileprivate let placeholderTextForTextView: String = "Message"

    // MARK: - Overrided UIViewController Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        conversationModel?.delegate = self
        conversationModel?.fetchedResultsController.delegate = self
        fetchMessages()
        setupGestures()
        setupIBOutletsAndNotifications()
        textViewDidChange(userMessage)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        setupNavigationBarTitleAndButtons()
        setupViewElements()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        chatTableView.reloadData()
        conversationModel?.communicatorManager.delegate = conversationModel as? ConversationModel
        UIView.animate(withDuration: 0.3) {
            self.chatTableView.alpha = 1
        }
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        conversationsListViewController = nil
    }

    // MARK: - Button Actions
    @IBAction func buttonForMessagePressed(_ sender: Any) {
        if userMessage.text.withoutSpecialCharacters != nil && userMessage.text.withoutSpecialCharacters != "" && userMessage.text != placeholderTextForTextView {
            guard let contextToSave = conversationModel?.getContextToSaveNewData() else { return }
            guard let newMessage = Message.insertMessage(into: contextToSave) else { return }
            newMessage.text = userMessage.text
            newMessage.isIncoming = false
            messages.insert(newMessage, at: 0)
            dataSource.insert(ConversationCellDisplayModel(message: userMessage.text), at: 0)
            let orderedSet: NSOrderedSet = NSOrderedSet.init(array: messages)
            guard let lastMessage = Message.insertMessage(into: contextToSave) else { return }
            lastMessage.text = "(ME) \(newMessage.text!)"
            lastMessage.isIncoming = false
            user?.setValue(orderedSet, forKey: "messages")
            user?.setValue(lastMessage, forKey: "lastMessage")
            user?.setValue(false, forKey: "hasUnreadMessages")
            user?.setValue(Date(), forKey: "date")

            guard let toUser = user?.withUser?.userID
                else { return }
            sendNewMessage(text: userMessage.text, fromUser: userDevice, toUser: toUser)
            userMessage.text = nil
            chatTableView.transform = CGAffineTransform (scaleX: 1, y: -1)
            conversationModel?.saveNewData()
        }
    }
    // MARK: - Additional Functions
    @objc private func hideKeyBoard() {
        userMessage.resignFirstResponder()
    }
    @objc private func startAnimationOnTap(_ recongnizer: UILongPressGestureRecognizer) {
        emitterAnimationOnTap = TinkoffEmblemView()
        emitterAnimationOnTap?.emitterLayer = CAEmitterLayer()
        emitterAnimationOnTap?.emitterCell = CAEmitterCell()
        emitterAnimationOnTap?.rootLayer = CALayer()
        emitterAnimationOnTap?.recognizer = recongnizer
        emitterAnimationOnTap?.view = view
        switch recongnizer.state {
        case .began:
            emitterAnimationOnTap?.performAnimation()
        case .changed:
            emitterAnimationOnTap?.changeAnimationPosition()
        case .ended:
            emitterAnimationOnTap?.stopAnimation()
        case .cancelled:
            emitterAnimationOnTap?.stopAnimation()
        case .failed:
            emitterAnimationOnTap?.stopAnimation()
        default:
            return
        }
    }
    private func setupViewElements() {
        completedMessage.layer.opacity = 0.66
        completedMessage.isEnabled = false
        chatTableView.alpha = 0
        conversationID = user?.conversationID
        inputMessageView.layer.borderColor = UIColor.lightGray.cgColor
        inputMessageView.layer.borderWidth = 1
    }
    private func setupNavigationBarTitleAndButtons() {
        if user?.isOnline == true {
            userIsOnline = true
            navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: TitleConfiguration.fontName, size: TitleConfiguration.fontSize * 1.1) as Any, NSAttributedString.Key.foregroundColor: UIColor.green]
        } else {
            userIsOnline = false
            navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: TitleConfiguration.fontName, size: TitleConfiguration.fontSize) as Any, NSAttributedString.Key.foregroundColor: UIColor.black]
        }
    }
    private func setupGestures() {
        let tapToHideKeyboard: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyBoard))
        view.addGestureRecognizer(tapToHideKeyboard)
        let tapToAnimateTinkoffEmblem: UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(ConversationViewController.startAnimationOnTap(_:)))
        view.addGestureRecognizer(tapToAnimateTinkoffEmblem)
    }
    private func setupIBOutletsAndNotifications() {
        userMessage.textColor = UIColor.lightGray
        userMessage.layer.cornerRadius = 15
        userMessage.delegate = self
        userMessage.layer.borderColor = UIColor.black.cgColor
        userMessage.layer.borderWidth = 1
        userMessage.text = placeholderTextForTextView
        userMessage.isEditable = true
        userMessage.selectedRange = NSRange(location: 1, length: 0)
        chatTableView.transform = CGAffineTransform (scaleX: 1, y: -1)
        chatTableView.backgroundColor = UIColor(white: 0.90, alpha: 1)
        chatTableView.register(ChatTableViewCell.self, forCellReuseIdentifier: CellID.cellIdentifierIncoming)
        chatTableView.register(ChatTableViewCell.self, forCellReuseIdentifier: CellID.cellIdentifierOutgoing)
        chatTableView.separatorStyle = .none
        chatTableView.backgroundColor = UIColor.white
        let notifications = NotificationCenter.default
        notifications.addObserver(self, selector: #selector(keyboardWillChange), name: UIResponder.keyboardWillShowNotification, object: nil)
        notifications.addObserver(self, selector: #selector(keyboardWillChange), name: UIResponder.keyboardWillHideNotification, object: nil)
        notifications.addObserver(self, selector: #selector(keyboardWillChange), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)

    }

    private func fetchMessages() {
        if let fetchedMessages = conversationModel?.fetchMessages() {
            messages = fetchedMessages
        }
    }
    
    //MARK: - Animations for Sending Message Button
    private func performAnimationForSendingMessageButton() {
        let groupAnimation = CAAnimationGroup()
        groupAnimation.duration = 0.5
        groupAnimation.isAccessibilityElement = true
        if userIsOnline == true {
            groupAnimation.animations = [scaleAnimationForSendingMessageButton(), rotateAnimationForSendingMessageButton(), opacityAnimationForSendingMessageButton(fromValue: 0.66, toValue: 1)]
            completedMessage.layer.add(groupAnimation, forKey: nil)
            completedMessage.layer.opacity = 1
            completedMessage.isEnabled = true
        } else {
            if completedMessage.layer.opacity != 0.66 {
                groupAnimation.animations = [scaleAnimationForSendingMessageButton(), rotateAnimationForSendingMessageButton(), opacityAnimationForSendingMessageButton(fromValue: 1, toValue: 0.66)]
                completedMessage.layer.add(groupAnimation, forKey: nil)
                completedMessage.layer.opacity = 0.66
                completedMessage.isEnabled = false
            }
        }
    }
    private func rotateAnimationForSendingMessageButton() -> CASpringAnimation {
        let animationRotate = CASpringAnimation(keyPath: "transform.rotation")
        animationRotate.fromValue = 0.1
        animationRotate.toValue = 0
        animationRotate.damping = 4
        animationRotate.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeIn)
        return animationRotate
    }
    private func scaleAnimationForSendingMessageButton() -> CASpringAnimation {
        let animationScale = CASpringAnimation(keyPath: "transform.scale")
        animationScale.fromValue = 1.15
        animationScale.toValue = 1
        animationScale.stiffness = 300
        animationScale.mass = 0.5
        animationScale.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeIn)
        return animationScale
    }
    private func opacityAnimationForSendingMessageButton(fromValue: Float, toValue: Float) -> CABasicAnimation {
        let animationOpacity = CABasicAnimation(keyPath: "opacity")
        animationOpacity.beginTime = CACurrentMediaTime() + 0.5
        animationOpacity.fromValue = fromValue
        animationOpacity.toValue = toValue
        return animationOpacity
    }
    
    //MARK: - Animations For ViewController Title
    private func performAnimationForTitle() {
        // MARK: - Animation For ViewController Title via UIView.animate
        if userIsOnline == true {
            UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 0, options: [.curveEaseOut], animations: {
                self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: TitleConfiguration.fontName, size: TitleConfiguration.fontSize * 1.1) as Any, NSAttributedString.Key.foregroundColor: UIColor.green]
                self.navigationController?.navigationBar.layoutIfNeeded()
            }, completion: nil)
        } else {
            UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 0, options: [.curveEaseOut], animations: {
                self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: TitleConfiguration.fontName, size: TitleConfiguration.fontSize) as Any, NSAttributedString.Key.foregroundColor: UIColor.black]
                self.navigationController?.navigationBar.layoutIfNeeded()
            }, completion: nil)
        }
        // MARK: - Animation For ViewController Title via CATransition
//        let fadeTextAnimation = CATransition()
//        fadeTextAnimation.duration = 1
//        fadeTextAnimation.type = CATransitionType.fade
//        fadeTextAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
//        self.navigationController?.navigationBar.layer.add(fadeTextAnimation, forKey: nil)
//        if userIsOnline == true {
//            navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: TitleConfiguration.fontName, size: TitleConfiguration.fontSize * 1.1) as Any, NSAttributedString.Key.foregroundColor: UIColor.green]
//        } else {
//            navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: TitleConfiguration.fontName, size: TitleConfiguration.fontSize) as Any, NSAttributedString.Key.foregroundColor: UIColor.black]
//        }
    }
    // MARK: - Delegate Functions
    func setup(datasource: [ConversationCellDisplayModel]) {
        self.dataSource = datasource
    }
    func show(error message: String) {
        print("Error: \(message)")
    }
    func receiveNewMessage(text: String, fromUser: String, toUser: String) {
        guard let contextToSave = conversationModel?.getContextToSaveNewData() else { return }
        if let newMessage = Message.insertMessage(into: contextToSave) {
            guard let profileName = user?.withUser?.userID
                else { return }
            if fromUser == profileName {
                newMessage.text = text
                newMessage.isIncoming = true
                messages.insert(newMessage, at: 0)
                let orderedSet: NSOrderedSet = NSOrderedSet.init(array: messages)
                guard let lastMessage = Message.insertMessage(into: contextToSave) else { return }
                lastMessage.text = text
                lastMessage.isIncoming = true
                dataSource.insert(ConversationCellDisplayModel(message: text), at: 0)
                user?.setValue(orderedSet, forKey: "messages")
                user?.setValue(lastMessage, forKey: "lastMessage")
                user?.setValue(false, forKey: "hasUnreadMessages")
                user?.setValue(Date(), forKey: "date")
                conversationModel?.saveNewData()
            } else {
                if let conversationIndex = conversationsListViewController?.userchats.index(where: {$0.withUser?.userID == fromUser}) {
                    guard var messagesToUser = conversationsListViewController?.userchats[conversationIndex].messages?.array as? [Message] else { return }
                    newMessage.text = text
                    newMessage.isIncoming = true
                    messagesToUser.insert(newMessage, at: 0)
                    let orderedSetOfUser: NSOrderedSet = NSOrderedSet.init(array: messagesToUser)
                    conversationsListViewController?.userchats[conversationIndex].setValue(orderedSetOfUser, forKey: "messages")
                    conversationsListViewController?.userchats[conversationIndex].setValue(newMessage, forKey: "lastMessage")
                    conversationsListViewController?.userchats[conversationIndex].setValue(true, forKey: "hasUnreadMessages")
                    conversationsListViewController?.userchats[conversationIndex].setValue(Date(), forKey: "date")
                    conversationModel?.saveNewData()
                }
            }
        }
    }

    func sendNewMessage(text: String, fromUser: String, toUser: String) {
        if let sessionIndex = conversationModel?.communicatorManager.communicator?.sessions.index(where: {$0.connectedPeers.contains(where: {$0.displayName == toUser})}) {
            if let communicator = conversationModel?.communicatorManager.communicator as? MultipeerCommunicator {
                conversationModel?.communicatorManager.communicator?.sessions[sessionIndex].delegate = communicator
            }
        }
        conversationModel?.communicatorManager.communicator?.sendMessage(string: text, to: toUser) { success, error in
            if success == false {
                guard let receivedError = error
                    else { return }
                print(receivedError.localizedDescription)
            } else {
                print("----- Message has been sent successfully -----")
            }
        }
    }

    func newUser(userID: String, userName: String) {
        guard let checkUser = conversationsListViewController?.userchats.contains(where: {$0.withUser?.userID == userID})
            else { return }
        if !checkUser {
            guard let contextToSave = conversationModel?.getContextToSaveNewData() else { return }
            if let conversation = Conversation.insertConversation(into: contextToSave) {
                conversation.conversationID = "\(userID) / \(UIDevice.current.identifierForVendor?.uuidString ?? UIDevice.current.systemName)!"
                conversation.isOnline = true
                conversation.withUser = User.insertUser(into: contextToSave)
                conversation.withUser?.userName = userName
                conversation.withUser?.isOnline = true
                conversation.withUser?.userID = userID
                conversationsListViewController?.userchats.append(conversation)
                conversationModel?.saveNewData()
            }
        } else {
            if let conversationIndex = conversationsListViewController?.userchats.index(where: {$0.withUser?.userID == userID}) {
                if conversationsListViewController?.userchats[conversationIndex].withUser?.userName != userName {
                    conversationsListViewController?.userchats[conversationIndex].withUser?.setValue(userName, forKey: "userName")
                    conversationsListViewController?.userchats[conversationIndex].setValue(true, forKey: "isOnline")
                } else { conversationsListViewController?.userchats[conversationIndex].setValue(true, forKey: "isOnline") }
                userIsOnline = true
                performAnimationForSendingMessageButton()
                performAnimationForTitle()
                conversationModel?.saveNewData()
            }
        }
    }

    func lostUser(userID: String) {
        if let conversationIndex = conversationsListViewController?.userchats.index(where: {$0.withUser?.userID == userID}) {
            conversationsListViewController?.userchats[conversationIndex].setValue(false, forKey: "isOnline")
            userIsOnline = false
            performAnimationForTitle()
            performAnimationForSendingMessageButton()
            conversationModel?.saveNewData()
        }
    }

    // MARK: - Selector Functions

    @objc func keyboardWillChange (notification: NSNotification) {
        guard
            let keyboardRect = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
            else { return }
        if notification.name == UIResponder.keyboardWillChangeFrameNotification || notification.name == UIResponder.keyboardWillShowNotification {
            self.bottomConstraintOfInputMessageView.constant = keyboardRect.height
            UIView.animate(withDuration: 0.5, animations: {
                self.view.layoutIfNeeded()
            })
        } else {
            self.bottomConstraintOfInputMessageView.constant = 0
            UIView.animate(withDuration: 0.5, animations: {
                self.view.layoutIfNeeded()
            })
        }
    }
}

// MARK: - Additional Functions

private func configureCellWithIdentifier(tableView: UITableView, identifier: String, indexPath: IndexPath, message: ConversationCellDisplayModel) -> MessageCellConfiguration {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? MessageCellConfiguration else { return ChatTableViewCell() }
    cell.textMessage = message.message
    return cell
}

// MARK: - ConversationViewController Extensions

extension ConversationViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cellFinal = ChatTableViewCell()

        let flag = messages[indexPath.row].isIncoming
        if flag {
            if let cell = configureCellWithIdentifier(tableView: tableView,
                                                    identifier: CellID.cellIdentifierIncoming,
                                                    indexPath: indexPath,
                                                    message: dataSource[indexPath.row]) as? ChatTableViewCell {
                cellFinal = cell
            }
        } else {
            if let cell = configureCellWithIdentifier(tableView: tableView,
                                                    identifier: CellID.cellIdentifierOutgoing,
                                                    indexPath: indexPath,
                                                    message: dataSource[indexPath.row]) as? ChatTableViewCell {
                cellFinal = cell
            }
        }

        cellFinal.isUserInteractionEnabled = false
        cellFinal.transform = CGAffineTransform (scaleX: 1, y: -1)

        return cellFinal
    }
}

extension ConversationViewController: UITextViewDelegate {

    func textViewDidChange(_ textView: UITextView) {
        let size = CGSize(width: view.frame.width, height: .infinity)
        _ = textView.sizeThatFits(size)
        inputMessageView.sizeThatFits(size)
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
        if user?.isOnline == true && completedMessage.isEnabled == false {
            performAnimationForSendingMessageButton()
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = placeholderTextForTextView
            textView.textColor = UIColor.lightGray
        }
    }

}

extension ConversationViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        chatTableView.beginUpdates()
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        chatTableView.endUpdates()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if let indexPath = newIndexPath {
                chatTableView.insertRows(at: [indexPath], with: .fade)
            }
        case .delete:
            if let indexPath = indexPath {
                chatTableView.deleteRows(at: [indexPath], with: .fade)
            }
        case .update:
            print("Message has been updated")
        case .move:
            if let indexPath = indexPath {
                chatTableView.deleteRows(at: [indexPath], with: .fade)
            }

            if let newIndexPath = newIndexPath {
                chatTableView.insertRows(at: [newIndexPath], with: .fade)
            }
        }
        chatTableView.reloadData()
    }
}
