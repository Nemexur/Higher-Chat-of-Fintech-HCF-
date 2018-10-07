//
//  ConversationViewController.swift
//  Higher Chat of Fintech
//
//  Created by Alex Milogradsky on 05/10/2018.
//  Copyright © 2018 Alex Milogradsky. All rights reserved.
//

import UIKit

//MARK: - Identifiers

fileprivate let cellIdentifierIncoming = "MessageCellIncoming"
fileprivate let cellIdentifierOutgoing = "MessageCellOutgoing"

class ConversationViewController: UIViewController {
    
    //MARK: - IBOutlets
    
    @IBOutlet weak var chatTableView: UITableView!

    @IBOutlet weak var inputMessageView: UIView!
    
    @IBOutlet weak var userMessage: UITextView!

    @IBOutlet weak var completedMessage: UIButton!

    var user: Conversation? {
        didSet {
            navigationItem.title = user!.name
        }
    }
    
    //MARK: - Messages Container
    
    fileprivate var messages: [Message] = []
    
    //MARK: - Overrided UIViewController Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if user?.lastMessage != nil && user?.hasUnreadMessages == false {
            messages.append(Message(text: user?.lastMessage, isIncoming: true))
        }
        setupIBOutletsAndNotifications()
        textViewDidChange(userMessage)
    }
    
    //MARK: - Button Actions
    
    @IBAction func buttonForMessagePressed(_ sender: Any) {
        if userMessage.text != nil {
            messages.insert(Message(text: userMessage.text, isIncoming: false), at: 0)
            userMessage.text = nil
            chatTableView.reloadData()
            chatTableView.transform = CGAffineTransform (scaleX: 1, y: -1);
        }
        view.frame.origin.y = 0
        hideKeyBoard()
    }
    
    //MARK: - Additional Functions
    
    private func hideKeyBoard() {
        userMessage.resignFirstResponder()
    }
    
    
    private func setupIBOutletsAndNotifications() {
        
        userMessage.layer.cornerRadius = 15
        userMessage.delegate = self
        userMessage.layer.borderColor = UIColor.black.cgColor
        userMessage.layer.borderWidth = 1
        chatTableView.transform = CGAffineTransform (scaleX: 1, y: -1);
        chatTableView.backgroundColor = UIColor(white: 0.90, alpha: 1)
        
        chatTableView.register(ChatTableViewCell.self, forCellReuseIdentifier: cellIdentifierIncoming)
        chatTableView.register(ChatTableViewCell.self, forCellReuseIdentifier: cellIdentifierOutgoing)
        chatTableView.separatorStyle = .none
        chatTableView.backgroundColor = UIColor.white
        
        let notifications = NotificationCenter.default
        notifications.addObserver(self, selector: #selector(keyboardWillChange), name: UIResponder.keyboardWillShowNotification, object: nil)
        notifications.addObserver(self, selector: #selector(keyboardWillChange), name: UIResponder.keyboardWillHideNotification, object: nil)
        notifications.addObserver(self, selector: #selector(keyboardWillChange), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
    }
    
    //MARK: - Selector Functions
    
    @objc func keyboardWillChange (notification: NSNotification) {
        guard
            let keyboardRect = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
            else { return }
        if notification.name == UIResponder.keyboardWillChangeFrameNotification || notification.name == UIResponder.keyboardWillShowNotification {
            view.frame.origin.y = -keyboardRect.height
        } else {
            view.frame.origin.y = 0
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
                                                        identifier: cellIdentifierIncoming,
                                                        indexPath: indexPath,
                                                        message: messages[indexPath.row]) as! ChatTableViewCell
            } else {
                cellFinal = configureCellWithIdentifier(tableView: tableView,
                                                        identifier: cellIdentifierOutgoing,
                                                        indexPath: indexPath,
                                                        message: messages[indexPath.row]) as! ChatTableViewCell
            }
        }
        
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
    
}

