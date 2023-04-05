//
//  Accounts.swift
//  A4_NotesApp
//
//  Created by Airell Mantilla on 2023-04-03.
//

import Foundation
import FirebaseFirestoreSwift

struct Accounts: Codable {
    @DocumentID var id: String?

    var name: String
    var email: String
    var password: String
}
