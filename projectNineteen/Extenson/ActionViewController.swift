//
//  ActionViewController.swift
//  Extenson
//
//  Created by Atheer on 2019-06-10.
//  Copyright © 2019 Atheer. All rights reserved.
//

import UIKit
import MobileCoreServices

class ActionViewController: UIViewController {
    @IBOutlet var script: UITextView!
    
    var pageTitle = ""
    var pageURL = ""
    
    // check info.plist modified it a bit where it should only accept one webpage
    // and acces extension, also made so it runs a javascript file before hand
    // the file is namned Action, swift add the .js after by default
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        
        // notificationCenter is used to check and send
        // state of things
        let notificationCenter = NotificationCenter.default
        // two diffierent observers that observe diffierent things
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        
        // when extension item is created we get extensionContext
        // it controlls how to interact with parent app
        if let inputItem = extensionContext?.inputItems.first as? NSExtensionItem {
            // we get an array of attachments we get the first attachment
            // from the first input item, basically give the very first thing
            // that is shared with us
            if let itemProvider = inputItem.attachments?.first {
                itemProvider.loadItem(forTypeIdentifier: kUTTypePropertyList as String) {
                    // we accept a dictionary and error, the dict contains
                    // what is provided to us 
                    [weak self] (dict, error) in
                    // NSDictionary is like a normal swift dictionary
                    // it knows what it holds
                    guard let itemDictionary = dict as? NSDictionary else { return }
                    // we get our javascript code that we typed in the action.js file
                    guard let javaScriptValue = itemDictionary[NSExtensionJavaScriptPreprocessingResultsKey] as? NSDictionary else { return }
                    
                    self?.pageTitle = javaScriptValue["title"] as? String ?? ""
                    self?.pageURL = javaScriptValue["URL"] as? String ?? ""
                    
                    // this is a second closure and we don't need weak self
                    // beacuase it's already in a closure that has that
                    DispatchQueue.main.async {
                        self?.title = self?.pageTitle
                    }
                }
            }
        }
        
    }

    @IBAction func done() {
        // sending back information to safari and this is the reverse
        // of what we did in viewDidLoad
        let item = NSExtensionItem()
        let argument: NSDictionary = ["customJavaScript": script.text]
        let webDictionary: NSDictionary = [NSExtensionJavaScriptFinalizeArgumentKey: argument]
        let customJavaScript = NSItemProvider(item: webDictionary, typeIdentifier: kUTTypePropertyList as String)
        item.attachments = [customJavaScript]
        extensionContext?.completeRequest(returningItems: [item])
        
    }
    
    @objc func adjustForKeyboard(notification: Notification) {
        // gives us the frame of keyboard
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        
        // tell us the size of the keyboard
        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        // getting correct size deping if our view is rotated
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            // the amount we push the text from the edge
            script.contentInset = .zero
        }else {
            script.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
        }
        
        script.scrollIndicatorInsets = script.contentInset
        
        // when we tap with our finger we will scroll to
        // that position
        let selectedRange = script.selectedRange
        script.scrollRangeToVisible(selectedRange)
    }

}
