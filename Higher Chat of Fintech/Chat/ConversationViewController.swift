//
//  ConversationViewController.swift
//  Higher Chat of Fintech
//
//  Created by Alex Milogradsky on 05/10/2018.
//  Copyright © 2018 Alex Milogradsky. All rights reserved.
//

import UIKit

//MARK: - Identifiers

struct CellID {
    static let cellIdentifierIncoming = "MessageCellIncoming"
    static let cellIdentifierOutgoing = "MessageCellOutgoing"
    
    
    private init() { }
}

class ConversationViewController: UIViewController, CommunicationManagerDelegate {
    
    //MARK: - IBOutlets
    
    @IBOutlet weak var chatTableView: UITableView!

    @IBOutlet weak var inputMessageView: UIView!
    
    @IBOutlet weak var userMessage: UITextView!

    @IBOutlet weak var completedMessage: UIButton!

    @IBOutlet var bottomConstraintOfInputMessageView: NSLayoutConstraint!
    
    //MARK: - Variables
    
    var user: Conversation? {
        didSet {
            navigationItem.title = user!.name
        }
    }
    
    var userDevice: String!
    
    var communicatorManager: CommunicationManager?
    
    weak var conversationsListViewController: ConversationsListViewController?
    
    //MARK: - Messages Container
    
    fileprivate var messages: [Message] = []
    
    //MARK: - Placeholder for userMessage
    
    fileprivate let placeholderTextForTextView: String = "Message"
    
    //MARK: - Overrided UIViewController Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if user?.online == false {
            completedMessage.isEnabled = false
            completedMessage.alpha = 0.66
        }
        inputMessageView.layer.borderColor = UIColor.lightGray.cgColor
        inputMessageView.layer.borderWidth = 1
        if let userMessages = user?.messages { messages = userMessages }
        let tapToHideKeyboard: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyBoard))
        view.addGestureRecognizer(tapToHideKeyboard)
        setupIBOutletsAndNotifications()
        textViewDidChange(userMessage)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        communicatorManager?.delegate = self
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        conversationsListViewController = nil
    }
    
    //MARK: - Button Actions
    
    @IBAction func buttonForMessagePressed(_ sender: Any) {
        if userMessage.text.withoutSpecialCharacters != nil && userMessage.text.withoutSpecialCharacters != "" && userMessage.text != placeholderTextForTextView {
            let newMessage = Message(text: userMessage.text, isIncoming: false)
            messages.insert(newMessage, at: 0)
            user?.messages?.insert(newMessage, at: 0)
            user?.lastMessage = "(ME) \(newMessage.text!)"
            user?.hasUnreadMessages = false
            user?.date = Date()
            guard let toUser = user?.id
                else { return }
            sendNewMessage(text: userMessage.text, fromUser: userDevice, toUser: toUser)
            userMessage.text = nil
            chatTableView.reloadData()
            chatTableView.transform = CGAffineTransform (scaleX: 1, y: -1);
        }
    }
    
    //MARK: - Additional Functions
    
    @objc private func hideKeyBoard() {
        userMessage.resignFirstResponder()
    }
    
    private func setupIBOutletsAndNotifications() {
        userMessage.textColor = UIColor.lightGray
        userMessage.layer.cornerRadius = 15
        userMessage.delegate = self
        userMessage.layer.borderColor = UIColor.black.cgColor
        userMessage.layer.borderWidth = 1
        userMessage.text = placeholderTextForTextView
        userMessage.isEditable = true
        userMessage.selectedRange = NSMakeRange(1, 0);
        chatTableView.transform = CGAffineTransform (scaleX: 1, y: -1);
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
    
    //MARK: - Delegate Functions
    
    func receiveNewMessage(text: String, fromUser: String, toUser: String) {
        let newMessage = Message(text: text, isIncoming: true)
        guard let profileName = user?.id
            else { return }
        if fromUser == profileName {
            messages.insert(newMessage, at: 0)
            user?.messages?.insert(newMessage, at: 0)
            user?.lastMessage = newMessage.text
            user?.hasUnreadMessages = false
            user?.date = Date()
            chatTableView.reloadData()
        } else {
            if let userIndex = conversationsListViewController?.userchats.index(where: {$0.id == fromUser}) {
                conversationsListViewController?.userchats[userIndex].messages?.insert(newMessage, at: 0)
                conversationsListViewController?.userchats[userIndex].lastMessage = newMessage.text
                conversationsListViewController?.userchats[userIndex].hasUnreadMessages = true
                conversationsListViewController?.userchats[userIndex].date = Date()
            }
        }
    }
    
    func sendNewMessage(text: String, fromUser: String, toUser: String) {
        if let sessionIndex = communicatorManager?.communicator?.sessions.index(where: {$0.connectedPeers.contains(where: {$0.displayName == toUser})}) {
            communicatorManager?.communicator?.sessions[sessionIndex].delegate = communicatorManager?.communicator
        }
        for session in (communicatorManager?.communicator?.sessions)! {
            print("\(session.connectedPeers.count) users in session")
        }
        communicatorManager?.communicator?.sendMessage(string: text, to: toUser) {
            success, error in
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
        guard let checkUser = conversationsListViewController?.userchats.contains(where: {$0.id == userID})
            else { return }
        if !checkUser {
            conversationsListViewController?.userchats.append(Conversation(id: userID, name: userName, lastMessage: nil, date: nil, online: true))
        } else {
            if let userIndex = conversationsListViewController?.userchats.index(where: {$0.id == userID}) {
                conversationsListViewController?.userchats[userIndex].online? = true
            }
        }
    }
    
    func lostUser(userID: String) {
        if let userIndex = conversationsListViewController?.userchats.index(where: {$0.id == userID}) {
            conversationsListViewController?.userchats[userIndex].online? = false
        }
    }
    
    //MARK: - Selector Functions
    
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
    
    //MARK: - Alert if there are no messages with this user
    
    private func noMessagesCodeAlert() {
        
        let alert = UIAlertController(title: "Messages", message: "No messages yet. \nDo you want to start a conversation?", preferredStyle: .alert)
        
        //Gallery Action
        let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(OKAction)
        
        //Cancel Action
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        { [unowned self] (_) in
            self.navigationController?.popViewController(animated: true)
            self.dismiss(animated: true, completion: nil)
        }
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    deinit {
        print("----- ConversationViewController has been deinitialized -----")
        self.removeFromParent()
    }
}

//MARK: - Additional Functions

private func configureCellWithIdentifier(tableView: UITableView, identifier: String, indexPath: IndexPath, message: Message) -> MessageCellConfiguration {
    let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! MessageCellConfiguration
    cell.textMessage = message.text
    return cell
}

//MARK: - ConversationViewController Extensions

extension ConversationViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if messages.count == 0 {
            noMessagesCodeAlert()
            return 0
        }
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cellFinal = UITableViewCell()
        
        if let flag = messages[indexPath.row].isIncoming {
            if flag {
                cellFinal = configureCellWithIdentifier(tableView: tableView,
                                                        identifier: CellID.cellIdentifierIncoming,
                                                        indexPath: indexPath,
                                                        message: messages[indexPath.row]) as! ChatTableViewCell
            } else {
                cellFinal = configureCellWithIdentifier(tableView: tableView,
                                                        identifier: CellID.cellIdentifierOutgoing,
                                                        indexPath: indexPath,
                                                        message: messages[indexPath.row]) as! ChatTableViewCell
            }
        }
        cellFinal.isUserInteractionEnabled = false
        cellFinal.transform = CGAffineTransform (scaleX: 1, y: -1);
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
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = placeholderTextForTextView
            textView.textColor = UIColor.lightGray
        }
    }
    
}

