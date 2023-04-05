//
//  HomeVC.swift
//  A4_NotesApp
//
//  Created by Airell Mantilla on 2023-04-02.
//

import UIKit
import Firebase
import FirebaseFirestore

class HomeVC: UIViewController {
    
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var notesTableView: UITableView!
    @IBOutlet weak var noteTextField: UITextField!
    
    var docID: String?
    var accountDocumentID: String?
    private var notes: [Notes] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchNotes()
        welcomeMsg()
        notesTableView.dataSource = self
        notesTableView.delegate = self
    }

    @IBAction func modifyClicked(_ sender: Any) {
        guard let id = docID,
                  let noteText = noteTextField.text,
                  let accountID = accountDocumentID
        else { return }

        let note = Notes(note: noteText, accID: accountID)
        updateNote(withId: id, note: note)
        docID = nil
        noteTextField.text = ""
    }
    
    @IBAction func addClicked(_ sender: Any) {
        guard let noteText = noteTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              let accountID = accountDocumentID,
              !noteText.isEmpty
        else {
            let alertController = UIAlertController(title: "Error", message: "Note field cannot be blank", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(okAction)
            present(alertController, animated: true, completion: nil)
            return
        }

        let note = Notes(note: noteText, accID: accountID)
        addNewNote(note: note)
        noteTextField.text = ""
    }
    
    private func welcomeMsg() {
        let db = Firestore.firestore()
        guard let accountID = accountDocumentID else { return }
        
        db.collection("accounts").document(accountID).getDocument { (document, error) in
            if let err = error {
                print("Error retrieving account from Firestore: \(err)")
            } else if let document = document, document.exists {
                if let account = try? document.data(as: Accounts.self) {
                    self.welcomeLabel.text = "\(account.name)'s Notes"
                } else {
                    print("Error converting document to an instance of type Accounts")
                }
            } else {
                print("No such document in accounts collection")
            }
        }
    }
    
    private func updateNote(withId id: String, note: Notes) {
        let db = Firestore.firestore()
        do {
            try db.collection("notes").document(id).setData(from: note)
            print("Note updated")
            fetchNotes()
        } catch {
            print("Error updating note in Firestore")
        }
    }

    private func addNewNote(note: Notes) {
        let db = Firestore.firestore()
        do {
            try db.collection("notes").addDocument(from: note)
            print("Note added")
            fetchNotes()
        } catch {
            print("Error saving note to Firestore")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toSettingsVC",
           let settingsVC = segue.destination as? SettingsVC {
            settingsVC.accountDocumentID = accountDocumentID
            settingsVC.didUpdateName = {
                self.welcomeMsg()
            }
        }
    }

    private func fetchNotes() {
        notes = []
        let db = Firestore.firestore()
        guard let accountID = accountDocumentID else { return }
        
        print("Account document ID: s") //debug line
        
        db.collection("notes").whereField("accID", isEqualTo: accountID).getDocuments { (snapshot, error) in
            if let err = error {
                print("Error getting documents from collection")
                print(err)
                return
            }
            
            guard let results = snapshot else {return}

            if results.count == 0 {
                print("No notes found for the current user")
            } else {
                print("There are \(results.count) notes for the current user")

                for document in results.documents {
                    let noteID = document.documentID
                    do {
                        let noteFromFS = try document.data(as: Notes.self)
                        var note = noteFromFS
                        note.id = noteID
                        self.notes.append(note)
                    } catch {
                        print("Error converting document to an instance of type Notes")
                    }
                }

                self.notesTableView.reloadData()
            }
        }
    }
}

extension HomeVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "noteCell", for: indexPath) as! NotesTVCell
        cell.note = notes[indexPath.row]
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Cell selected at row \(indexPath.row)") // debug line
        docID = notes[indexPath.row].id
        noteTextField.text = notes[indexPath.row].note
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            guard let noteID = notes[indexPath.row].id else { return }
            let db = Firestore.firestore()
            db.collection("notes").document(noteID).delete() { error in
                if let err = error {
                    print("Error deleting note from Firestore: \(err)")
                } else {
                    print("Note successfully deleted")
                    self.fetchNotes()
                    self.notesTableView.reloadData()
                }
            }
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}
