//
//  ImportContactsViewController.swift
//  Phone Jam App
//
//  Created by Joseph Jordan on 7/4/18.
//  Copyright © 2018 Joseph Jordan. All rights reserved.
//

import UIKit
import Firebase

class ImportContactsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
        /*if (isSearching) {
         return filteredRecs.count
         } else {
         return getSource().count
         }*/
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "contactCell", for: indexPath) as! ContactTableViewCell
        
        /*if (isSearching) {
            currentRec = filteredRecs[indexPath.row]
        } else {
            currentRec = getSource()[indexPath.row]
        }*/
        let currentRec = contacts[indexPath.row]
        
        cell.contact = currentRec
        cell.table = tableView
        
        var lastNameToUse = ""
        
        if let lastName = currentRec.lastName as String? {
            lastNameToUse = lastName
        }
        
        if currentRec.isQueued {
            cell.backgroundColor = UIColor.init(red: 224 / 255.0, green: 220 / 255.0, blue: 66 / 255.0, alpha: 1.0)
        } else {
            cell.backgroundColor = UIColor.white
        }
        
        cell.plusButton.isHidden = true
        //format the cell correctly
        cell.contactNameLabel.text = currentRec.firstName + " " + lastNameToUse
        
        return cell
    }
    
    func segueToRecScreen() {
        performSegue(withIdentifier: "toRecScreen", sender: self)
    }
    
    @IBAction func `import`(_ sender: Any) {
        for cont in contactsToAppend {
            cont.ID = String(recs.count)
            cont.status = "active"
            cont.isQueued = false
            recs.append(cont)
            let ref = Database.database().reference()
            
            let userRef = ref.child("reps").child(user)
            let recRef = userRef.child(String(numRecs))
            recRef.child("firstName").setValue(cont.firstName)
            recRef.child("lastName").setValue(cont.lastName)
            recRef.child("referrer").setValue(cont.referrer)
            recRef.child("note").setValue(cont.note)
            recRef.child("rating").setValue(String(cont.rating))
            recRef.child("phoneNumber").setValue(String(cont.phoneNumber))
            numRecs += 1
            userRef.child("numRecs").setValue(String(numRecs))
            recs.sort(by: HomeViewController.sortByLastName(lhs:rhs:))
        }
        contacts = []
        contactsToAppend = []
        performSegue(withIdentifier: "fromContactImporter", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.reloadData()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let thisRec = contacts[indexPath.row]
        if contactsToAppend.contains(thisRec) {
            thisRec.isQueued = false
            contactsToAppend.remove(at: contactsToAppend.index(of: thisRec)!)
        } else {
            contactsToAppend.append(thisRec)
            thisRec.isQueued = true
        }
        tableView.reloadData()
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
