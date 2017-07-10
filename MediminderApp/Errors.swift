//
//  Errors.swift
//  MediminderApp
//
//  Created by Matthew Drill on 7/10/17.
//  Copyright © 2017 Matthew Drill. All rights reserved.
//

import Foundation

enum RegistrationError: Error {
    case usernameAlreadyExists
    case emailIsInvalid
    case passwordsDontMatch
}

enum InstructionError:  Error {
    case notLoggedIn
    case wrapperDoesntHaveNextURL
    case notDoctor
}

enum BackendError: Error {
    case invalidJSON
    case postListResponseDoesNotHaveResultField
    case postDoesNotHaveProperFields
}

enum DoctorError: Error {
    case notLoggedIn
}

enum PatientError: Error {
    case notLoggedIn
}
