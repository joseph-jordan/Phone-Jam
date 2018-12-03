//
//  SignInViewController.swift
//  Phone Jam App
//
//  Created by Joseph Jordan on 3/7/18.
//  Copyright © 2018 Joseph Jordan. All rights reserved.
//

var user = ""
var repNumber = ""
var numberOfReps = 0
var firstSignIn = true
var recs : [Rec] = []
var booked : [Rec] = []
var declined : [Rec] = []
var deleted : [Rec] = []
var referrers : [Rec] = []
var callQueue : [Rec] = []
var numRecs = 0
var contacts : [Rec] = []
var thisRec : Rec?
var contactsToAppend : [Rec] = []

import UIKit
import Firebase

class SignInViewController: UIViewController, UITextFieldDelegate {
    
    static func isMatch(firstName: String, lastName: String) -> Bool {
        for r in recs {
            if firstName == r.firstName && lastName == r.lastName {
                return true
            }
        }
        for r in declined {
            if firstName == r.firstName && lastName == r.lastName {
                return true
            }
        }
        for r in booked {
            if firstName == r.firstName && lastName == r.lastName {
                return true
            }
        }
        for r in deleted {
            if firstName == r.firstName && lastName == r.lastName {
                return true
            }
        }
        return false
    }
    
    var ref : DatabaseReference?
    
    var handle : DatabaseHandle?
    
    @IBOutlet weak var statusLabel: UILabel!

    @IBOutlet weak var fullNameTextField: UITextField!
    
    @IBOutlet weak var repNumberTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        repNumberTextField.delegate = self
        /*let mike = Rec(firstName: "Michael", lastName: "Jordan", referrer: "Joann Jordan", rating: 4, note: "famous basketball player", phoneNumber: 2014506073)
        
        let dorine = Rec(firstName: "Dorine", lastName: "Winters", referrer: "Joann Jordan", rating: 3, note: "Already has some Cutco that she loves", phoneNumber: 2015462883)
        
        let dougherty = Rec(firstName: "Coach", lastName: "Dougherty", referrer: "Coach Gregory", rating: 2, note: "Has seen the demo before and didn't buy", phoneNumber: 11111111111)
        
        let arginteanu = Rec(firstName: "Mrs.", lastName: "Arginteanu", referrer: "me", rating: 4, note: "Very wealthy and loves to cook", phoneNumber: 2015411094)
        
        recs = [mike, dorine, dougherty, arginteanu]
        recs.sort(by: HomeViewController.sortByLastName)
 */
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
    
        statusLabel.text = ""
        
        if let defaultName = UserDefaults.standard.object(forKey: "user") as? String {
            fullNameTextField.text = defaultName
            if let defaultRepNumber = UserDefaults.standard.object(forKey: "repNumber") as? String {
                repNumberTextField.text = defaultRepNumber
                user = defaultName
                repNumber = defaultRepNumber
                if (firstSignIn) {
                    firstSignIn = false
                    advance()
                }
            }
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func signInButtonPressed(_ sender: Any) {
        
        var validSignIn = true
        
        // make sure that items were entered
        if repNumberTextField.text != nil || fullNameTextField.text != nil {
        
        
        // make sure rep number entered is 10 digits
        if let repNumberInt = Int(repNumberTextField.text!) {
            if repNumberInt < 10000000 {
                validSignIn = false
            }
            if repNumberInt > 99999999 {
                validSignIn = false
            }
        } else {
            validSignIn = false
        }
        
        ref = Database.database().reference()
        
        ref?.observeSingleEvent(of: .value, with: { (snapshot) in
            if let numberOfRepsString = snapshot.childSnapshot(forPath: "numberOfReps").value as? String {
                if let numberOfRepsInt = Int(numberOfRepsString) {
                    numberOfReps = numberOfRepsInt
                }
            }
            let usedRepNumbersSnap = snapshot.childSnapshot(forPath: "usedRepNumbers")
            var i = 0
            var newRepNumber = true
            while i < numberOfReps {
                let thisRepNumberSnap = usedRepNumbersSnap.childSnapshot(forPath: String(i))
                if let thisRepNumber = thisRepNumberSnap.value as? String {
                    if thisRepNumber == self.repNumberTextField.text {
                        newRepNumber = false
                    }
                }
                i = i + 1
            }
            let usedFullNamesSnap = snapshot.childSnapshot(forPath: "usedFullNames")
            i = 0
            var newFullName = true
            while i < numberOfReps {
                let thisFullNameSnap = usedFullNamesSnap.childSnapshot(forPath: String(i))
                if let thisFullName = thisFullNameSnap.value as? String {
                    if thisFullName == self.fullNameTextField.text {
                        newFullName = false
                    }
                }
                i = i + 1
            }
            
            if (newRepNumber && newFullName && validSignIn) {
                // new rep, we need to create a new spot for them and save their information
                self.ref?.child("reps").child(self.fullNameTextField.text!).child("repNumber").setValue(self.repNumberTextField.text)
                self.ref?.child("usedRepNumbers").child(String(numberOfReps)).setValue(self.repNumberTextField.text!)
                self.ref?.child("usedFullNames").child(String(numberOfReps)).setValue(self.fullNameTextField.text!)
                numberOfReps = numberOfReps + 1
                self.ref?.child("numberOfReps").setValue(String(numberOfReps))
            } else if !newRepNumber && !newFullName && validSignIn {
                // old rep, we need to make sure their credentials match up
                if let correctRepNumber = snapshot.childSnapshot(forPath: "reps").childSnapshot(forPath: self.fullNameTextField.text!).childSnapshot(forPath: "repNumber").value as? String {
                    if correctRepNumber != self.repNumberTextField.text! {
                        validSignIn = false
                    }
                }
            } else {
                validSignIn = false
            }
            
            
            self.handleSignIn(validSignIn: validSignIn)
        })
        }
    }
    
    func advance() {
        ref = Database.database().reference()
        
        ref?.observeSingleEvent(of: .value, with: { (snapshot) in
            if let recsCount = snapshot.childSnapshot(forPath: "reps").childSnapshot(forPath: user).childSnapshot(forPath: "numRecs").value as? String {
                numRecs = Int(recsCount)!
                for i in 0...(numRecs - 1) {
                    let recSnap = snapshot.childSnapshot(forPath: "reps").childSnapshot(forPath: user).childSnapshot(forPath: String(i))
                        let firstName = recSnap.childSnapshot(forPath: "firstName").value as! String
                        let lastName = recSnap.childSnapshot(forPath: "lastName").value as! String
                        let referrer = recSnap.childSnapshot(forPath: "referrer").value as! String
                        let rating = recSnap.childSnapshot(forPath: "rating").value as! String
                        let phoneNumber = recSnap.childSnapshot(forPath: "phoneNumber").value as! String
                        let note = recSnap.childSnapshot(forPath: "note").value as! String
                        var status = ""
                        if let statusActual = recSnap.childSnapshot(forPath: "status").value as? String {
                            status = statusActual
                        }
                        let newRec = Rec(firstName: firstName, lastName: lastName, referrer: referrer, rating: Int(rating)!, note: note, phoneNumber: Int(phoneNumber)!, ID: String(i), status: status)
                    if status == "active" || status == "" {
                        recs.append(newRec)
                    } else if status == "declined" {
                        declined.append(newRec)
                    } else if status == "booked" {
                        booked.append(newRec)
                    } else {
                        deleted.append(newRec)
                    }
                }
            }
            self.performSegue(withIdentifier: "toHomeScreen", sender: self)
        })
    }
    
    func handleSignIn(validSignIn : Bool) {
        
        if validSignIn {
            UserDefaults.standard.set(fullNameTextField.text, forKey: "user")
            UserDefaults.standard.set(repNumberTextField.text, forKey: "repNumber")
            firstSignIn = false
            user = fullNameTextField.text!
            repNumber = repNumberTextField.text!
            advance()
        } else {
            statusLabel.text = "Oops, try again!"
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
        moveTextField(textField: repNumberTextField, moveDistance: -50, up: true)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        moveTextField(textField: repNumberTextField, moveDistance: -50, up: false)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func nameEditingBegan(_ sender: Any) {
        moveTextField(textField: fullNameTextField, moveDistance: -50, up: true)
    }
    
    @IBAction func nameEditingEnded(_ sender: Any) {
        moveTextField(textField: fullNameTextField, moveDistance: -50, up: false)
    }
    
    
    func moveTextField(textField: UITextField, moveDistance: Int, up: Bool) {
        let moveDuration = 0.3
        let movement: CGFloat = CGFloat(up ? moveDistance : -moveDistance)
        //print("the move function was triggered")
        UIView.beginAnimations("animateTextField", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(moveDuration)
        self.view.frame.origin.y += movement
        UIView.commitAnimations()
    }

}
