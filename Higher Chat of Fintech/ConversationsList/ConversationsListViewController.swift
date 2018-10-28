//
//  ConversationsListViewController.swift
//  Higher Chat of Fintech
//
//  Created by Alex Milogradsky on 04/10/2018.
//  Copyright © 2018 Alex Milogradsky. All rights reserved.
//

import UIKit

//MARK: - Identifiers

fileprivate let cellIdentifier = "Conversation"

struct Segues {
    static let profileSegueID = "ShowProfile"
    //For ThemesPicker on Obj-C
    static let themesPickerSegueID = "ShowThemesPicker"
    //For ThemesPicker on Swift
    static let themesPickerSwiftSegueID = "ShowThemesPickerSwift"
    static let chatSegueID = "ShowFullChat"
    
    
    private init() { }
}

class ConversationsListViewController: UIViewController, ThemesViewControllerDelegate, CommunicationManagerDelegate {
    //MARK: - IBOutlets
    
    @IBOutlet weak var conversationsTableView: UITableView!
    
    @IBOutlet var chooseThemePickerView: UIView!
    
    //MARK: - Declared variables and constants
    
    var sectionData: [Int:[Conversation]] = [:]
    
    let userTypes: [String] = ["Online", "Offline"]
    
    var selectedColor: UIColor?
    
    var chooseThemePickerViewAvailable: Bool = true
    
    var communicatorManager: CommunicationManager?
    
    //MARK: - HardCoded Conversations Information
    
    var userchats: [Conversation] = [
        /*Conversation(name: "Andrei", lastMessage: nil, date: "07-10-2018 16:09", online: false, hasUnreadMessages: false),
        Conversation(name: "Alex", lastMessage: "Never gonna give you up. Never gonna see your smile", date: "14-09-2018 16:09", online: true, hasUnreadMessages: true),
        Conversation(name: "Oleg", lastMessage: "I dont know what to do right now cause im busy", date: "15-10-2017 20:09", online: true, hasUnreadMessages: true),
        Conversation(name: "Johny", lastMessage: "I dont know what to write", date: "06-10-2018 16:09", online: true, hasUnreadMessages: false),
        Conversation(name: "Steve", lastMessage: "I know what to write", date: "14-09-2018 16:09", online: false, hasUnreadMessages: true),
        Conversation(name: "Jobs", lastMessage: "I have invented Apple", date: "20-02-2002 13:20", online: false, hasUnreadMessages: false),
        Conversation(name: "Ive", lastMessage: nil, date: "14-09-2018 16:09", online: true),
        Conversation(name: "Ilya", lastMessage: nil, date: "30-01-2015 18:27", online: false),
        Conversation(name: "Andrei", lastMessage: nil, date: "07-10-2018 16:09", online: false, hasUnreadMessages: false),
        Conversation(name: "Henry", lastMessage: "How do you study in HSE?", date: "01-09-2018 18:10", online: false, hasUnreadMessages: false),
        Conversation(name: "Max", lastMessage: "I'm busy", date: "15-10-2017 20:09", online: true, hasUnreadMessages: true),
        Conversation(name: "Dima", lastMessage: "Say YES", date: "07-10-2018 15:09", online: false, hasUnreadMessages: true),
        Conversation(name: "Tair", lastMessage: "How do you do?", date: "04-09-2018 15:30", online: true, hasUnreadMessages: true),
        Conversation(name: "Roma", lastMessage: "Where do you live?", date: "20-02-2002 13:20", online: false, hasUnreadMessages: true),
        Conversation(name: "Mary", lastMessage: nil, date: "13-09-2018 17:12", online: true)*/
    ]

    //MARK: - Overrided UIViewController Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        communicatorManager = CommunicationManager()
        sectionData[0] = []
        sectionData[1] = []
        conversationsTableView.alpha = 0
        conversationsTableView.tableFooterView = UIView()
        selectedColor = self.view.backgroundColor
        let defaults = UserDefaults.standard
        if let color = defaults.colorForKey(key: "ThemeOfTheApp") {
            selectedColor = color
            self.view.backgroundColor = selectedColor
            navigationController?.navigationBar.barTintColor = selectedColor
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        reloadTableViewElements()
        communicatorManager?.delegate = self
    }

    //MARK: - Do something with Navigation Bar
    
    private func setupNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        chooseThemePickerView.layer.cornerRadius = 15
    }
    
    //MARK: - Unwind Segues to this ViewController
    
    @IBAction func unwindToConversationsListFromProfile (_ sender: UIStoryboardSegue) { }
    
    @IBAction func unwindToConversationsListFromThemes (_ sender: UIStoryboardSegue) { }
    
    @IBAction func unwindToConversationsListFromThemesSwift (_ sender: UIStoryboardSegue) { }
    
    //MARK: - Button Actions
    
    @IBAction func showChooseThemePickerView(_ sender: Any) {
        if chooseThemePickerViewAvailable {
            displayChooseThemePickerView(chooseThemePickerView)
        } else {
            hideChooseThemePickerView(chooseThemePickerView)
        }
    }
    
    @IBAction func showSwiftThemesPicker(_ sender: Any) {
        self.performSegue(withIdentifier: Segues.themesPickerSwiftSegueID, sender: nil)
    }
    
    @IBAction func showObjCThemesPicker(_ sender: Any) {
        self.performSegue(withIdentifier: Segues.themesPickerSegueID, sender: nil)
    }
    
    //MARK: - Additional Functions
    
    private func reloadTableViewElements() {
        let allocatedUsers = self.allocateUsers(users: userchats)
        sectionData[0] = allocatedUsers.online.sorted(by: {
            if      $0.date == nil && $1.date == nil { return $0.name! < $1.name! }
            else if $0.date == nil && $1.date != nil { return false}
            else if $0.date != nil && $1.date == nil { return true }
            else                                     { return $0.date! > $1.date! }
        })
        sectionData[1] = allocatedUsers.offline.sorted(by: {
            if      $0.date == nil && $1.date == nil { return $0.name! < $1.name! }
            else if $0.date == nil && $1.date != nil { return false}
            else if $0.date != nil && $1.date == nil { return true }
            else                                     { return $0.date! > $1.date! }
        })
        conversationsTableView.reloadData()
    }
    
    private func displayChooseThemePickerView(_ view: UIView) {
        chooseThemePickerViewAvailable.toggle()
        UIView.animate(withDuration: 0.7,
                       delay: 0,
                       usingSpringWithDamping: 0.6,
                       initialSpringVelocity: 0.35,
                       options: [.curveEaseInOut],
                       animations: {view.transform = CGAffineTransform.init(translationX: 0, y: 170)},
                       completion: nil)
    }
    
    private func hideChooseThemePickerView(_ view: UIView) {
        chooseThemePickerViewAvailable.toggle()
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       options: [.curveEaseOut],
                       animations: {view.transform = CGAffineTransform.identity},
                       completion: nil)
    }
    
    //MARK: - Delegate Methods
    
    func themesViewController(_ controller: ThemesViewController, didSelectTheme selectedTheme: UIColor) {
        logThemeChanging(selectedTheme: selectedTheme)
    }

    func logThemeChanging(selectedTheme: UIColor) {
        let defaults = UserDefaults.standard
        self.view.backgroundColor = selectedTheme
        UINavigationBar.appearance().barTintColor = selectedTheme
        selectedColor = selectedTheme
        let queue = DispatchQueue.global(qos: .background)
        queue.async { defaults.setColor(color: selectedTheme, forKey: "ThemeOfTheApp") }
        let colors = [UIColor.red:"Red", UIColor.yellow:"Yellow", UIColor.green:"Green", UIColor.white:"White"]
        if colors.keys.contains(selectedTheme) {
            print("User picked: \(colors[selectedTheme]!) color")
        }
    }
    
    func receiveNewMessage(text: String, fromUser: String, toUser: String) {
        if let userIndex = userchats.index(where: {$0.id == fromUser}) {
            let receivedMessage = Message(text: text, isIncoming: true)
            var newMessages = userchats[userIndex].messages
            newMessages?.insert(receivedMessage, at: 0)
            userchats[userIndex].messages = newMessages
            userchats[userIndex].lastMessage = receivedMessage.text
            userchats[userIndex].date = Date()
            userchats[userIndex].hasUnreadMessages = true
            DispatchQueue.main.async {
                self.reloadTableViewElements()
            }
        }
    }
    
    func sendNewMessage(text: String, fromUser: String, toUser: String) { }
    
    func newUser(userID: String, userName: String) {
        if !userchats.contains(where: {$0.id == userID}) {
            userchats.append(Conversation(id: userID, name: userName, lastMessage: nil, date: nil, online: true))
        } else {
            if let userIndex = userchats.index(where: {$0.id == userID}) {
                userchats[userIndex].online? = true
            }
        }
        DispatchQueue.main.async {
            self.reloadTableViewElements()
            UIView.animate(withDuration: 0.5) {
                self.conversationsTableView.alpha = 1
            }
        }
    }
    
    func lostUser(userID: String) {
        if let userIndex = userchats.index(where: {$0.id == userID}) {
            userchats[userIndex].online? = false
        }
        DispatchQueue.main.async {
            self.reloadTableViewElements()
        }
    }
    
    //MARK: - Prepare for Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Segues.chatSegueID {
            guard let chatController = segue.destination as? ConversationViewController
                else { return }
            chatController.user = sender as? Conversation
            chatController.userDevice = communicatorManager?.userName
            chatController.communicatorManager = communicatorManager
            chatController.view.backgroundColor = selectedColor
            chatController.inputMessageView.backgroundColor = selectedColor
            chatController.conversationsListViewController = self
        }
        
        if segue.identifier == Segues.profileSegueID {
            guard let userController = segue.destination as? ProfileViewController
                else { return}
            userController.view.backgroundColor = selectedColor
            userController.textFieldProfileName.backgroundColor = selectedColor
        }
        
        if segue.identifier == Segues.themesPickerSegueID {
            guard let themePickerController = segue.destination as? ThemesViewController
                else { return }
            hideChooseThemePickerView(chooseThemePickerView)
            themePickerController.delegate = self
            themePickerController.view.backgroundColor = selectedColor
        }
        
        if segue.identifier == Segues.themesPickerSwiftSegueID {
            guard let themesPickerSwiftController = segue.destination as? ThemesPickerViewControllerSwift
                else { return }
            hideChooseThemePickerView(chooseThemePickerView)
            themesPickerSwiftController.onThemesViewControllerDelegate = {
                [unowned self] didSelectTheme in
                self.logThemeChanging(selectedTheme: didSelectTheme)
            }
            themesPickerSwiftController.view.backgroundColor = selectedColor
        }
    }
    
    //MARK: - Allocate Users Functions
    
    private func allocateUsers(users: [Conversation]) -> (online: [Conversation], offline: [Conversation]){
        
        var offlineUsers:[Conversation] = []
        var onlineUsers: [Conversation] = []
        for user in users {
            if user.online == false {
                offlineUsers.append(user)
            } else {
                onlineUsers.append(user)
            }
        }
        return(onlineUsers, offlineUsers)
    }
}

//MARK: - Extensions for UITableView

extension ConversationsListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (sectionData[section]?.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! ConversationCellConfiguration
        let certainUser = sectionData[indexPath.section]![indexPath.row]
        
        //MARK: - Fill UITableViewCell
        
        cell.name = certainUser.name
        cell.message = certainUser.lastMessage
        cell.date = certainUser.date
        cell.online = certainUser.online
        cell.hasUnreadMessages = certainUser.hasUnreadMessages
        
        return cell as! ConversationTableViewCell
        
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return userTypes[section]
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return userTypes.count
    }
}

extension ConversationsListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let certainUser = sectionData[indexPath.section]![indexPath.row]
        sectionData[indexPath.section]![indexPath.row] = Conversation()
        certainUser.hasUnreadMessages = false
        sectionData[indexPath.section]![indexPath.row] = certainUser
        
        self.performSegue(withIdentifier: Segues.chatSegueID, sender: certainUser)
        
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}
