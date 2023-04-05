//
//  NotesTVCell.swift
//  A4_NotesApp
//
//  Created by Airell Mantilla on 2023-04-03.
//

import UIKit

class NotesTVCell: UITableViewCell {
    @IBOutlet weak var notesLabel: UILabel!
    
    var note: Notes? {
        didSet {
            if let note = note {
                notesLabel.text = note.note
            }
        }
    }
}
