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
    static let cellIdentifierIncoming = "MessageCellIncoming"
    static let cellIdentifierOutgoing = "MessageCellOutgoing"

    private init() { }
}

class ConversationViewController: UIViewController, CommunicationManagerDelegate {
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
    var communicatorManager: CommunicationManager?
    var storageManager: StorageManager?

    weak var conversationsListViewController: ConversationsListViewController?
    fileprivate var fetchedResultsController: NSFetchedResultsController<Message>?
    // MARK: - Messages Container
    fileprivate var messages: [Message] = []
    // MARK: - Placeholder for userMessage

    fileprivate let placeholderTextForTextView: String = "Message"

    // MARK: - Overrided UIViewController Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        storageManager = StorageManager.shared()
        if user?.isOnline == false {
            completedMessage.isEnabled = false
            completedMessage.alpha = 0.66
        }
        chatTableView.alpha = 0
        conversationID = user?.conversationID
        inputMessageView.layer.borderColor = UIColor.lightGray.cgColor
        inputMessageView.layer.borderWidth = 1
        let tapToHideKeyboard: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyBoard))
        view.addGestureRecognizer(tapToHideKeyboard)
        setupIBOutletsAndNotifications()
        textViewDidChange(userMessage)
        guard let context = storageManager?.coreDataMainContext else { return }
        //guard let model = storageManager?.coreDataModel else { return }
        let fetchRequest: NSFetchRequest<Message> = Message.fetchRequest()
        //let fetchRequest: NSFetchRequest<Message> = Message.fetchRequestMessage(model: model)
        fetchRequest.predicate = NSPredicate(format: "conversation.conversationID = %@", conversationID)
        let sortDescriptor = NSSortDescriptor(key: "isIncoming", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController?.delegate = self
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        fetchMessages()
        chatTableView.reloadData()
        communicatorManager?.delegate = self
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
            guard let contextToSave = storageManager?.coreDataContextToSaveNewData else { return }
            guard let newMessage = Message.insertMessage(into: contextToSave) else { return }
            newMessage.text = userMessage.text
            newMessage.isIncoming = false
            messages.insert(newMessage, at: 0)
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
            storageManager?.saveDataAppUser(completionIfError: nil, completionIfSuccess: nil)
        }
    }
    // MARK: - Additional Functions
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
        let fetchedMessages = storageManager?.readDataConversationMessages(conversationID: (user?.conversationID)!)
        if let conversationMessages = fetchedMessages {
            messages = conversationMessages
        }
        do {
            try fetchedResultsController?.performFetch()
        } catch {
            print("Unable to Perform Fetch Request")
            print("\(error), \(error.localizedDescription)")
        }
    }

    // MARK: - Delegate Functions

    func receiveNewMessage(text: String, fromUser: String, toUser: String) {
        guard let contextToSave = storageManager?.coreDataContextToSaveNewData else { return }
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
                user?.setValue(orderedSet, forKey: "messages")
                user?.setValue(lastMessage, forKey: "lastMessage")
                user?.setValue(false, forKey: "hasUnreadMessages")
                user?.setValue(Date(), forKey: "date")
                storageManager?.saveDataAppUser(completionIfError: nil, completionIfSuccess: nil)
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
                    storageManager?.saveDataAppUser(completionIfError: nil, completionIfSuccess: nil)
                }
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
        communicatorManager?.communicator?.sendMessage(string: text, to: toUser) { success, error in
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
            guard let contextToSave = storageManager?.coreDataContextToSaveNewData else { return }
            if let conversation = Conversation.insertConversation(into: contextToSave) {
                conversation.conversationID = "\(userID) / \(UIDevice.current.identifierForVendor?.uuidString ?? UIDevice.current.systemName)!"
                conversation.isOnline = true
                conversation.withUser = User.insertUser(into: contextToSave)
                conversation.withUser?.userName = userName
                conversation.withUser?.isOnline = true
                conversation.withUser?.userID = userID
                conversationsListViewController?.userchats.append(conversation)
                storageManager?.saveDataAppUser(completionIfError: nil, completionIfSuccess: nil)
            }
        } else {
            if let conversationIndex = conversationsListViewController?.userchats.index(where: {$0.withUser?.userID == userID}) {
                if conversationsListViewController?.userchats[conversationIndex].withUser?.userName != userName {
                    conversationsListViewController?.userchats[conversationIndex].withUser?.setValue(userName, forKey: "userName")
                    conversationsListViewController?.userchats[conversationIndex].setValue(true, forKey: "isOnline")
                } else { conversationsListViewController?.userchats[conversationIndex].setValue(true, forKey: "isOnline") }
                completedMessage.isEnabled = true
                completedMessage.alpha = 1
                storageManager?.saveDataAppUser(completionIfError: nil, completionIfSuccess: nil)
            }
        }
    }

    func lostUser(userID: String) {
        if let conversationIndex = conversationsListViewController?.userchats.index(where: {$0.withUser?.userID == userID}) {
            conversationsListViewController?.userchats[conversationIndex].setValue(false, forKey: "isOnline")
            completedMessage.isEnabled = false
            completedMessage.alpha = 0.66
            storageManager?.saveDataAppUser(completionIfError: nil, completionIfSuccess: nil)
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

private func configureCellWithIdentifier(tableView: UITableView, identifier: String, indexPath: IndexPath, message: Message) -> MessageCellConfiguration {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? MessageCellConfiguration else { return ChatTableViewCell() }
    cell.textMessage = message.text
    return cell
}

// MARK: - ConversationViewController Extensions

extension ConversationViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cellFinal = ChatTableViewCell()

        let flag = messages[indexPath.row].isIncoming
        if flag {
            if let cell = configureCellWithIdentifier(tableView: tableView,
                                                    identifier: CellID.cellIdentifierIncoming,
                                                    indexPath: indexPath,
                                                    message: messages[indexPath.row]) as? ChatTableViewCell {
                cellFinal = cell
            }
        } else {
            if let cell = configureCellWithIdentifier(tableView: tableView,
                                                    identifier: CellID.cellIdentifierOutgoing,
                                                    indexPath: indexPath,
                                                    message: messages[indexPath.row]) as? ChatTableViewCell {
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
