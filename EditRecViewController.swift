//
//  EditRecViewController.swift
//  Phone Jam App
//
//  Created by Joseph Jordan on 3/12/18.
//  Copyright © 2018 Joseph Jordan. All rights reserved.
//

import UIKit
import Firebase

class EditRecViewController: UIViewController, UITextFieldDelegate{
    
    @IBOutlet weak var firstNameTextField: UITextField!
    
    @IBOutlet weak var lastNameTextField: UITextField!
    
    @IBOutlet weak var referredByTextField: UITextField!
    
    @IBOutlet weak var ratingTextField: UITextField!
    
    @IBOutlet weak var noteTextView: UITextView!

    @IBOutlet weak var phoneNumberTextField: UITextField!
    
    @IBAction func save(_ sender: Any) {
        
        let phoneNumberString = phoneNumberTextField.text
        let ratingString = ratingTextField.text
        let firstNameString = firstNameTextField.text
        let referrerString = referredByTextField.text
        let noteString = noteTextView.text
        let lastNameString = lastNameTextField.text
        
        var validSave = true
        
        if phoneNumberString == nil || ratingString == nil || firstNameString == nil || firstNameString == "" {
            validSave = false
            statusLabel.text = "invalid save"
        } else {
            
            if let _ = Int(phoneNumberString!) {
            } else {
                validSave = false
            }
            if phoneNumberString!.count != 10 {
                validSave = false
            }
            if let ratingInt = Int(ratingString!) {
                if ratingInt < 1 || ratingInt > 4 {
                    validSave = false
                }
            } else {
                validSave = false
            }
            
            if thisRec != nil {
                if (validSave) {
                    thisRec!.firstName = firstNameString!
                    thisRec!.lastName = lastNameString!
                    thisRec!.referrer = referrerString!
                    thisRec!.note = noteString!
                    thisRec!.rating = Int(ratingString!)!
                    thisRec!.phoneNumber = Int(phoneNumberString!)!
                    
                    let ref = Database.database().reference()
                    
                    let recRef = ref.child("reps").child(user).child(thisRec!.ID!)
                    recRef.child("firstName").setValue(firstNameString)
                    recRef.child("lastName").setValue(lastNameString)
                    recRef.child("referrer").setValue(referrerString)
                    recRef.child("note").setValue(noteString)
                    recRef.child("rating").setValue(ratingString)
                    recRef.child("phoneNumber").setValue(phoneNumberString)
                    performSegue(withIdentifier: "backToRecScreen", sender: self)
                }
            } else {
                if (validSave) {
                    recs.append(Rec(firstName: firstNameString!, lastName: lastNameString!, referrer: referrerString!, rating: Int(ratingString!)!, note: noteString!, phoneNumber: Int(phoneNumberString!)!, ID: String(numRecs), status: "active"))
                    let ref = Database.database().reference()
                    
                    let userRef = ref.child("reps").child(user)
                    let recRef = userRef.child(String(numRecs))
                    recRef.child("firstName").setValue(firstNameString)
                    recRef.child("lastName").setValue(lastNameString)
                    recRef.child("referrer").setValue(referrerString)
                    recRef.child("note").setValue(noteString)
                    recRef.child("rating").setValue(ratingString)
                    recRef.child("phoneNumber").setValue(phoneNumberString)
                    numRecs += 1
                    userRef.child("numRecs").setValue(String(numRecs))
                    recs.sort(by: HomeViewController.sortByLastName(lhs:rhs:))
                    performSegue(withIdentifier: "fromEditToHome", sender: self)
                }
            }
            
            if !validSave {
                statusLabel.text = "invalid save"
            }
        }
    }
    
    @IBOutlet weak var statusLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        statusLabel.text = "*Required"
        
        if thisRec != nil {
        firstNameTextField.text = thisRec!.firstName
        
        lastNameTextField.text = thisRec!.lastName
        
        referredByTextField.text = thisRec!.referrer
        
        phoneNumberTextField.text = String(thisRec!.phoneNumber)
        
        ratingTextField.text = String(thisRec!.rating)
        
        noteTextView.text = thisRec?.note
            
        } else {
            ratingTextField.text = "2"
        }
        
        phoneNumberTextField.delegate = self
        // Do any additional setup after loading the view.
        //print("view did load")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancel(_ sender: Any) {
        if (thisRec == nil) {
            performSegue(withIdentifier: "fromEditToHome", sender: self)
        } else {
            performSegue(withIdentifier: "backToRecScreen", sender: self)
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        moveTextField(textField: phoneNumberTextField, moveDistance: -225, up: true)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        moveTextField(textField: phoneNumberTextField, moveDistance: -225, up: false)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func moveTextField(textField: UITextField, moveDistance: Int, up: Bool) {
        let moveDuration = 0.3
        let movement: CGFloat = CGFloat(up ? moveDistance : -moveDistance)
        print("the move function was triggered")
        UIView.beginAnimations("animateTextField", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(moveDuration)
        self.view.frame.origin.y += movement
        UIView.commitAnimations()
    }
    

}
