//
//  LoginVC.swift
//  A4_NotesApp
//
//  Created by Airell Mantilla on 2023-04-02.
//

import UIKit
import Firebase

class LoginVC: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func loginClicked(_ sender: UIButton) {
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        
        let db = Firestore.firestore()
        db.collection("accounts").whereField("email", isEqualTo: email).whereField("password", isEqualTo: password).getDocuments { querySnapshot, error in
            if let e = error {
                print("Error retrieving account from Firestore: \(e)")
            } else if let documents = querySnapshot?.documents, !documents.isEmpty {
                let accountDocumentID = documents[0].documentID
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                guard let homeVC = storyboard.instantiateViewController(withIdentifier: "homeScreen") as? HomeVC else { return }
                homeVC.accountDocumentID = accountDocumentID
                guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                      let sceneDelegate = windowScene.delegate as? SceneDelegate,
                      let window = sceneDelegate.window else { return }
                window.rootViewController = homeVC
            } else {
                let alert = UIAlertController(title: "Error", message: "Invalid Login Credentials", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
}
