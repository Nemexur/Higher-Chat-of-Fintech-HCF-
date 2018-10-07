//
//  ConversationsListViewController.swift
//  Higher Chat of Fintech
//
//  Created by Alex Milogradsky on 04/10/2018.
//  Copyright © 2018 Alex Milogradsky. All rights reserved.
//

import UIKit

//MARK: - Identifiers

fileprivate let segueIdentifier = "ShowFullChat"
fileprivate let cellIdentifier = "Conversation"

class ConversationsListViewController: UIViewController {
    
    //MARK: - IBOutlets
    
    @IBOutlet weak var conversationsTableView: UITableView!
    
    //MARK: - Declared variables and constants connected to User
    
    var sectionData: [Int:[Conversation]] = [:]
    
    let userTypes: [String] = ["Online", "Offline"]
    
    //MARK: - HardCoded Conversations Information
    
    var userchats: [Conversation] = [
        Conversation(name: "Andrei", lastMessage: nil, date: "07-10-2018 16:09", online: false, hasUnreadMessages: false),
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
        Conversation(name: "Mary", lastMessage: nil, date: "13-09-2018 17:12", online: true)
    ]

    //MARK: - Overrided UIViewController Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        let allocatedUsers = allocateUsers(users: userchats)
        sectionData[0] = allocatedUsers.online
        sectionData[1] = allocatedUsers.offline
    
    }

    //MARK: - Do something with Navigation Bar
    
    private func setupNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    //MARK: - Unwind Segues to this ViewController
    
    @IBAction func unwindToConversationsListFromProfile (_ sender: UIStoryboardSegue) {
        
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
        
        self.performSegue(withIdentifier: segueIdentifier, sender: certainUser)
        
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? ConversationViewController {
            controller.user = sender as? Conversation
        }
    }
}
