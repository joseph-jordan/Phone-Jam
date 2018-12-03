//
//  RecTableViewCell.swift
//  Phone Jam App
//
//  Created by Joseph Jordan on 3/10/18.
//  Copyright © 2018 Joseph Jordan. All rights reserved.
//

import UIKit



class RecTableViewCell: UITableViewCell {
    
    var homeVCInstance : HomeViewController?
    
    var rec : Rec?
    
    @IBOutlet weak var recNameLabel: UILabel!
    
    @IBOutlet weak var referredByLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    @IBAction func viewDetails(_ sender: Any) {
        thisRec = rec
        homeVCInstance?.segueToRecScreen()
    }
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
