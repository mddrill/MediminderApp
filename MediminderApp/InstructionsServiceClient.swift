//
//  InstructionsServiceClient.swift
//  MediminderApp
//
//  Created by Matthew Drill on 7/10/17.
//  Copyright © 2017 Matthew Drill. All rights reserved.
//

import Foundation


class InstructionsServiceClient {
    
    static let sharedInstance = InstructionsServiceClient()
    
    static func endpointForInstructions() -> String{
        return "http://127.0.0.1:8000/instructions/"
    }
    static func endpointForInstructions(id: Int) -> String{
        return "http://127.0.0.1:8000/instructions/\(id)/"
    }
    func create(patient: Int, text: String, onSuccess: (Void)->(), onError: (NSError)->()) throws {
        
    }
    func edit(id: Int, text: String, onSuccess: (Void)->(), onError: (NSError)->()) throws {
        
    }
    func delete(id: Int, onSuccess: (Void)->(), onError: (NSError)->()) throws {
        
    }
}
