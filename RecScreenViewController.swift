//
//  RecScreenViewController.swift
//  Phone Jam App
//
//  Created by Joseph Jordan on 3/12/18.
//  Copyright © 2018 Joseph Jordan. All rights reserved.
//

import UIKit

class RecScreenViewController: UIViewController {
    
    @IBOutlet var moveOptionsView: UIView!
    
    @IBOutlet weak var recStatusLabel: UILabel!
    
    @IBAction func cancelDelete(_ sender: Any) {
        dismissConfirmationOptions()
    }
    
    @IBAction func confirmDelete(_ sender: Any) {
        if confirmationDeleteButton.titleLabel!.text! == "Delete" {
            thisRec!.updateStatus(newStatus: "deleted")
            thisRec!.isQueued = false
            if callQueue.contains(thisRec!) {
                callQueue.remove(at: callQueue.index(of: thisRec!)!)
            }
            recStatusLabel.text = "Status: deleted"
            deleteButton.setTitle("Reactiveate", for: .normal)
            moveButton.isHidden = true
            setLocationButtonTitles(status: "deleted")
        } else {
            thisRec!.updateStatus(newStatus: "active")
            recStatusLabel.text = "Status: active"
            deleteButton.setTitle("Delete", for: .normal)
            moveButton.isHidden = false
            setLocationButtonTitles(status: "active")
        }
        dismissConfirmationOptions()
    }
    
    @IBOutlet weak var confirmationDeleteButton: UIButton!
    
    @IBOutlet var confirmationView: UIView!
    
    ///////////////////////////////////////////
    func dismissConfirmationOptions() {
        UIView.animate(withDuration: 0.3, animations: {
            self.confirmationView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
            self.confirmationView.alpha = 0
        }) { (success: Bool) in
            self.confirmationView.removeFromSuperview()
        }
    }
    
    func presentConfirmationOptions() {
        confirmationDeleteButton.setTitle(deleteButton.titleLabel!.text!, for: .normal)
        self.view.addSubview(confirmationView)
        confirmationView.center = self.view.center
        confirmationView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
        confirmationView.alpha = 0
        UIView.animate(withDuration: 0.4) {
            self.confirmationView.alpha = 1
            self.confirmationView.transform = CGAffineTransform.identity
        }
    }
    ///////////////////////////////////////////
    
    func setLocationButtonTitles(status: String) {
        if (status == "deleted") {
            deleteButton.setTitle("Reactivate", for: .normal)
            moveButton.isHidden = true
        } else {
            moveButton.isHidden = false
            deleteButton.setTitle("Delete", for: .normal)
            if (status == "active") {
                location1Button.setTitle("booked", for: .normal)
                location2Button.setTitle("declined", for: .normal)
            } else if (status == "booked") {
                location1Button.setTitle("active", for: .normal)
                location2Button.setTitle("declined", for: .normal)
            } else {
                location1Button.setTitle("booked", for: .normal)
                location2Button.setTitle("active", for: .normal)
            }
        }
    }
    
    @IBOutlet weak var moveButton: UIButton!
    
    @IBOutlet weak var deleteButton: UIButton!
    
    //////////////////////////////
    func dismissOptions() {
        UIView.animate(withDuration: 0.3, animations: {
            self.moveOptionsView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
            self.moveOptionsView.alpha = 0
        }) { (success: Bool) in
            self.moveOptionsView.removeFromSuperview()
        }
    }
    
    func presentOptions() {
        self.view.addSubview(moveOptionsView)
        moveOptionsView.center = self.view.center
        moveOptionsView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
        moveOptionsView.alpha = 0
        UIView.animate(withDuration: 0.4) {
            self.moveOptionsView.alpha = 1
            self.moveOptionsView.transform = CGAffineTransform.identity
        }
    }    /////////////////////////////
    
    @IBAction func move(_ sender: Any) {
        presentOptions()
    }
    
    @IBAction func deleteRec(_ sender: Any) {
        presentConfirmationOptions()
    }
    
    @IBAction func cancelMove(_ sender: Any) {
        dismissOptions()
    }
    
    @IBOutlet weak var location2Button: UIButton!
    
    @IBOutlet weak var location1Button: UIButton!
    
    @IBAction func location1Move(_ sender: Any) {
        thisRec!.updateStatus(newStatus: location1Button.titleLabel!.text!)
        thisRec!.isQueued = false
        if callQueue.contains(thisRec!) {
            callQueue.remove(at: callQueue.index(of: thisRec!)!)
        }
        recStatusLabel.text = "Status: " + location1Button.titleLabel!.text!
        setLocationButtonTitles(status: location1Button.titleLabel!.text!)
        dismissOptions()
    }
    
    @IBAction func location2Move(_ sender: Any) {
        thisRec!.updateStatus(newStatus: location2Button.titleLabel!.text!)
        thisRec!.isQueued = false
        if callQueue.contains(thisRec!) {
            callQueue.remove(at: callQueue.index(of: thisRec!)!)
        }
        recStatusLabel.text = "Status: " + location2Button.titleLabel!.text!
        setLocationButtonTitles(status: location2Button.titleLabel!.text!)
        dismissOptions()
    }

   

    override func viewDidLoad() {
        super.viewDidLoad()
        
        var statusToDisplay : String
        
        if thisRec?.status == nil {
            statusToDisplay = "active"
        } else {
            statusToDisplay = thisRec!.status
            if statusToDisplay == "" {
                statusToDisplay = "active"
            }
        }
        
        setLocationButtonTitles(status: statusToDisplay)
        
        recStatusLabel.text = "Status: " + statusToDisplay
        
        let lastNameToDisplay : String
        
        if thisRec?.lastName == nil {
            lastNameToDisplay = ""
        } else {
            lastNameToDisplay = (thisRec?.lastName!)!
        }

        // Do any additional setup after loading the view.
        recNameTextLabel.text = thisRec!.firstName + " " + lastNameToDisplay
        
        let referrerToDisplay : String
        
        if thisRec!.referrer == nil {
            referrerToDisplay = ""
        } else {
            referrerToDisplay = thisRec!.referrer!
        }
        
        referredByTextLabel.text = "Referred By: " + referrerToDisplay
        
        var phoneNumberString = String(thisRec!.phoneNumber)
        let start = phoneNumberString.startIndex
        phoneNumberString.insert("(", at: start)
        phoneNumberString.insert(")", at : phoneNumberString.index(start, offsetBy: 4))
        phoneNumberString.insert("-", at: phoneNumberString.index(start, offsetBy: 5))
        phoneNumberString.insert("-", at: phoneNumberString.index(start, offsetBy: 9))
        
        phoneNumberTextLabel.text = phoneNumberString
        
        ratingTextLabel.text = "Gear: " + String(thisRec!.rating) + "/4"
        
        let noteToDisplay : String
        
        if (thisRec!.note == nil) {
            noteToDisplay = ""
        } else {
            noteToDisplay = thisRec!.note!
        }
        
        noteTextView.text = noteToDisplay
        
    }
    
    @IBOutlet weak var referredByTextLabel: UILabel!
    
    @IBOutlet weak var recNameTextLabel: UILabel!
    
    @IBOutlet weak var phoneNumberTextLabel: UILabel!
  
    
    @IBOutlet weak var ratingTextLabel: UILabel!
    
    @IBOutlet weak var noteTextView: UITextView!
    
    
    @IBAction func goBack(_ sender: Any) {
        thisRec?.note = noteTextView.text
        thisRec = nil
        performSegue(withIdentifier: "backToHomeScreen", sender: self)
    }
    
    @IBAction func editRec(_ sender: Any) {
        thisRec?.note = noteTextView.text
        performSegue(withIdentifier: "toEditScreen", sender: self)
    }
    
    @IBOutlet weak var edit: UIButton!
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
