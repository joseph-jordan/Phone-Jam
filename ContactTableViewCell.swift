//
//  ContactTableViewCell.swift
//  Phone Jam App
//
//  Created by Joseph Jordan on 7/4/18.
//  Copyright © 2018 Joseph Jordan. All rights reserved.
//

import UIKit
import Firebase

class ContactTableViewCell: UITableViewCell {

    @IBOutlet weak var contactNameLabel: UILabel!
    
    @IBOutlet weak var plusButton: UIButton!
    var contact : Rec?
    var table : UITableView?
    
    @IBAction func importContact(_ sender: Any) {
        /*if let contact = self.contact {
            if !contact.isQueued {
                contactsToAppend.append(contact)
                contact.isQueued = true
            } else {
                if let index =  contactsToAppend.index(of: contact) {
                    contactsToAppend.remove(at: index)
                }
                contact.isQueued = false
            }
            table?.reloadData()
        }*/
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
