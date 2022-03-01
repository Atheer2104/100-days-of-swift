//
//  ViewController.swift
//  projectTen
//
//  Created by Atheer on 2019-05-26.
//  Copyright © 2019 Atheer. All rights reserved.
//

import UIKit

class ViewController: UICollectionViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var people = [Person]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewPerson))
        
        let defaults = UserDefaults.standard
        
        // getting saved data
        if let savedPeople = defaults.object(forKey: "people") as? Data {
            let jsonDeconder = JSONDecoder()
            
            do {
                // when we are decoding we are telling it to use information
                // from savedpeople and try to make it into type of person array
                people = try jsonDeconder.decode([Person].self, from: savedPeople)
            } catch {
                print("Failed to load people")
            }
        }
        
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return people.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // without typecasting we get a normal collectionviewcell
        // one without our label or imageview
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Person", for: indexPath) as? PersonCell else {
            // this line will make the app crash in theory this never happen 
            fatalError("Unable to dequeue personCell.")
        }
        
        // grid that's why we use item
        let person = people[indexPath.item]
        
        cell.name.text = person.name
        
        let path = getDocumentsDirectory().appendingPathComponent(person.image)
        // we get as an URL first and it wants it in string that's why add
        // path again
        cell.imageViewe.image = UIImage(contentsOfFile: path.path)
        
        // white: 0 means black
        cell.imageViewe.layer.borderColor = UIColor(white: 0, alpha: 0.3).cgColor
        cell.imageViewe.layer.borderWidth = 2
        cell.imageViewe.layer.cornerRadius = 3
        cell.layer.cornerRadius = 7
        
        return cell
    }
    
    @objc func addNewPerson() {
        let picker = UIImagePickerController()
        // the user could edit and crop the picture
        picker.allowsEditing = true
        // need to comform to uipickerdelegate it contains methods but are optinal
        // the methods tell us when the user has choosen a picture or canceld
        picker.delegate = self
        present(picker, animated: true)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // trying to find image and then convert it into UIImage
        guard let image = info[.editedImage] as? UIImage else { return }
        
        // making unuiq id for the picture
        let imageName = UUID().uuidString
        // read documents directory and it will create a file with imageName
        let imagePath = getDocumentsDirectory().appendingPathComponent(imageName)
        
        if let jpegData = image.jpegData(compressionQuality: 0.8) {
            //we are writing to disk 
            try? jpegData.write(to: imagePath)
        }
        
        // create instance of person
        let person = Person(name: "Uknown", image: imageName)
        // add to the person array
        people.append(person)
        save()
        // reload collectionview
        collectionView.reloadData()
        
        // this dismiss'es the top controller in our case it's the picker
        dismiss(animated: true)
    }

    func getDocumentsDirectory() -> URL {
        //asking for documents directory path which also gets backuped by Icloud
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // the item we choose 
        let person = people[indexPath.item]
        
        let ac = UIAlertController(title: "Rename person", message: nil, preferredStyle: .alert)
        ac.addTextField()
        
        ac.addAction(UIAlertAction(title: "Ok", style: .default) {
            [weak self, weak ac] _ in
            guard let newName = ac?.textFields?[0].text else { return }
            person.name = newName
            self?.save()
            self?.collectionView.reloadData()
        })
        
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
    
    func save() {
        let jsonEncoder = JSONEncoder()
        
        // codable works as json data so we are trying to convert our people
        // array into json data
        if let savedData = try? jsonEncoder.encode(people) {
            let defaults = UserDefaults.standard
            defaults.set(savedData, forKey: "people")
            
        }else {
            print("Failed to save people")
        }
    }
}

