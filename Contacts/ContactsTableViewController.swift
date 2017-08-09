//
//  ContactsTableViewController.swift
//  Contacts
//
//  Created by Anders Melen on 7/31/17.
//  Copyright © 2017 Anders Melen. All rights reserved.
//

import UIKit

class ContactsTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    @IBOutlet var tableView: UITableView!
    
    private var contacts = [Contact]()
    
    // MARK: - Life Cycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.updateTable(completion: nil)
    }
    
    // MARK: - Button Actions
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        self.performSegue(withIdentifier: SEGUE_IDENTIFIER_CONTACT_DETAIL, sender: nil)
        
    }
    
    // MARK: - Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == SEGUE_IDENTIFIER_CONTACT_DETAIL {
            
            guard let contactDetailViewController = segue.destination as? ContactDetailViewController else {
                assert(false,
                       "Expected segue destination to be `ContactDetailViewController`")
                return
            }
            
            var contactDTO: Contact.DTO!
            if let contact = sender as? Contact {
                contactDTO = Contact.DTO(contact: contact)
            } else {
                contactDTO = Contact.DTO()
            }
            
            contactDetailViewController.configure(contact: sender as? Contact,
                                                  contactDTO: contactDTO)
            
        }
        
    }
    
    // MARK: - Data
    
    private func updateTable(completion: (() -> Void)?) {
        
        self.updateData {
            self.tableView.reloadData()
            completion?()
        }
        
    }
    
    private func updateData(completion: @escaping () -> Void) {
        
        DispatchQueue.main.async {
            guard let contacts = Contact.fetch() else {
                self.contacts = []
                completion()
                return
            }
            
            self.contacts = contacts
            completion()
        }
        
    }

    // MARK: - UITableView Delegate / DataSource

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.contacts.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ContactTableViewCell.reuseID()) as? ContactTableViewCell else {
            
            assert(false,
                   "Expected `ContactTableViewCell`")
            return UITableViewCell()
            
        }
        
        let contact = self.contacts[indexPath.row]
        cell.configure(contact: contact)
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let contact = self.contacts[indexPath.row]
        self.performSegue(withIdentifier: SEGUE_IDENTIFIER_CONTACT_DETAIL, sender: contact)
        
    }
    
    // MARK: - UISearchBarDelegate
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        
        
    }

}
