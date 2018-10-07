//
//  ChatTableViewCell.swift
//  Higher Chat of Fintech
//
//  Created by Alex Milogradsky on 04/10/2018.
//  Copyright © 2018 Alex Milogradsky. All rights reserved.
//

import UIKit

fileprivate let fontFamilyType = "Helvetica"

class ChatTableViewCell: UITableViewCell, MessageCellConfiguration {
    
    var textMessage: String? {
        didSet {
            self.messageLabel.text = textMessage
        }
    }
    
    //MARK: - Declared Elments of TableView Cell
    
    let messageLabel = UILabel()
    let bubblebackgroundView = UIView()

    //MARK: - Declared Changing Constraints
    
    var trailingConstraint: NSLayoutConstraint!
    var leadingConstraint: NSLayoutConstraint!
    
    
    //MARK: - Overrided Init of Cell
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .clear
        
        //MARK: - Configure BubbleBackgroundView
        
        bubblebackgroundView.layer.cornerRadius = 24
        bubblebackgroundView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(bubblebackgroundView)
        
        //MARK: - Configure MessageLabel
        
        addSubview(messageLabel)
        messageLabel.font = UIFont(name: fontFamilyType, size: 14)
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        //MARK: - Value of Constraints
        let constraints = [
            messageLabel.topAnchor.constraint(equalTo: topAnchor, constant: 32),
            messageLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -32),
            messageLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 200),
            
            bubblebackgroundView.topAnchor.constraint(equalTo: messageLabel.topAnchor, constant: -16),
            bubblebackgroundView.leadingAnchor.constraint(equalTo: messageLabel.leadingAnchor, constant: -16),
            bubblebackgroundView.bottomAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 16),
            bubblebackgroundView.trailingAnchor.constraint(equalTo: messageLabel.trailingAnchor, constant: 16)
        ]
        
        NSLayoutConstraint.activate(constraints)
        
        leadingConstraint = messageLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 25)
        leadingConstraint.isActive = false
        trailingConstraint = messageLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -25)
        leadingConstraint.isActive = true
        
        messageLabel.numberOfLines = 0
        
        //MARK: - Set certain cell according to Identifier
        
        if reuseIdentifier == "MessageCellIncoming" {
            bubblebackgroundView.backgroundColor = UIColor.gray
            messageLabel.textColor = UIColor.white
            
            leadingConstraint.isActive = true
            trailingConstraint.isActive = false
        }
        
        if reuseIdentifier == "MessageCellOutgoing" {
            bubblebackgroundView.backgroundColor = UIColor.orange
            messageLabel.textColor = UIColor.black
            
            leadingConstraint.isActive = false
            trailingConstraint.isActive = true
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
}
