//
//  DoctorsServiceClient.swift
//  MediminderApp
//
//  Created by Matthew Drill on 7/10/17.
//  Copyright © 2017 Matthew Drill. All rights reserved.
//

import Foundation

class DoctorsServiceClient {
    
    static let sharedInstance = DoctorsServiceClient()
    
    static func endpointForDoctors() -> String{
        return "http://127.0.0.1:8000/doctors/"
    }
    static func endpointForDoctors(id: Int) -> String{
        return "http://127.0.0.1:8000/doctors/\(id)/"
    }
    static func endpointForLogin() -> String{
        return "http://127.0.0.1:8000/api-token-auth/"
    }
    func create(username: String, password1: String, password2: String, email: String,
                firstName: String, lastName: String, onSuccess: (Void)->(), onError: (NSError)->()) throws {
        
    }
    func login(username: String, password: String, onSuccess: (Token, String)->(), onError: (NSError)->()) {
        
    }
    func getIdOf(username: String, onSuccess: (Int)->(), onError: (NSError)->()) {
        
    }
    func get(id: Int, onSuccess: (Doctor)->(), onError: (NSError)->()) throws {
        
    }
}
