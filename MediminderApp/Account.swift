//
//  Account.swift
//  MediminderApp
//
//  Created by Matthew Drill on 7/10/17.
//  Copyright © 2017 Matthew Drill. All rights reserved.
//

import UIKit

enum AccountFields:  String {
    case Username = "username"
    case Email = "email"
    case FirstName = "first_name"
    case LastName = "last_name"
    case Instructions = "instructions"
}

class Account {
    var username: String!
    var email: String!
    var firstName: String!
    var lastName: String!
    var instructions: [Instruction] = []
    
    init(json: [String: Any]) {
        self.username = json[AccountFields.Username.rawValue] as? String
        self.email = json[AccountFields.Email.rawValue] as? String
        self.firstName = json[AccountFields.FirstName.rawValue] as? String
        self.lastName = json[AccountFields.LastName.rawValue] as? String
        let jsonInstructions = json[AccountFields.Instructions.rawValue] as? [[String: Any]]
        for json in jsonInstructions! {
            self.instructions += [Instruction(doctorId: (json["doctor"] as? Int)!,
                                patientId: (json["patient"] as? Int)!,
                                text: (json["text"] as? String)!)]
        }
    }
}
