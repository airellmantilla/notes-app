//
//  Notes.swift
//  A4_NotesApp
//
//  Created by Airell Mantilla on 2023-04-03.
//

import Foundation
import FirebaseFirestoreSwift

struct Notes: Codable {
    @DocumentID var id: String?
    
    var note: String
    var accID: String
}
