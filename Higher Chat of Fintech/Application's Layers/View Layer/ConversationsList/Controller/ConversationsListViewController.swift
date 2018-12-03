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

class ConversationsListViewController: UIViewController, ThemesViewControllerDelegate, ConversationsListModelDelegate {
    // MARK: - IBOutlets

    @IBOutlet weak var conversationsTableView: UITableView!

    @IBOutlet var chooseThemePickerView: UIView!

    // MARK: - Declared variables and constants

    private var sectionData: [Int: [ConversationsListCellDisplayModel]] = [:]

    private let userTypes: [String] = ["Online", "Offline"]

    private var selectedColor: UIColor?

    private var chooseThemePickerViewAvailable: Bool = true

    //Model
    var conversationsListModel: IConversationsListModel?
    private var emitterAnimationOnTap: IAnimationWithEmitterLayer?

    // MARK: - Conversations Information Handler

    var userchats: [Conversation] = []
    private var dataSource: [ConversationsListCellDisplayModel] = []

    // MARK: - FRC Handler

    var fetchedResultsController: NSFetchedResultsController<Conversation>?

    // MARK: - Overrided UIViewController Functions

    override func viewDidLoad() {
        super.viewDidLoad()
        setupGestures()
        conversationsListModel?.delegate = self
        conversationsListModel?.fetchedResultsController.delegate = self
        sectionData[0] = []
        sectionData[1] = []
        setupNavigationBarAndView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        fetchConversations()
        conversationsListModel?.communicatorManager.delegate = conversationsListModel as? ConversationsListModel
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Helvetica", size: 20) as Any, NSAttributedString.Key.foregroundColor: UIColor.black]
        reloadTableViewElements()
        UIView.animate(withDuration: 0.5) {
            self.conversationsTableView.alpha = 1
        }
    }

    // MARK: - Do something with Navigation Bar/UI

    private func setupNavigationBarAndView() {
        chooseThemePickerView.layer.cornerRadius = 15
        conversationsTableView.alpha = 0
        conversationsTableView.tableFooterView = UIView()
        selectedColor = self.view.backgroundColor
        let defaults = UserDefaults.standard
        if let color = defaults.colorForKey(key: "ThemeOfTheApp") {
            selectedColor = color
            self.view.backgroundColor = UIColor.white
            navigationController?.navigationBar.barTintColor = selectedColor
        }
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
    //To Set Each Conversation Offline
    func setOffline() {
        for index in 0..<dataSource.endIndex {
            dataSource[index].online = false
            userchats[index].setValue(false, forKey: "isOnline")
        }
        reloadTableViewElements()
        conversationsListModel?.saveNewData()
    }

    private func reloadTableViewElements() {
        let allocatedUsers = self.allocateUsers(users: dataSource)
        sectionData[0] = allocatedUsers.online.sorted(by: {
            if $0.date == nil && $1.date == nil { return ($0.name)! < ($1.name)! } else if $0.date == nil && $1.date != nil { return false } else if $0.date != nil && $1.date == nil { return true } else { return $0.date! > $1.date! }
        })
        sectionData[1] = allocatedUsers.offline.sorted(by: {
            if $0.date == nil && $1.date == nil { return ($0.name)! < ($1.name)! } else if $0.date == nil && $1.date != nil { return false } else if $0.date != nil && $1.date == nil { return true } else { return $0.date! > $1.date! }
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
        if let conversationsData = conversationsListModel?.fetchConversations() {
            userchats = conversationsData
        }
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
    private func setupGestures() {
        let tapToAnimateTinkoffEmblem: UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(ConversationsListViewController.startAnimationOnTap(_:)))
        view.addGestureRecognizer(tapToAnimateTinkoffEmblem)
    }

    // MARK: - Delegate Methods

    func themesViewController(_ controller: ThemesViewController, didSelectTheme selectedTheme: UIColor) {
        logThemeChanging(selectedTheme: selectedTheme)
    }

    private func logThemeChanging(selectedTheme: UIColor) {
        let defaults = UserDefaults.standard
        UINavigationBar.appearance().barTintColor = selectedTheme
        selectedColor = selectedTheme
        let queue = DispatchQueue.global(qos: .background)
        queue.async { defaults.setColor(color: selectedTheme, forKey: "ThemeOfTheApp") }
        let colors = [UIColor.red: "Red", UIColor.yellow: "Yellow", UIColor.green: "Green", UIColor.white: "White"]
        if colors.keys.contains(selectedTheme) {
            print("User picked: \(colors[selectedTheme]!) color")
        }
    }
    func setup(datasource: [ConversationsListCellDisplayModel]) {
        self.dataSource = datasource
    }
    func show(error message: String) {
        print("Error: \(message)")
    }
    func receiveNewMessage(text: String, fromUser: String, toUser: String) {
        if let userIndex = userchats.index(where: {$0.withUser?.userID == fromUser}) {
            guard let contextToSave = conversationsListModel?.getContextToSaveNewData() else { return }
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
                //Display Model
                dataSource[userIndex].message = message.text
                dataSource[userIndex].date = Date()
                dataSource[userIndex].hasUnreadMessages = true
                conversationsListModel?.saveNewData()
            }
        }
    }

    func sendNewMessage(text: String, fromUser: String, toUser: String) { }

    func newUser(userID: String, userName: String) {
        if !userchats.contains(where: {$0.withUser?.userID == userID}) {
            guard let contextToSave = conversationsListModel?.getContextToSaveNewData() else { return }
            if let conversation = Conversation.insertConversation(into: contextToSave) {
                let conversationIdentifier = "\(userID) / \(UIDevice.current.identifierForVendor?.uuidString ?? UIDevice.current.systemName)!"
                conversation.conversationID = conversationIdentifier
                conversation.isOnline = true
                conversation.withUser = User.insertUser(into: contextToSave)
                conversation.withUser?.userName = userName
                conversation.withUser?.isOnline = true
                conversation.withUser?.userID = userID
                //Appending Display Model Element
                dataSource.append(ConversationsListCellDisplayModel(identifier: conversationIdentifier, name: userName, message: nil, date: nil, online: true, hasUnreadMessages: nil))
                userchats.append(conversation)
            }
        } else {
            if let userIndex = userchats.index(where: {$0.withUser?.userID == userID}) {
                if userchats[userIndex].withUser?.userName != userName {
                    userchats[userIndex].withUser?.setValue(userName, forKey: "userName")
                    userchats[userIndex].setValue(true, forKey: "isOnline")
                    //Changing Display Model Elements
                    dataSource[userIndex].online = true
                    dataSource[userIndex].name = userName
                } else {
                    userchats[userIndex].setValue(true, forKey: "isOnline")
                    //Changing Display Model Elements
                    dataSource[userIndex].online = true
                }
            }
        }
        OperationQueue.main.addOperation {
            self.reloadTableViewElements()
        }
        conversationsListModel?.saveNewData()
    }

    func lostUser(userID: String) {
        if let userIndex = userchats.index(where: {$0.withUser?.userID == userID}) {
            userchats[userIndex].setValue(false, forKey: "isOnline")
            //Changing Display Model Elements
            dataSource[userIndex].online = false
            OperationQueue.main.addOperation {
                self.reloadTableViewElements()
            }
            conversationsListModel?.saveNewData()
        }
    }

    // MARK: - Prepare for Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Segues.chatSegueID {
            guard let chatController = segue.destination as? ConversationViewController else { return }
            setupConversationViewControllerElements(chatController, sender: sender)
        }

        if segue.identifier == Segues.profileSegueID {
            guard let userController = segue.destination as? ProfileViewController else { return}
            setupProfileViewControllerElements(userController)
        }

        if segue.identifier == Segues.themesPickerSegueID {
            guard let themePickerController = segue.destination as? ThemesViewController else { return }
            hideChooseThemePickerView(chooseThemePickerView)
            setupThemesPickerObjCViewControllerElements(themePickerController)
        }

        if segue.identifier == Segues.themesPickerSwiftSegueID {
            guard let themesPickerSwiftController = segue.destination as? ThemesPickerViewControllerSwift else { return }
            hideChooseThemePickerView(chooseThemePickerView)
            setupThemesPickerSwiftViewControllerElements(themesPickerSwiftController)
        }
    }
    // MARK: - Setup ViewControllers for Segues
    private func setupConversationViewControllerElements(_ chatController: ConversationViewController, sender: Any?) {
        guard let conversation = sender as? ConversationsListCellDisplayModel,
            let storageManager = conversationsListModel?.storageManager,
            let communicatorManager = conversationsListModel?.communicatorManager
            else { return }
        guard let userIndex = userchats.index(where: {$0.conversationID == conversation.identifier}) else { return }
        let conversationModel: IConversationModel = ConversationModel(storageManager: storageManager, communicatorManager: communicatorManager, conversationID: conversation.identifier ?? "Русалочка Ариэль")
        chatController.conversationModel = conversationModel
        chatController.user = userchats[userIndex]
        chatController.userDevice = conversationsListModel?.communicatorManager.userName
        chatController.view.backgroundColor = UIColor.white
        chatController.inputMessageView.backgroundColor = selectedColor
        chatController.conversationsListViewController = self
    }
    private func setupProfileViewControllerElements(_ userController: ProfileViewController) {
        guard let storageManager = conversationsListModel?.storageManager,
            let operationManager = conversationsListModel?.operationManager,
            let networkManager = conversationsListModel?.networkManager
            else { return }
        let profileModel: IProfileModel = ProfileModel(storageManager: storageManager, operationManager: operationManager, networkManager: networkManager)
        userController.profileModel = profileModel
        userController.view.backgroundColor = selectedColor
        userController.textFieldProfileName.backgroundColor = selectedColor
    }
    private func setupThemesPickerSwiftViewControllerElements(_ themesPickerSwiftController: ThemesPickerViewControllerSwift) {
        let themesPickerModel: IThemePickerModel = ThemePickerModel()
        themesPickerSwiftController.themesPickerModel = themesPickerModel
        themesPickerSwiftController.onThemesViewControllerDelegate = {
            [unowned self] didSelectTheme in
            self.logThemeChanging(selectedTheme: didSelectTheme)
        }
        themesPickerSwiftController.view.backgroundColor = selectedColor
    }
    private func setupThemesPickerObjCViewControllerElements(_ themePickerController: ThemesViewController) {
        themePickerController.delegate = self
        themePickerController.view.backgroundColor = selectedColor
    }

    // MARK: - Allocate Users Functions

    private func allocateUsers(users: [ConversationsListCellDisplayModel]) -> (online: [ConversationsListCellDisplayModel], offline: [ConversationsListCellDisplayModel]) {

        var offlineUsers: [ConversationsListCellDisplayModel] = []
        var onlineUsers: [ConversationsListCellDisplayModel] = []
        for user in users {
            if user.online == false {
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
        cellToReturn.conversationProfileImage.layer.cornerRadius = 24
        cellToReturn.conversationProfileImage.clipsToBounds = true
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
        cell.name = conversation.name
        cell.date = conversation.date
        cell.message = conversation.message
        cell.online = conversation.online
        cell.hasUnreadMessages = conversation.hasUnreadMessages
    }
}

extension ConversationsListViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var certainUser = sectionData[indexPath.section]![indexPath.row]
        certainUser.hasUnreadMessages = false
        if let userIndex = userchats.index(where: {$0.conversationID == certainUser.identifier}) {
            userchats[userIndex].setValue(false, forKey: "hasUnreadMessages")
            dataSource[userIndex].hasUnreadMessages = false
        }
        conversationsListModel?.saveNewData()
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
            print("Cell has moved")
        }
        reloadTableViewElements()
    }
}
