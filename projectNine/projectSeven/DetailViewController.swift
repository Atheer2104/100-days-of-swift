//
//  DetailViewController.swift
//  projectSeven
//
//  Created by Atheer on 2019-05-20.
//  Copyright © 2019 Atheer. All rights reserved.
//

import UIKit
import WebKit

class DetailViewController: UIViewController {
    var webView: WKWebView!
    var detailItem: Petition?
    
    // when view loads
    override func loadView() {
        webView = WKWebView()
        view = webView
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let detailItem = detailItem else { return }
        
        let html = """
        <html>
        <head>
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <style> body { font-size: 150%; } </style>
        </head>
        <body>
        \(detailItem.body)
        </body>
        </html>
        """
        
        // loading a custom html that we have created 
        webView.loadHTMLString(html, baseURL: nil)
        
    }
    

    

}
