//
//  Rec.swift
//  Phone Jam App
//
//  Created by Joseph Jordan on 3/10/18.
//  Copyright © 2018 Joseph Jordan. All rights reserved.
//

import UIKit
import Firebase

class Rec: NSObject {
    
    var firstName : String
    var lastName : String?
    var referrer : String?
    var rating : Int
    var phoneNumber : Int
    var note: String?
    var isQueued = false
    var ID : String?
    var status: String
    
    
    init(firstName : String, lastName: String, referrer : String, rating: Int, note : String, phoneNumber : Int, ID : String, status: String) {
        self.firstName = firstName
        self.lastName = lastName
        self.referrer = referrer
        self.rating = rating
        self.note = note
        self.phoneNumber = phoneNumber
        self.ID = ID
        self.status = status
    }
    
    func updateStatus(newStatus: String) {
        if self.status == newStatus {
            return
        } else {
            Database.database().reference().child("reps").child(user).child(self.ID!).child("status").setValue(newStatus)
            
            if newStatus == "" || newStatus == "active" {
                recs.append(self)
            } else if newStatus == "declined" {
                declined.append(self)
            } else if newStatus == "booked" {
                booked.append(self)
            } else {
                deleted.append(self)
            }
            
            if status == "" || status == "active" {
                recs.remove(at: recs.index(of: self)!)
            } else if status == "declined" {
                declined.remove(at: declined.index(of: self)!)
            } else if status == "booked" {
                booked.remove(at: booked.index(of: self)!)
            } else {
                deleted.remove(at: deleted.index(of: self)!)
            }
            status = newStatus
        }
    }
}

