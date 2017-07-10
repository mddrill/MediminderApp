//
//  Patient.swift
//  MediminderApp
//
//  Created by Matthew Drill on 7/10/17.
//  Copyright © 2017 Matthew Drill. All rights reserved.
//

import UIKit

class Patient: Account {
    var doctors: [Doctor] = []
    override init(json: [String: Any]) {
        super.init(json: json)
        let jsonDoctors = json["doctors"] as? [[String: Any]]
        for json in jsonDoctors! {
            doctors += [Account(json: json) as! Doctor]
        }
    }
}
