//
//  ViewController.swift
//  projectSeven
//
//  Created by Atheer on 2019-05-19.
//  Copyright © 2019 Atheer. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
    var petitions = [Petition]()
    var filterdpetitions = [Petition]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Credit", style: .plain, target: self, action: #selector(creditData))
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(searchPetition))
        
        let urlString: String
            
        if navigationController?.tabBarItem.tag == 0 {
            urlString = "https://www.hackingwithswift.com/samples/petitions-1.json"
        }else {
            urlString = "https://www.hackingwithswift.com/samples/petitions-2.json"
        }
            
        if let url = URL(string: urlString) {
            // fetch data
            // the data can return an error for example if there no internet connection
            if let data = try? Data(contentsOf: url) {
                // okay to parse data
                parse(json: data)
                return
            }
        }
            showError()
    }
    
    @objc func creditData() {
        let ac = UIAlertController(title: "Data", message: "The data comes from We The People API of the Whitehouse, if you were wondering.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Okay!", style: .default))
        present(ac, animated: true)
    }
    
    @objc func searchPetition() {
        let ac = UIAlertController(title: "Search for petition", message: nil, preferredStyle: .alert)
        ac.addTextField()
        
        let searchAction = UIAlertAction(title: "Search", style: .default) {
            [weak self, weak ac] action in
            
            guard let searchTitle = ac?.textFields?[0].text else { return }
            self?.filterPetitions(searchTitle)
        }
        
        ac.addAction(searchAction)
        present(ac, animated: true)
        
    }
    
    func filterPetitions(_ Title: String) {
        for petition in petitions {
            if petition.title.contains(Title) {
                filterdpetitions = []
                filterdpetitions.append(petition)
                tableView.reloadData()
            }
        }
    }
    
    func showError() {
        
        let ac = UIAlertController(title: "Loading Error", message: "There was an error loading the feed; please check your connection and try again.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Okay", style: .default))
        present(ac, animated: true)
        
    }
    
    func parse(json: Data) {
        let decoder = JSONDecoder()
        
        // tries to convert the data into a Petitions object
        if let jsonPetitions = try? decoder.decode(Petitions.self, from: json) {
            petitions = jsonPetitions.results
            filterdpetitions = petitions
            tableView.reloadData()
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filterdpetitions.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let petition = filterdpetitions[indexPath.row]
        cell.textLabel?.text = petition.title
        cell.detailTextLabel?.text = petition.body
        return cell 
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = DetailViewController()
        vc.detailItem = filterdpetitions[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }

}

