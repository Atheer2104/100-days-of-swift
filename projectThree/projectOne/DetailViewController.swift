//
//  DetailViewController.swift
//  projectOne
//
//  Created by Atheer on 2019-05-07.
//  Copyright © 2019 Atheer. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    @IBOutlet var imageView: UIImageView!
    var selectedImage: String?
    var currentImageIndex = 0
    var totalImages = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Picture \(currentImageIndex) of \(totalImages)"
        // confirguration just for this viewcontroller won't impact others
        // we don't show large title
        navigationItem.largeTitleDisplayMode = .never
        
        // target tells where the action function exist
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareTapped))
        
        
        
        if let imageToLoad = selectedImage {
            imageView.image = UIImage(named: imageToLoad)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.hidesBarsOnTap = true
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.hidesBarsOnTap = false
    }

    @objc func shareTapped() {
        guard let image = imageView.image?.jpegData(compressionQuality: 0.8) else {
            print("No image found")
            return
        }
        
        
        let vc = UIActivityViewController(activityItems: [image], applicationActivities: [])
        // do this mainly for ipad so the user knows where the popup comes from
        vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(vc, animated: true)
    }
    
}
