//
//  RegistrationVC.swift
//  A4_NotesApp
//
//  Created by Airell Mantilla on 2023-04-02.
//

import UIKit
import Firebase
import FirebaseFirestore

class RegistrationVC: UIViewController {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func registerClicked(_ sender: UIButton) {
        guard let name = nameTextField.text else { return }
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        
        let account = Accounts(name: name, email: email, password: password)
        
        let db = Firestore.firestore()
        do {
            let _ = try db.collection("accounts").addDocument(from: account) { error in
                if let error = error {
                    print("Error writing account to Firestore: \(error)")
                } else {
                    let alert = UIAlertController(title: "Account Created", message: "Your account has been successfully created.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        guard let titleVC = storyboard.instantiateViewController(withIdentifier: "titleScreen") as? TitleVC else { return }
                        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                              let sceneDelegate = windowScene.delegate as? SceneDelegate,
                              let window = sceneDelegate.window else { return }
                        window.rootViewController = titleVC
                    }))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        } catch let error {
            print("Error writing account to Firestore: \(error)")
        }
    }
}
