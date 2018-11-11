//
//  PeerToPeerCommunicator.swift
//  Higher Chat of Fintech
//
//  Created by Alex Milogradsky on 25/10/2018.
//  Copyright © 2018 Alex Milogradsky. All rights reserved.
//

import Foundation
import UIKit
import MultipeerConnectivity

class MultipeerCommunicator: NSObject, Communicator, MCSessionDelegate, MCNearbyServiceAdvertiserDelegate, MCNearbyServiceBrowserDelegate, MCBrowserViewControllerDelegate {

    //User Name
    var userName: String?

    weak var delegate: CommunicatorDelegate?
    var online: Bool = Bool()

    var browserVC: MCBrowserViewController!
    var sessions: [MCSession] = []
    var advertiser: MCNearbyServiceAdvertiser!
    var browser: MCNearbyServiceBrowser!
    var peerID: MCPeerID!

    var storageManager: StorageManager?

    override init() {
        super.init()
        self.online = true
        storageManager = StorageManager.shared()
        getProfileUserName()
        peerID = MCPeerID(displayName: UIDevice.current.identifierForVendor!.uuidString)
        advertiser = MCNearbyServiceAdvertiser(peer: peerID, discoveryInfo: ["userName": userName ?? "Русалочка Ариэль"], serviceType: "tinkoff-chat")
        browser = MCNearbyServiceBrowser(peer: peerID, serviceType: "tinkoff-chat")
        advertiser.delegate = self
        browser.delegate = self
        advertiser.startAdvertisingPeer()
        browser.startBrowsingForPeers()
    }

    private func getProfileUserName() {
        if let appUser = storageManager?.readDataAppUser() {
            userName = appUser.currentUser?.userName
        }
    }

    func genrateJSONData(message: [String: String]) -> Data {
        do {
            let theJSONData = try JSONSerialization.data(withJSONObject: message, options: [])
            return theJSONData
        } catch {
            print(error.localizedDescription)
            return Data()
        }
    }

    func sendMessage(string: String, to userID: String, completionHandler: ((Bool, Error?) -> Void)?) {
        let stID = generateMessageID()
        let messageToSend = [
            "eventType": "TextMessage",
            "text": string,
            "messageID": stID
        ]
        let dataToSend = genrateJSONData(message: messageToSend)
        guard let sessionID = sessions.index(where: {$0.connectedPeers.contains(where: {$0.displayName == userID})})
            else { return }
        let peerID = sessions[sessionID].connectedPeers.first(where: {$0.displayName == userID})
        guard let peer = peerID
            else { return }
        do {
            try sessions[sessionID].send(dataToSend, toPeers: [peer], with: .reliable)
            completionHandler?(true, nil)
        } catch {
            completionHandler?(false, error)
        }
    }

    //Session
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case .connected:
            print("\(peerID.displayName) Connected to session: \(session)")

        case .connecting:
            print("\(peerID.displayName) Connecting to session: \(session)")

        default:
            print("\(peerID.displayName) Did not connect to session: \(session)")
        }
    }

    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        let decoder = JSONDecoder()
        do {
            let jsonData = try decoder.decode([String: String].self, from: data)
            guard let receivedMessage = jsonData["text"]
                else { return }
            delegate?.didReceiveMessage(text: receivedMessage, fromUser: peerID.displayName, toUser: userName ?? "Русалочка Ариэль")
        } catch {
            print(error.localizedDescription)
        }
    }

    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) { }

    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) { }

    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) { }

    func session(_ session: MCSession, didReceiveCertificate certificate: [Any]?, fromPeer peerID: MCPeerID, certificateHandler: @escaping (Bool) -> Void) { certificateHandler(true) }

    //Advertiser
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        if sessions.contains(where: {$0.connectedPeers.contains(peerID)}) {
            invitationHandler(false, nil)
        } else {
            let sessionUser = MCSession(peer: self.peerID, securityIdentity: nil, encryptionPreference: .optional)
            sessions.append(sessionUser)
            sessionUser.delegate = self
            invitationHandler(true, sessionUser)
        }
    }

    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        delegate?.failedToStartAdvertising(error: error)
    }

    //Browser
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String: String]?) {
        if !sessions.contains(where: {$0.connectedPeers.contains(peerID)}) {
            let sessionUser = MCSession(peer: self.peerID, securityIdentity: nil, encryptionPreference: .optional)
            sessionUser.delegate = self
            sessions.append(sessionUser)
            browser.invitePeer(peerID, to: sessionUser, withContext: nil, timeout: 10)
        }
        delegate?.didFoundUser(userID: peerID.displayName, userName: info?["userName"])
    }

    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        if let sessionIndex = sessions.index(where: {$0.connectedPeers.contains(peerID)}) {
            sessions.remove(at: sessionIndex)
        }
        delegate?.didLostUser(userID: peerID.displayName)
    }

    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        delegate?.failedToStartBrowsingForUsers(error: error)
    }

    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        browserViewController.dismiss(animated: true, completion: nil)
    }

    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        browserViewController.dismiss(animated: true, completion: nil)
    }
}
