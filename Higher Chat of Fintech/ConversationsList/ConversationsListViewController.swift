//
//  ConversationsListViewController.swift
//  Higher Chat of Fintech
//
//  Created by Alex Milogradsky on 04/10/2018.
//  Copyright © 2018 Alex Milogradsky. All rights reserved.
//

import UIKit
import CoreData

// MARK: - Identifiers

private let cellIdentifier = "Conversation"

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
    // MARK: - IBOutlets

    @IBOutlet weak var conversationsTableView: UITableView!

    @IBOutlet var chooseThemePickerView: UIView!

    // MARK: - Declared variables and constants

    var sectionData: [Int: [Conversation]] = [:]

    let userTypes: [String] = ["Online", "Offline"]

    var selectedColor: UIColor?

    var chooseThemePickerViewAvailable: Bool = true

    var communicatorManager: CommunicationManager?

    var storageManager: StorageManager?

    // MARK: - Conversations Information Handler

    var userchats: [Conversation] = []

    // MARK: - FRC Handler

    var fetchedResultsController: NSFetchedResultsController<Conversation>?

    // MARK: - Overrided UIViewController Functions

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        communicatorManager = CommunicationManager()
        storageManager = StorageManager.shared()
        sectionData[0] = []
        sectionData[1] = []
        conversationsTableView.alpha = 0
        conversationsTableView.tableFooterView = UIView()
        selectedColor = self.view.backgroundColor
        let defaults = UserDefaults.standard
        if let color = defaults.colorForKey(key: "ThemeOfTheApp") {
            selectedColor = color
            self.view.backgroundColor = UIColor.white
            navigationController?.navigationBar.barTintColor = selectedColor
        }
        fetchConversations()
        guard let context = storageManager?.coreDataMainContext else { return }
        //guard let model = storageManager?.coreDataModel else { return }
        let fetchRequest: NSFetchRequest<Conversation> = Conversation.fetchRequest()
        //let fetchRequest: NSFetchRequest<Conversation> = Conversation.fetchRequestConversation(model: model)
        let sortDescriptorOnline = NSSortDescriptor(key: "isOnline", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptorOnline]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController?.delegate = self
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        reloadTableViewElements()
        communicatorManager?.delegate = self
        UIView.animate(withDuration: 0.5) {
            self.conversationsTableView.alpha = 1
        }
    }

    // MARK: - Do something with Navigation Bar

    private func setupNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        chooseThemePickerView.layer.cornerRadius = 15
    }

    // MARK: - Unwind Segues to this ViewController

    @IBAction func unwindToConversationsListFromProfile (_ sender: UIStoryboardSegue) { }

    @IBAction func unwindToConversationsListFromThemes (_ sender: UIStoryboardSegue) { }

    @IBAction func unwindToConversationsListFromThemesSwift (_ sender: UIStoryboardSegue) { }

    // MARK: - Button Actions

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

    // MARK: - Additional Functions

    private func reloadTableViewElements() {
        let allocatedUsers = self.allocateUsers(users: userchats)
        sectionData[0] = allocatedUsers.online.sorted(by: {
            if $0.date == nil && $1.date == nil { return ($0.withUser?.userName)! < ($1.withUser?.userName)! } else if $0.date == nil && $1.date != nil { return false } else if $0.date != nil && $1.date == nil { return true } else { return $0.date! > $1.date! }
        })
        sectionData[1] = allocatedUsers.offline.sorted(by: {
            if $0.date == nil && $1.date == nil { return ($0.withUser?.userName)! < ($1.withUser?.userName)! } else if $0.date == nil && $1.date != nil { return false } else if $0.date != nil && $1.date == nil { return true } else { return $0.date! > $1.date! }
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

    private func fetchConversations() {
        if let data = storageManager?.readDataConversation() {
            userchats = data
        }
        do {
            try fetchedResultsController?.performFetch()
        } catch {
            print("Unable to Perform Fetch Request")
            print("\(error), \(error.localizedDescription)")
        }
    }

    // MARK: - Delegate Methods

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
        let colors = [UIColor.red: "Red", UIColor.yellow: "Yellow", UIColor.green: "Green", UIColor.white: "White"]
        if colors.keys.contains(selectedTheme) {
            print("User picked: \(colors[selectedTheme]!) color")
        }
    }

    func receiveNewMessage(text: String, fromUser: String, toUser: String) {
        if let userIndex = userchats.index(where: {$0.withUser?.userID == fromUser}) {
            guard let contextToSave = storageManager?.coreDataContextToSaveNewData else { return }
            if let message = Message.insertMessage(into: contextToSave) {
                message.text = text
                message.isIncoming = true
                guard var newMessages = userchats[userIndex].messages?.array as? [Message] else { return }
                newMessages.insert(message, at: 0)
                let orderedSet: NSOrderedSet = NSOrderedSet.init(array: newMessages)

                userchats[userIndex].setValue(orderedSet, forKey: "messages")
                userchats[userIndex].setValue(message, forKey: "lastMessage")
                userchats[userIndex].setValue(Date(), forKey: "date")
                userchats[userIndex].setValue(true, forKey: "hasUnreadMessages")
                storageManager?.saveDataAppUser(completionIfError: nil, completionIfSuccess: nil)
            }
            OperationQueue.main.addOperation {
                self.reloadTableViewElements()
            }
        }
    }

    func sendNewMessage(text: String, fromUser: String, toUser: String) { }

    func newUser(userID: String, userName: String) {
        if !userchats.contains(where: {$0.withUser?.userID == userID}) {
            guard let contextToSave = storageManager?.coreDataContextToSaveNewData else { return }
            if let conversation = Conversation.insertConversation(into: contextToSave) {
                conversation.conversationID = "\(userID) / \(UIDevice.current.identifierForVendor?.uuidString ?? UIDevice.current.systemName)!"
                conversation.isOnline = true
                conversation.withUser = User.insertUser(into: contextToSave)
                conversation.withUser?.userName = userName
                conversation.withUser?.isOnline = true
                conversation.withUser?.userID = userID
                userchats.append(conversation)
                storageManager?.saveDataAppUser(completionIfError: nil, completionIfSuccess: nil)
            }
        } else {
            if let userIndex = userchats.index(where: {$0.withUser?.userID == userID}) {
                if userchats[userIndex].withUser?.userName != userName {
                    userchats[userIndex].withUser?.setValue(userName, forKey: "userName")
                    userchats[userIndex].setValue(true, forKey: "isOnline")
                } else { userchats[userIndex].setValue(true, forKey: "isOnline") }
                storageManager?.saveDataAppUser(completionIfError: nil, completionIfSuccess: nil)
            }
        }
        OperationQueue.main.addOperation {
            self.reloadTableViewElements()
        }
    }

    func lostUser(userID: String) {
        if let userIndex = userchats.index(where: {$0.withUser?.userID == userID}) {
            userchats[userIndex].setValue(false, forKey: "isOnline")
            storageManager?.saveDataAppUser(completionIfError: nil, completionIfSuccess: nil)
        }
        OperationQueue.main.addOperation {
            self.reloadTableViewElements()
        }
    }

    // MARK: - Prepare for Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Segues.chatSegueID {
            guard let chatController = segue.destination as? ConversationViewController
                else { return }
            chatController.user = sender as? Conversation
            chatController.userDevice = communicatorManager?.userName
            chatController.communicatorManager = communicatorManager
            chatController.view.backgroundColor = UIColor.white
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

    // MARK: - Allocate Users Functions

    private func allocateUsers(users: [Conversation]) -> (online: [Conversation], offline: [Conversation]) {

        var offlineUsers: [Conversation] = []
        var onlineUsers: [Conversation] = []
        for user in users {
            if user.isOnline == false {
                offlineUsers.append(user)
            } else {
                onlineUsers.append(user)
            }
        }
        return (onlineUsers, offlineUsers)
    }
}

// MARK: - Extensions for UITableView

extension ConversationsListViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (sectionData[section]?.count)!
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? ConversationCellConfiguration else { return ConversationTableViewCell() }

        configure(cell, at: indexPath)

        guard let cellToReturn = cell as? ConversationTableViewCell else { return ConversationTableViewCell() }
        return cellToReturn

    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return userTypes[section]
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return userTypes.count
    }

    func configure(_ cell: ConversationCellConfiguration, at indexPath: IndexPath) {
        let conversation = sectionData[indexPath.section]![indexPath.row]
        cell.name = conversation.withUser?.userName
        cell.date = conversation.date
        cell.message = conversation.lastMessage?.text
        cell.online = conversation.isOnline
        cell.hasUnreadMessages = conversation.hasUnreadMessages
    }
}

extension ConversationsListViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let certainUser = sectionData[indexPath.section]![indexPath.row]
        certainUser.setValue(false, forKey: "hasUnreadMessages")
        storageManager?.saveDataAppUser(completionIfError: nil, completionIfSuccess: nil)
        sectionData[indexPath.section]![indexPath.row] = certainUser

        self.performSegue(withIdentifier: Segues.chatSegueID, sender: certainUser)

        tableView.deselectRow(at: indexPath, animated: true)
        tableView.reloadData()
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}

// MARK: - Extension for FetchedResultsControllerDelegate

extension ConversationsListViewController: NSFetchedResultsControllerDelegate {

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.conversationsTableView.beginUpdates()
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.conversationsTableView.endUpdates()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            let indicies: IndexSet = [sectionIndex]
            self.conversationsTableView.insertSections(indicies, with: .fade)
        case .delete:
            let indicies: IndexSet = [sectionIndex]
            self.conversationsTableView.deleteSections(indicies, with: .fade)
        default:
            break
        }
        reloadTableViewElements()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if let indexPath = newIndexPath {
                conversationsTableView.insertRows(at: [indexPath], with: .fade)
            }
        case .delete:
            if let indexPath = indexPath {
                conversationsTableView.deleteRows(at: [indexPath], with: .fade)
            }
        case .update:
            if let indexPath = indexPath, let cell = self.conversationsTableView.cellForRow(at: indexPath) as? ConversationCellConfiguration {
                configure(cell, at: indexPath)
            }
        case .move:
            if let indexPath = indexPath {
                conversationsTableView.deleteRows(at: [indexPath], with: .fade)
            }

            if let newIndexPath = newIndexPath {
                conversationsTableView.insertRows(at: [newIndexPath], with: .fade)
            }
        }
        reloadTableViewElements()
    }
}
