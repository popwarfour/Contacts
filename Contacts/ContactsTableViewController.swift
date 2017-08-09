//
//  ContactsTableViewController.swift
//  Contacts
//
//  Created by Anders Melen on 7/31/17.
//  Copyright © 2017 Anders Melen. All rights reserved.
//

import UIKit

protocol ContactUpdateDelegate {
    func shouldReloadContacts()
}

class ContactsTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    @IBOutlet var tableView: UITableView!
    @IBOutlet var searchBar: UISearchBar!
    
    @IBOutlet weak var tableViewBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var searchBarHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var searchBarTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var addButtonHeightConstraint: NSLayoutConstraint!
    
    private var _contacts = [Contact]()
    private var contacts: [Contact] {
        get {
            return self._contacts
        }
        set {
            self.updateFilteredContacts()
            self._contacts = newValue
        }
    }
    
    private var filteredContacts = [Contact]()
    
    // MARK: - Configuration
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        AppDelegate.shared.contactDelegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    // MARK: - Life Cycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.updateTable(completion: nil)
    }
    
    // MARK: - Button Actions
    @IBAction func addButtonPressed(_ sender: UIButton) {
    
        self.performSegue(withIdentifier: SEGUE_IDENTIFIER_CONTACT_DETAIL, sender: nil)
    
    }
    
    @IBAction func filterButtonPressed(_ sender: UIBarButtonItem) {
        
        let value = (self.searchBarTopConstraint.constant == 0.0) ? self.searchBarHeightConstraint.constant * -1 : 0.0
    
        if value != 0.0 {
            self.view.endEditing(true)
            self.updateFilteredContacts(filter: false)
            self.tableView.reloadData()
        } else {
            self.updateFilteredContacts(filter: true)
            self.tableView.reloadData()
        }
        
        UIView.animate(withDuration: 0.2) { 
            self.searchBarTopConstraint.constant = value
            self.view.layoutIfNeeded()
        }
        
    }
    
    @IBAction func editButtonPressed(_ sender: UIBarButtonItem) {
        
        self.tableView.isEditing = !self.tableView.isEditing
        
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
    
    // MARK: - Keyboard
    
    func keyboardWillShow(_ notification: Notification){
        
        let info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        self.tableViewBottomConstraint.constant = keyboardFrame.size.height - self.addButtonHeightConstraint.constant
        
        UIView.animate(withDuration: 0.2, animations: {() -> Void in
            self.view.layoutIfNeeded()
        })
        
    }
    
    func keyboardWillHide() {
        
        self.tableViewBottomConstraint.constant = 0
        UIView.animate(withDuration: 0.2, animations: {() -> Void in
            self.view.layoutIfNeeded()
        })
        
    }
    
    // MARK: - Data
    private func updateFilteredContacts(filter: Bool = true) {
        
        guard filter == true else {
            
            self.filteredContacts = self.contacts
            return
            
        }
        
        self.filteredContacts = self.contacts.filter { contact -> Bool in
            
            guard let filterText = self.searchBar.text?.lowercased() else {
                return true
            }
            
            guard filterText != "" else {
                return true
            }
            
            return contact.firstName.lowercased().contains(filterText) || contact.lastName.lowercased().contains(filterText)
        }
        
    }
    
    fileprivate func updateTable(completion: (() -> Void)?) {
        
        self.updateData {
            
            self.updateFilteredContacts()
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
        return self.filteredContacts.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ContactTableViewCell.reuseID()) as? ContactTableViewCell else {
            
            assert(false,
                   "Expected `ContactTableViewCell`")
            return UITableViewCell()
            
        }
        
        let contact = self.filteredContacts[indexPath.row]
        cell.configure(contact: contact)
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let contact = self.filteredContacts[indexPath.row]
        self.performSegue(withIdentifier: SEGUE_IDENTIFIER_CONTACT_DETAIL, sender: contact)
        
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        guard editingStyle == .delete else {
            return
        }
        
        guard indexPath.row < self.filteredContacts.count else {
            assert(false,
                   "Expected `IndexPath` to be within the bounds of filterContacts")
            return
        }
        
        let contact = self.filteredContacts[indexPath.row]
        contact.dalete { result in
            
            switch result {
            
            case .success(_):
                
                guard let index = self.contacts.index(of: contact) else {
                    return
                }
                
                self.contacts.remove(at: index)
                self.updateFilteredContacts()
                
                self.tableView.beginUpdates()
                self.tableView.deleteRows(at: [indexPath], with: .automatic)
                self.tableView.endUpdates()
                
                break
                
            case .failure(_):
                
                let alert = UIAlertController(title: "Error",
                                              message: "Failed to delete contact!",
                                              preferredStyle: .alert)
                let ok = UIAlertAction(title: "Ok",
                                       style: .default,
                                       handler: { _ in
                                        
                                        alert.dismiss(animated: true,
                                                      completion: nil)
                                        
                })
                
                alert.addAction(ok)
                
                self.present(alert,
                             animated: true,
                             completion: nil)
                
                break
            
            }
            
        }
        
    }
    
    // MARK: - UISearchBarDelegate
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        self.updateFilteredContacts()
        self.tableView.reloadData()
        
    }

}

extension ContactsTableViewController: ContactUpdateDelegate {
    
    func shouldReloadContacts() {
        
        self.updateTable(completion: nil)
        
    }
    
}
