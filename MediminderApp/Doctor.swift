//
//  Doctor.swift
//  MediminderApp
//
//  Created by Matthew Drill on 7/10/17.
//  Copyright © 2017 Matthew Drill. All rights reserved.
//

import UIKit

class Doctor: Account {
    var patients: [Patient] = []
    override init(json: [String: Any]) {
        super.init(json: json)
        let jsonPatients = json["patients"] as? [[String: Any]]
        for json in jsonPatients! {
            patients += [Account(json: json) as! Patient]
        }
    }
}
