//
//  ContactDetailViewController.swift
//  Contacts
//
//  Created by Anders Melen on 8/5/17.
//  Copyright © 2017 Anders Melen. All rights reserved.
//

import UIKit
import AFDateHelper
import CoreStore
import PureLayout

class ContactDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    @IBOutlet weak var tableViewBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var headingLetterContainer: Designable!
    @IBOutlet weak var headingNameLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var datePickerView: UIView!
    
    @IBOutlet weak var initialContainer: UIView!
    
    var dateInputViewController: DateInputViewController?
    var initialView: InitialView?
    
    var contactDTO: Contact.DTO?
    var contact: Contact?
    
    // MARK: - Configuration
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func configure(contact: Contact?,
                   contactDTO: Contact.DTO) {
        
        // Forces view stack to load if not already done so
        let _ = self.view
        
        self.contact = contact
        self.contactDTO = contactDTO
        self.configureHeadingView(contactDTO: contactDTO)
    
        self.tableView.reloadData()
        
        
    }
    
    // MARK: Subview Configuration
    
    private func configureHeadingView(contactDTO: Contact.DTO) {
        
        var name = "New Contact"
        if let firstName = contactDTO.data[Contact.Parameter.firstName] as? String,
            let lastName = contactDTO.data[Contact.Parameter.lastName] as? String {
            
            name = "\(firstName) \(lastName)"
            
        }
        
        self.headingNameLabel.text = name
        self.configureInitialView(contactDTO: contactDTO)
        
    }
    
    private func configureInitialView(contactDTO: Contact.DTO) {
        
        if self.initialView == nil {
            
            self.initialView = InitialView.viewByTypeFromNibNamed(nibName: NIB_INITIAL_VIEWS)
            self.initialContainer.addSubview(self.initialView!)
            self.initialView?.autoPinEdgesToSuperviewEdges()
            
        }
        
        let character = (contactDTO.data[Contact.Parameter.firstName] as? String)?.characters.first
        self.initialView?.configure(fontSize: 100.0,
                                    color: contactDTO.color,
                                    character: character)
        
    }
    
    // MARK: - Keyboard
    
    func keyboardWillShow(_ notification: Notification){
        
        let info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        self.tableViewBottomConstraint.constant = keyboardFrame.size.height
        
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

    // MARK: - Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == SEGUE_IDENTIFIER_DATE_PICKER {
        
            self.dateInputViewController = segue.destination as? DateInputViewController
            
        }
        
    }
    
    // MARK: - Data
    private func save(contactDTO: Contact.DTO) {
        
        let saveClosure: (AsynchronousDataTransaction.Result<Contact>) -> Void = { result in
            
            switch result {
                
            case .success(_):
                self.dismiss(animated: true,
                             completion: nil)
                break
                
            case .failure(let error):
                
                switch error {
                    
                case .userError(let userError):
                    self.showAlert(error: userError)
                    break
                    
                default:
                    self.showAlert(error: error)
                    break
                }
                break
                
            }
        
        }
        
        do {
            
            if let contact = self.contact {
                
                // Modify Existing Contact
                try contact.update(updateClosure: { updateContact in
                    
                    try updateContact.configure(contactDTO: contactDTO)
                    
                }, completionClosure: saveClosure)
                
            } else {
                
                // Create New Contact
                try Contact.create(contactDTO: contactDTO,
                                   completionClosure: saveClosure)
                
            }
            
        } catch let error {
            
            self.showAlert(error: error)
            
        }
        
    }
    
    private func showAlert(error: Error) {
        
        var title: String
        var message: String
        
        if let contactError = error as? Contact.ContactError {
            (title, message) = self.contactError(error: contactError)
        } else {
            title = "Error"
            message = error.localizedDescription
        }
        
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        let ok = UIAlertAction(title: "Ok",
                               style: .default) { _ in
                                alert.dismiss(animated: true,
                                              completion: nil)
        }
        alert.addAction(ok)
        
        self.present(alert,
                     animated: true,
                     completion: nil)
        
    }
    
    private func contactError(error: Contact.ContactError) -> (String, String) {
        
        var title: String!
        var message: String!
        
        switch error {
            
        case .parametersRequired(let parameters):
            title = "Missing Required"
            message = ""
            for parameter in parameters {
                message.append(parameter.rawValue)
                message.append(" ")
            }
            break
            
        }
        
        return (title, message)
    }
    
    // MARK: - Date Input
    private func showDateInputView(parameter: Contact.Parameter,
                                   date: Date?) {
     
        guard let contactDTO = self.contactDTO else {
            assert(false,
                   "Expected `Contact.DTO` not to be nil")
            return
        }
        
        self.datePickerView.alpha = 0.0
        self.datePickerView.isHidden = false
        
        self.dateInputViewController?.configure(date: date,
                                                saveClosure: { newDate in
                                           
                                                    contactDTO.data[parameter] = newDate
                                                    self.tableView.reloadData()
                                                    
                                                    UIView.animate(withDuration: 0.2,
                                                                   animations: { 
                                                                    
                                                                    self.datePickerView.alpha = 0.0
                                                                    self.datePickerView.isHidden = true
                                                                    
                                                    })
                                                    
                                                    
        })
        
        UIView.animate(withDuration: 0.2) {
            
            self.datePickerView.alpha = 1.0
            
        }
        
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Button Actions
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true,
                     completion: nil)
    }
    
    @IBAction func saveButtonPressed(_ sender: UIBarButtonItem) {
       
        guard let contactDTO = self.contactDTO else {
            assert(false,
                   "Expected `Contact.DTO` not to be nil")
            return
        }

        self.save(contactDTO: contactDTO)
        
    }
    
    // MARK: - UITextField
  
    private static func keyboardType(parameter: Contact.Parameter) -> UIKeyboardType {
        
        switch parameter {
            
        case .firstName:
            return .alphabet
            
        case .lastName:
            return .alphabet
            
        case .dateOfBirth:
            return .alphabet
        
        case .zipCode:
            return .numberPad
            
        case .phoneNumber:
            return .numberPad
            
        }
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true
        
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        guard let indexPath = textField.indexPath else {
            assert(false,
                   "Expected `IndexPath` not to be nil")
            return true
        }
        
        let parameter = Contact.Parameter.all()[indexPath.row]
        
        guard parameter == .dateOfBirth else {
            return true
        }
        
        guard let contactDTO = self.contactDTO else {
            assert(false,
                   "Expected `Contact.DTO` not to be nil")
            return true
        }
        
        self.view.endEditing(true)
        
        let date = contactDTO.data[parameter] as? Date
        
        self.showDateInputView(parameter: parameter,
                               date: date)
        
        return false
        
    }
    
    @IBAction func textFieldEditingDidChange(_ sender: UITextField) {
        
        guard let indexPath = sender.indexPath else {
            assert(false,
                   "Expected `IndexPath` not to be nil")
            return
        }
        
        let parameter = Contact.Parameter.all()[indexPath.row]
        
        guard parameter != .dateOfBirth else {
            return
        }
        
        guard let contactDTO = self.contactDTO else {
            assert(false,
                   "Expected `Contact.DTO` not to be nil")
            return
        }
        
        let text = sender.text
        contactDTO.data[parameter] = text
        
        self.configureHeadingView(contactDTO: contactDTO)
    }
    
    // MARK: - UITableView Delegate / DataSource

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Contact.Parameter.all().count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ContactParameterTableViewCell.reuseID()) as? ContactParameterTableViewCell else {
            
            assert(false,
                   "Expected `ContactParameterTableViewCell`")
            return UITableViewCell()
            
        }
        
        guard let contactDTO = self.contactDTO else {
            assert(false,
                   "Expected `Contact.DTO`")
            return UITableViewCell()
        }
        
        let parameter = Contact.Parameter.all()[indexPath.row]
        let value = contactDTO.data[parameter]
        let keyboardType = ContactDetailViewController.keyboardType(parameter: parameter)
        
        switch parameter {
            
        case .firstName:
            let string = value as? String
            cell.configure(parameter: parameter,
                           keyboardType: keyboardType,
                           string: string,
                           image: #imageLiteral(resourceName: "userIcon"),
                           indexPath: indexPath)
            break
        
        case .lastName:
            let string = value as? String
            cell.configure(parameter: parameter,
                           keyboardType: keyboardType,
                           string: string,
                           image: nil,
                           indexPath: indexPath)
            break
            
        case .zipCode:
            let string = value as? String
            cell.configure(parameter: parameter,
                           keyboardType: keyboardType,
                           string: string,
                           image: #imageLiteral(resourceName: "zipIcon"),
                           indexPath: indexPath)
            break
            
        case .dateOfBirth:
            let date = value as? Date
            cell.configure(parameter: parameter,
                           date: date,
                           image: nil,
                           indexPath: indexPath,
                           dateInputClosure: self.showDateInputView(parameter:date:))
            break
            
        case .phoneNumber:
            let string = value as? String
            cell.configure(parameter: parameter,
                           keyboardType: keyboardType,
                           string: string,
                           image: #imageLiteral(resourceName: "phoneIcon"),
                           indexPath: indexPath)
            break
            
        }
        
        
        return cell
        
    }

}
