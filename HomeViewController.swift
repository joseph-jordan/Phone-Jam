//
//  HomeViewController.swift
//  Phone Jam App
//
//  Created by Joseph Jordan on 3/7/18.
//  Copyright © 2018 Joseph Jordan. All rights reserved.
//

import UIKit
import Contacts

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource, UISearchBarDelegate {
    
    @IBOutlet weak var importContactsButton: UIButton!
    
    @IBAction func importContacts(_ sender: Any) {
        requestContacts()
    }
    
    func requestContacts() {
        let store = CNContactStore()
        store.requestAccess(for: .contacts) { (granted, error) in
            if let err = error {
                print("encounted error requesting access to contacts", err)
                return
            }
            
            if (granted) {
                print("try")
                let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey, CNContactNoteKey]
                let request = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])
                do {
                    try store.enumerateContacts(with: request, usingBlock: { (contact, stopPointer) in
                        if (contact.phoneNumbers.count > 0) {
                           if let number = (contact.phoneNumbers[0].value ).value(forKey: "digits") as? String {
                                if (!SignInViewController.isMatch(firstName: contact.givenName, lastName: contact.familyName)) {
                                    let rec = Rec(firstName: contact.givenName, lastName: contact.familyName, referrer: "", rating: 2, note: contact.note, phoneNumber: Int(number)!, ID: "0", status: "imported")
                                    contacts.append(rec)
                                }
                            }
                        } else {
                            print("contact had no number")
                        }
                    })
                }
                catch _ {
                    print("failed to enumerate contacts")
                    return
                }
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "toContactImporter", sender: self)
                }
            } else {
                return
            }
        }
    }
    
    let locations = ["Home", "Declined", "Booked", "Deleted"]
    var loc = "Home"
    var effect : UIVisualEffect!
    let sorts = [HomeViewController.sortByLastName, HomeViewController.sortByReferrer, HomeViewController.sortByGear]
    var sortsIndex = 1
    
    var isSearching = false
    
    var filteredRecs = [Rec]()
    
    @IBAction func changeList(_ sender: Any) {
        presentPickerView()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text == nil || searchBar.text == "" {
            isSearching = false
            view.endEditing(true)
            tableView.reloadData()
        } else {
            isSearching = true
            filteredRecs = getSource().filter({
                if ($0.lastName != nil && $0.lastName != "") {
                    return $0.firstName.contains(searchBar.text!) || $0.lastName!.contains(searchBar.text!)
                } else {
                    return $0.firstName.contains(searchBar.text!)                }
            })
            tableView.reloadData()
        }
    }
    
    func dismissPickerView() {
        UIView.animate(withDuration: 0.3, animations: {
            self.pickerView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
            self.pickerView.alpha = 0
            self.visualEffectView.effect = nil
            self.importContactsButton.isHidden = false
        }) { (success: Bool) in
            self.pickerView.removeFromSuperview()
            self.xAlign.constant = 1000
        }
    }
    
    @IBOutlet weak var xAlign: NSLayoutConstraint!
    
    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    
    func presentPickerView() {
        self.view.addSubview(pickerView)
        pickerView.center = self.view.center
        pickerView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
        pickerView.alpha = 0
        xAlign.constant = 0
        self.importContactsButton.isHidden = true
        UIView.animate(withDuration: 0.4) {
            self.pickerView.alpha = 1
            self.pickerView.transform = CGAffineTransform.identity
            self.visualEffectView.effect = self.effect
        }
    }
    
    func getSource() -> [Rec] {
        if loc == "Home" {
            return recs
        } else if loc == "Declined" {
            return declined
        } else if loc == "Booked" {
            return booked
        } else {
            return deleted
        }
    }
    
    @IBOutlet var pickerView: UIPickerView!
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return locations[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 4
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        loc = locations[row]
        tableView.reloadData()
        if loc == "Home" {
            jamButton.isHidden = false
            addRecButton.isHidden = false
            numberQueuedLabel.isHidden = false
        } else {
            jamButton.isHidden = true
            addRecButton.isHidden = true
            numberQueuedLabel.isHidden = true
        }
        dismissPickerView()
    }
    
    @IBAction func logout(_ sender: Any) {
        resetGlobals()
        performSegue(withIdentifier: "toSignInScreen", sender: self)
    }
    
    @IBOutlet weak var addRecButton: UIButton!
    @IBOutlet weak var jamButton: UIButton!
    
    func resetGlobals() {
        user = ""
        repNumber = ""
        numberOfReps = 0
        firstSignIn = false
        recs = []
        referrers = []
        callQueue = []
        numRecs = 0
        
        thisRec = nil
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (isSearching) {
            return filteredRecs.count
        } else {
            return getSource().count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //print("WE HAVE ENTERED THE DELEGATION FUNCTION")
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "recCell", for: indexPath) as! RecTableViewCell
        
        let currentRec : Rec
        
        if (isSearching) {
            currentRec = filteredRecs[indexPath.row]
        } else {
            currentRec = getSource()[indexPath.row]
        }
        
        cell.rec = currentRec
        cell.homeVCInstance = self
        
        if currentRec.isQueued {
            cell.backgroundColor = UIColor.init(red: 224 / 255.0, green: 220 / 255.0, blue: 66 / 255.0, alpha: 1.0)
        } else {
            cell.backgroundColor = UIColor.white
        }
        
        let lastNameToDisplay : String
        
        if currentRec.lastName == nil {
            lastNameToDisplay = ""
        } else {
            lastNameToDisplay = currentRec.lastName!
        }
            cell.recNameLabel.text = currentRec.firstName + " " + lastNameToDisplay
        var currentRef = ""
        if let ref = currentRec.referrer as String? {
            currentRef = ref
        }
        cell.referredByLabel.text = currentRef
        //format the cell correctly

        return cell
    }
    
    func segueToRecScreen() {
        performSegue(withIdentifier: "toRecScreen", sender: self)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (loc != "Home") {
            return
        }
        let search = isSearching
        let thisRec : Rec
        if (search) {
            thisRec = filteredRecs[indexPath.row]
        } else {
            thisRec = recs[indexPath.row]
        }
        if callQueue.contains(thisRec) {
            thisRec.isQueued = false
            callQueue.remove(at: callQueue.index(of: thisRec)!)
            numberQueuedLabel.text = String(callQueue.count) + " Queued"
        } else {
            if (search) {
                callQueue.append(filteredRecs[indexPath.row])
            } else {
                callQueue.append(recs[indexPath.row])
            }
            thisRec.isQueued = true
            numberQueuedLabel.text = String(callQueue.count) + " Queued"
        }
        tableView.reloadData()
    }
    
    @IBAction func sort(_ sender: Any) {
        recs.sort(by: sorts[sortsIndex % 3])
        declined.sort(by: sorts[sortsIndex % 3])
        booked.sort(by: sorts[sortsIndex % 3])
        deleted.sort(by: sorts[sortsIndex % 3])
        sortsIndex += 1
        tableView.reloadData()
    }
    
    @IBAction func addRec(_ sender: Any) {
        thisRec = nil
        performSegue(withIdentifier: "addRec", sender: self)
    }
    
    static func sortByLastName (lhs: Rec, rhs: Rec) -> Bool {
        var lhsCompare = ""
        var rhsCompare = ""
        
        if lhs.lastName == nil {
            lhsCompare = lhs.firstName
        } else {
            lhsCompare = lhs.lastName!
        }
        
        if rhs.lastName == nil {
            rhsCompare = rhs.firstName
        } else {
            rhsCompare = rhs.lastName!
        }
        
        if lhsCompare == rhsCompare {
            return lhs.firstName < rhs.firstName
        }
        
        return lhsCompare < rhsCompare
    }
    
    static func sortByReferrer (lhs: Rec, rhs: Rec) -> Bool {
        var lhsCompare = lhs.referrer
        var rhsCompare = rhs.referrer
        if (lhsCompare == nil) {
            lhsCompare = ""
        }
        
        if (rhsCompare == nil) {
            rhsCompare = ""
        }
        
        if lhsCompare == rhsCompare {
            return sortByLastName(lhs: lhs, rhs: rhs)
        }
        
        return lhsCompare! < rhsCompare!
    }
    
    static func sortByGear(lhs: Rec, rhs: Rec) -> Bool {
        let lhsCompare = lhs.rating
        let rhsCompare = rhs.rating
        
        if lhsCompare == rhsCompare {
            return sortByLastName(lhs: lhs, rhs: rhs)
        }
        
        return lhsCompare < rhsCompare
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.reloadData()
        effect = visualEffectView.effect
        visualEffectView.effect = nil
        xAlign.constant = 1000
        recs.sort(by: HomeViewController.sortByLastName)
        searchBar.delegate = self
        searchBar.returnKeyType = UIReturnKeyType.done
        // Do any additional setup after loading the view.
    }
    
    @IBOutlet weak var numberQueuedLabel: UILabel!
    
    @IBOutlet weak var searchBar: UISearchBar!

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
    @IBAction func startJam(_ sender: Any) {
        if callQueue.count > 0 {
            performSegue(withIdentifier: "segueToPhoneJam", sender: self)
        }
    }
    
    

    @IBOutlet weak var tableView: UITableView!
    
}
