//
//  SettingsVC.swift
//  A4_NotesApp
//
//  Created by Airell Mantilla on 2023-04-02.
//

import UIKit
import Firebase
import FirebaseFirestore

class SettingsVC: UIViewController {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var newNameField: UITextField!
    
    var accountDocumentID: String?
    var didUpdateName: (() -> Void)?
            
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        fetchAccountData()
    }
    
    private func fetchAccountData() {
        let db = Firestore.firestore()
        guard let accountID = accountDocumentID else { return }
        
        db.collection("accounts").document(accountID).getDocument { (document, error) in
            if let err = error {
                print("Error retrieving account from Firestore: \(err)")
            } else if let document = document, document.exists {
                if let account = try? document.data(as: Accounts.self) {
                    DispatchQueue.main.async {
                        self.nameLabel.text = account.name
                        self.emailLabel.text = account.email
                    }
                } else {
                    print("Error converting document to an instance of type Accounts")
                }
            } else {
                print("No such document in accounts collection")
            }
        }
    }
    
    func displayErrorMessage(_ message: String) {
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func confirmClicked(_ sender: Any) {
        guard let newName = newNameField.text,
              !newName.isEmpty,
              let accountID = accountDocumentID else {
            displayErrorMessage("Please fill in the name field")
            return
        }

        let db = Firestore.firestore()
        let accountRef = db.collection("accounts").document(accountID)

        accountRef.updateData(["name": newName]) { error in
            if let err = error {
                print("Error updating account name: \(err)")
            } else {
                let alertController = UIAlertController(title: "Success", message: "Account name successfully updated", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alertController, animated: true, completion: nil)

                self.nameLabel.text = newName
                self.newNameField.text = ""
                self.didUpdateName?()
            }
        }
    }
    
    @IBAction func logoutClicked(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let titleVC = storyboard.instantiateViewController(withIdentifier: "titleScreen") as? TitleVC {
            titleVC.modalPresentationStyle = .fullScreen
            present(titleVC, animated: true, completion: nil)
        }
    }
}
