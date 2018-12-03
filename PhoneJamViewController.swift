//
//  PhoneJamViewController.swift
//  Phone Jam App
//
//  Created by Joseph Jordan on 5/26/18.
//  Copyright © 2018 Joseph Jordan. All rights reserved.
//

import UIKit
import Firebase
import MessageUI

class PhoneJamViewController: UIViewController, MFMessageComposeViewControllerDelegate {
    
    var demosBooked = 0;
    var callBacks = 0;
    var noThanks = 0;
    var callsMade = 0;
    var reached = 0;
    var countdown = 10;
    var paused = false;
    var shouldBreak = false;
    var cancelButton = UIButton()
    var utilityButton = UIButton()
    var utilityTextView = UITextView()
    let finish = " thought you might be nice enough to help me out with something I'm doing for school. Give me a quick call when you can! :)"
    var unreached = false
    
    func activateSecondaryOptions() {
        var utilityButtonTitle = ""
        var cancelButtonTitle = ""
        var textViewText = ""
        if (unreached) {
            utilityButtonTitle = "Send Text"
            cancelButtonTitle = "Don't Send"
        } else {
            if let note = callQueue[0].note as String? {
                textViewText = "call back after: INSERT DATE" + "\n" + note
            } else {
                textViewText = "call back after: INSERT DATE"
            }
            utilityButtonTitle = "Save Note"
            cancelButtonTitle = "Dont Save"
        }
        demoBookedButton.isHidden = true
        callBackButton.isHidden = true
        noThanksButton.isHidden = true
        unreachedButton.isHidden = true
        utilityButton.setTitle(utilityButtonTitle, for: .normal)
        cancelButton.setTitle(cancelButtonTitle, for: .normal)
        utilityTextView.text = textViewText
        utilityButton.isHidden = false
        cancelButton.isHidden = false
        if (!unreached) {
            utilityTextView.isHidden = false
        }
    }
    
    func setUpSecondaryOptions() {
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.setTitleColor(UIColor.blue, for: .normal)
        utilityButton.setTitleColor(UIColor.blue, for: .normal)
        cancelButton.frame = CGRect(x: 0, y: optionsView.frame.height * 3 / 4, width: optionsView.frame.width / 2, height: optionsView.frame.height / 4)
        utilityButton.frame = CGRect(x: optionsView.frame.width / 2, y: optionsView.frame.height * 3 / 4, width: optionsView.frame.width / 2, height: optionsView.frame.height / 4)
        cancelButton.addTarget(self, action: #selector(handleCancelTouch), for: .touchUpInside)
        utilityButton.addTarget(self, action: #selector(handleUtilityTouch), for: .touchUpInside)
        optionsView.addSubview(cancelButton)
        optionsView.addSubview(utilityButton)
        cancelButton.isHidden = true
        utilityButton.isHidden = true
        utilityTextView.backgroundColor = UIColor.lightGray
        utilityTextView.frame = CGRect(x: 0, y: 0, width: Int(optionsView.frame.width), height: Int(optionsView.frame.height * 3 / 4))
        optionsView.addSubview(utilityTextView)
        utilityTextView.isHidden = true
    }
    
    func getDate() -> String {
        let str = Date().description
        return str.substring(to: str.index(str.startIndex, offsetBy: 10))
    }
    
    func updateNote(entry: String) {
        var newNote = ""
        if let currentNote = callQueue[0].note as String? {
            newNote =  entry + "\n" + currentNote
        } else {
            newNote = entry
        }
        let ref = Database.database().reference()
        ref.child("reps").child(user).child(callQueue[0].ID!).child("note").setValue(newNote)
        notesTextView.text = newNote
        callQueue[0].note = newNote
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        if (result == MessageComposeResult.sent) {
            updateNote(entry: getDate() + ": sent text")
        }
        self.dismiss(animated: true, completion: nil)
        cancelButton.isHidden = true
        utilityButton.isHidden = true
        utilityTextView.isHidden = true
        UIView.animate(withDuration: 0.3, animations: {
            self.optionsView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
            self.optionsView.alpha = 0
            self.visualEffect.effect = nil
        }) { (success: Bool) in
            self.optionsView.removeFromSuperview()
            self.xPositionOfEffectView.constant = 1000
            self.paused = false
            self.showButtons()
            //self.next()
            callQueue[0].isQueued = false
            callQueue.remove(at: 0)
            self.callsMade += 1
            if (callQueue.count == 0) {
                self.populateLabels()
                self.paused = true
            } else {
                self.countdown = 10;
                self.populateLabels()            }
        }
    }
    
    func handleUtilityTouch() {
        if (unreached) {
            
            //send text
            if (MFMessageComposeViewController.canSendText()) {
                let controller = MFMessageComposeViewController()
                let string1 = "Hi " + callQueue[0].firstName + " this is " + user
                var string2 = ""
                if var referrer = callQueue[0].referrer as String? {
                    if (referrer == "") {
                        referrer = "I"
                    }
                    string2 = ". I just had a quick question for you. " + referrer
                } else {
                    string2 = ". I just had a quick question for you. I"
                }
                controller.body =  string1 + string2 + finish
                controller.recipients = [String(callQueue[0].phoneNumber)]
                controller.messageComposeDelegate = self
                self.present(controller, animated: true, completion: nil)
            } else {
                updateNote(entry: getDate() + ": unable to send text")
                handleCancelTouch()
            }
        } else {
            var newNote = ""
            if let text = utilityTextView.text as String? {
                newNote = text
            } else {
                newNote = ""
            }
            callQueue[0].note = ""
            updateNote(entry: newNote)
            handleCancelTouch()
        }
    }
    
    func handleCancelTouch() {
        cancelButton.isHidden = true
        utilityButton.isHidden = true
        utilityTextView.isHidden = true
        dismissOptions()
    }
    
    @IBAction func panPerformed(_ sender: UIPanGestureRecognizer) {
        
        
    }
    
    @IBOutlet var optionsView: UIView!
    
    @IBAction func demoBooked(_ sender: Any) {
        demosBooked += 1
        reached += 1
        unreached = false
        updateNote(entry: getDate() + ": demo booked")
        callQueue[0].updateStatus(newStatus: "booked")
        dismissOptions()
    }
    
    @IBAction func unreached(_ sender: Any) {
        unreached = true
        activateSecondaryOptions()
        //dismissOptions()
    }
    
    @IBAction func noThanks(_ sender: Any) {
        unreached = false
        updateNote(entry: getDate() + ": decline")
        reached += 1
        noThanks += 1
        callQueue[0].updateStatus(newStatus: "declined")
        dismissOptions()
    }
  
    @IBAction func callBack(_ sender: Any) {
        unreached = false
        activateSecondaryOptions()
        reached += 1
        callBacks += 1
        //dismissOptions()
    }
    
    func dismissOptions() {
        UIView.animate(withDuration: 0.3, animations: {
            self.optionsView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
            self.optionsView.alpha = 0
            self.visualEffect.effect = nil
        }) { (success: Bool) in
            self.optionsView.removeFromSuperview()
            self.xPositionOfEffectView.constant = 1000
            self.paused = false
            self.showButtons()
            self.next()
        }
    }
    
    func presentOptions() {
        paused = true
        hideButtons()
        self.view.addSubview(optionsView)
        optionsView.center = self.view.center
        optionsView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
        optionsView.alpha = 0
        xPositionOfEffectView.constant = 0
        callBackButton.isHidden = false
        unreachedButton.isHidden = false
        noThanksButton.isHidden = false
        demoBookedButton.isHidden = false
        UIView.animate(withDuration: 0.4) {
            self.visualEffect.effect = self.effect
            self.optionsView.alpha = 1
            self.optionsView.transform = CGAffineTransform.identity
        }
    }
    
    
    
    /*=============OUTLET CONNECTIONS====================*/
    @IBOutlet weak var visualEffect: UIVisualEffectView!
    
    var effect : UIVisualEffect!
    
    @IBOutlet weak var callsMadeLabel: UILabel!
    
    @IBOutlet weak var demosBookedLabel: UILabel!
    
    @IBOutlet weak var callBacksLabel: UILabel!
    
    @IBOutlet weak var noThanksLabel: UILabel!
    
    @IBOutlet weak var countdownLabel: UILabel!
    
    @IBOutlet weak var onDeckLabel: UILabel!
    
    @IBOutlet weak var callsQueuedLabel: UILabel!
    
    @IBOutlet weak var endJamButton: UIButton!
    
    @IBOutlet weak var pauseButton: UIButton!
    
    @IBOutlet weak var notesTextView: UITextView!
    
    @IBOutlet weak var numberOfStarsLabel: UILabel!
    
    @IBOutlet weak var phoneImage: UIImageView!
    @IBOutlet weak var referredBy: UILabel!
    
    @IBOutlet weak var nextRecView: UIView!
    
    @IBOutlet weak var sendButton: UIButton!
    
    @IBOutlet weak var skipButton: UIButton!
    
    @IBOutlet weak var demoBookedButton: UIButton!
    
    @IBOutlet weak var unreachedButton: UIButton!
    
    @IBOutlet weak var noThanksButton: UIButton!
    
    @IBOutlet weak var callBackButton: UIButton!
    
    let swipeLeft = UISwipeGestureRecognizer()
    
    let swipeRight = UISwipeGestureRecognizer()
    @IBOutlet weak var xPositionOfEffectView: NSLayoutConstraint!
    /*=============FILE CODE==============================*/
    
    func populateLabels() {
        if (callQueue.count == 0) {
            phoneImage.isHidden = true
            nextRecView.isHidden = true
            hideButtons()
            callsQueuedLabel.text = "Jam Completed"
            callsMadeLabel.text = "Calls Made: " + String(callsMade) + "\t" + "Reached: " + String(reached)
            demosBookedLabel.text = "Demos Booked: " + String(demosBooked)
            callBacksLabel.text = "Call Backs: " + String(callBacks)
            noThanksLabel.text = "No Thanks: " + String(noThanks)
            countdownLabel.text = ""
            onDeckLabel.text = ""
            referredBy.text = ""
            notesTextView.text = ""
            numberOfStarsLabel.text = ""
            self.nextRecView.alpha = 0
        } else {
            phoneImage.isHidden = false
            callsQueuedLabel.text = "Calls Queued: " + String(callQueue.count)
        
            countdownLabel.text = String(countdown)
        
            if let lastName = callQueue[0].lastName as String? {
                onDeckLabel.text = "On Deck: " + callQueue[0].firstName + " " + lastName
            } else {
                onDeckLabel.text = "On Deck: " + callQueue[0].firstName
            }
        
            callsMadeLabel.text = "Calls Made: " + String(callsMade) + "\t" + "Reached: " + String(reached)
            demosBookedLabel.text = "Demos Booked: " + String(demosBooked)
            callBacksLabel.text = "Call Backs: " + String(callBacks)
            noThanksLabel.text = "No Thanks: " + String(noThanks)
            if let referrer = callQueue[0].referrer as String? {
                referredBy.text = "Referred By: " + referrer
            } else {
                referredBy.text = "Referred By: "
            }
            if let notes = callQueue[0].note as String? {
                notesTextView.text = notes
            }
            if let rating = String(callQueue[0].rating) as String? {
                numberOfStarsLabel.text = rating
            } else {
                numberOfStarsLabel.text = "n/a"
            }
        }
    }
    
    @IBAction func pause(_ sender: Any) {
        paused = !paused
        if (paused) {
            pauseButton.setTitle("Resume", for: .normal)
            DispatchQueue.global().suspend()
        } else {
            pauseButton.setTitle("Pause", for: .normal)
            DispatchQueue.global().resume()
        }
    }
    
    func hideButtons() {
        sendButton.isHidden = true
        skipButton.isHidden = true
    }
    
    func showButtons() {
        sendButton.isHidden = false
        skipButton.isHidden = false
    }
    
    func handleTimer() {
        DispatchQueue.global().async {
            while (self.countdown > 0) {
                //dont countdown when paused
                if (self.paused) {
                    while (self.paused) {
                        if (self.shouldBreak) {
                            break;
                        }
                    }
                    if (self.shouldBreak) {
                        break;
                    }
                } else {
                    sleep(1)
                }
                if (self.shouldBreak) {
                    break;
                }
                while (self.paused) {
                    if (self.shouldBreak) {
                        break;
                    }
                }
                self.countdown = self.countdown - 1
                if (!self.shouldBreak) {
                    DispatchQueue.main.async {
                        self.countdownLabel.text = String(self.countdown)
                    }
                    if (self.countdown == 0) {
                        sleep(1)
                    }                }
            }
            if (!self.shouldBreak) {
                DispatchQueue.main.async {
                    self.makeCall()
                }
            } else {
                self.shouldBreak = false
            }
        }
    }
    
    func makeCall() {
        if (callQueue.count > 0) {
            let number : NSURL = URL(string: "tel://" + String(callQueue[0].phoneNumber))! as NSURL
                
            UIApplication.shared.open(number as URL, options: [:], completionHandler: {(success) in
                self.presentOptions()
            })
        }
    }
    
    @IBAction func endJam(_ sender: Any) {
        for rec in callQueue {
            rec.isQueued = false
        }
        callQueue = []
        performSegue(withIdentifier: "endJamToHomeScreen", sender: self)
    }
    
    func next() {
        callQueue[0].isQueued = false
        callQueue.remove(at: 0)
        callsMade += 1
        if (callQueue.count == 0) {
            populateLabels()
            paused = true
        } else {
            countdown = 10;
            populateLabels()
            handleTimer()
        }
    }
    
    @IBAction func skip(_ sender: Any) {
        slideViewRight()
    }
    
    @IBAction func send(_ sender: Any) {
        slideViewLeft()
    }
    
    func send() {
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        countdown = 10
        // Do any additional setup after loading the view.
        populateLabels()
        
        swipeLeft.direction = UISwipeGestureRecognizerDirection.left
        swipeLeft.addTarget(self, action: #selector(slideViewLeft))
        self.nextRecView.addGestureRecognizer(swipeLeft)
        
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        swipeRight.addTarget(self, action: #selector(slideViewRight))
        self.nextRecView.addGestureRecognizer(swipeRight)
        
        effect = visualEffect.effect
        visualEffect.effect = nil
        optionsView.layer.cornerRadius = 5
        xPositionOfEffectView.constant = 1000
        setUpSecondaryOptions()
        
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        handleTimer()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func slideViewRight() {
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveLinear, animations: {
            self.nextRecView.layoutIfNeeded()
            self.phoneImage.isHidden = true                //self.pinOffScreen.priority = self.pinOnScreen.priority - 1
            self.nextRecView.layer.transform = CATransform3DMakeTranslation(500, 0, 0)
        }, completion: { (success) in
            self.shouldBreak = true
            self.populateLabels()
            let rec = callQueue[0]
            callQueue.insert(rec, at: callQueue.count)
            callQueue.remove(at: 0)
            self.nextRecView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            self.nextRecView.layer.transform = CATransform3DMakeTranslation(-500, 0, 0)
            self.nextRecView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            self.shouldBreak = false;
            self.countdown = 10
            self.populateLabels()
            self.phoneImage.isHidden = false
        })
    }
    
    func slideViewLeft() {
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveLinear, animations: {
            self.nextRecView.layoutIfNeeded()
            //self.pinOffScreen.priority = self.pinOnScreen.priority - 1
            self.nextRecView.layer.transform = CATransform3DMakeTranslation(-250, 0, 0)
        }, completion: { (success) in
            self.nextRecView.layer.transform =
                CATransform3DMakeTranslation(0, 0, 0)
            self.shouldBreak = true
            self.makeCall()
        })
    }
    
    @IBOutlet weak var pinOffScreen: NSLayoutConstraint!

    @IBOutlet weak var pinOnScreen: NSLayoutConstraint!
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
