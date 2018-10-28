//
//  ConversationTableViewCell.swift
//  Higher Chat of Fintech
//
//  Created by Alex Milogradsky on 04/10/2018.
//  Copyright © 2018 Alex Milogradsky. All rights reserved.
//

import UIKit

//MARK: - Values for DateFormatting

fileprivate enum DateFormatting {
    
    static let dateFormatType = "dd-MM-yyyy HH:mm"
    static let formattedDateSeparator: Character = " "
}

class ConversationTableViewCell: UITableViewCell, ConversationCellConfiguration {

    @IBOutlet weak var namelabel: UILabel!
    @IBOutlet weak var conversationProfileImage: UIImageView!
    @IBOutlet weak var messagePreview: UILabel!
    @IBOutlet weak var timeOfTheMessage: UILabel!
    
    
    var name: String? {
        didSet {
            self.namelabel.text = name
        }
    }
    
    var message: String? {
        didSet {
            if message == nil {
                self.messagePreview.text = "No messages yet"
                self.messagePreview.font = UIFont.systemFont(ofSize: self.messagePreview.font.pointSize)
                self.messagePreview.textColor = UIColor.lightGray
            } else {
                self.messagePreview.text = message
            }
        }
    }
    
    var date: Date? {
        didSet {
            
            if date != nil {
                //Parsing date and getting current date
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = DateFormatting.dateFormatType
                let formattedDate = dateFormatter.string(from: date!)
                let splittedDate = formattedDate.split(separator: DateFormatting.formattedDateSeparator)
                let currentDate = Date()
                let calendar = Calendar.current
                let day = calendar.component(.day, from: currentDate)
                let month = calendar.component(.month, from: currentDate)
                let year = calendar.component(.year, from: currentDate)
                
                //Set date
                if splittedDate[0] == "\(String(format: "%02d", day))-\(String(format: "%02d", month))-\(year)" {
                    self.timeOfTheMessage.text = String(formattedDate.split(separator: " ")[1])
                } else {
                    let dateWithoutActualTime = splittedDate[0].split(separator: "-")
                    self.timeOfTheMessage.text = "\(dateWithoutActualTime[0]).\(dateWithoutActualTime[1]).\(dateWithoutActualTime[2])"
                }
            } else {
                self.timeOfTheMessage.text = ""
            }
            
        }
    }
    
    var online: Bool? {
        didSet {
            if online == true {
                self.backgroundColor = UIColor(red: 1.0, green: 0.80, blue: 0.3, alpha: 0.2)
            } else {
                self.backgroundColor = UIColor.white
            }
        }
    }
    
    var hasUnreadMessages: Bool? {
        didSet {
            if hasUnreadMessages == true {
                self.messagePreview.font = UIFont.boldSystemFont(ofSize: self.messagePreview.font.pointSize)
                self.messagePreview.textColor = UIColor.orange
            } else {
                self.messagePreview.font = UIFont.italicSystemFont(ofSize: self.messagePreview.font.pointSize)
                self.messagePreview.textColor = UIColor.orange
            }
        }
    }
    
    
//    override func prepareForReuse() {
//        super.prepareForReuse()
//
//        conversationProfileImage.image = nil
//    }
}
