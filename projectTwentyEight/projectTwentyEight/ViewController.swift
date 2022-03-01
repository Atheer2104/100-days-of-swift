//
//  ViewController.swift
//  projectTwentyEight
//
//  Created by Atheer on 2019-06-23.
//  Copyright © 2019 Atheer. All rights reserved.
//

import LocalAuthentication
import UIKit

class ViewController: UIViewController {
    @IBOutlet var secret: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Nothing to see here"
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        // we will call function saveSecretMessage when we leave the app or when
        // go into multitask
        notificationCenter.addObserver(self, selector: #selector(saveSecretMessage), name: UIApplication.willResignActiveNotification, object: nil)
        
        
    }

    @IBAction func authenticateTapped(_ sender: Any) {
        let context = LAContext()
        // NSError type is object c type of error in swift
        // LocalAuthentication is on objective C
        var error: NSError?
        
        // can we try to use face id or touch id to authenticate the user
        // ie the user has setup face id or touch id
        // &error we are telling don't pass in error, pass in where that value is
        // in ram, then it can be overwritten with a new value which is our error
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            // will only be shown to people using touchid
            // need to identify reason in info.plist for face id  
            let reason = "Identify yourself!"
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) {
                // we will get back to values succes and error
                [weak self] succes, authenticationError in
                
                DispatchQueue.main.async {
                    if succes {
                        self?.unlockSecretMessage()
                    } else {
                        // error
                        let ac = UIAlertController(title: "Authentication failed", message: "You could not be verified: please try again.", preferredStyle: .alert)
                        ac.addAction(UIAlertAction(title: "Okay", style: .default))
                        self?.present(ac, animated: true)
                    }
                }
                
            }
        } else {
            // no biometric ie no touch id etc.
            let ac = UIAlertController(title: "Biometry unavailable" , message: "Your device is nor configured for biometrics authentication", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Okay", style: .default))
             present(ac, animated: true)
        }
        
    }
    
    @objc func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        
        // size of keyboard relative to screen and not view
        let keyboardScreenEnd = keyboardValue.cgRectValue
        // taking account of rotation of keyboard
        let keyboardViewEndFrame = view.convert(keyboardScreenEnd, from: view.window)
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            secret.contentInset = .zero
        } else {
            secret.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
        }
    
        secret.scrollIndicatorInsets = secret.contentInset
        
        let selectedRange = secret.selectedRange
        secret.scrollRangeToVisible(selectedRange)
    
    
    }
    
    func unlockSecretMessage() {
        secret.isHidden = false
        title = "Secret stuff!"
        
        // get string from key if not found then return empyy string
        // using keychains more secure than userdefault however using
        // third party to make it easy to use it becomes like userdefault syntax
        secret.text = KeychainWrapper.standard.string(forKey: "SecretMessage") ?? ""
        
    }
    
    
    @objc func saveSecretMessage() {
        // making sure secret ie textview is visible
        guard secret.isHidden == false else { return }
        
        KeychainWrapper.standard.set(secret.text, forKey: "SecretMessage")
        // making textview unresponsive
        secret.resignFirstResponder()
        secret.isHidden = true
        title = "Nothing to see here"
        
        
    }
    
}

