//
//  PatientsServiceTest.swift
//  MediminderApp
//
//  Created by Matthew Drill on 7/10/17.
//  Copyright © 2017 Matthew Drill. All rights reserved.
//

import XCTest
import Mockingjay
import Quick
import Nimble
@testable import MediminderApp

class PatientsServiceTestCase: QuickSpec {
    let patientsClient = PatientsServiceClient.sharedInstance
    
    override func spec() {
        super.spec()
        
        describe("create Patient") {
            let username = "mddrill"
            let password = "password"
            let email = "mddrill@email.com"
            let firstName = "Matt"
            let lastName = "Drill"
            
            context("Success"){
                it("Runs success block and not run error block, sends username and password to callback") {
                    let path = Bundle(for: type(of: self)).path(forResource: "RegisterUser", ofType: "json")!
                    let data = NSData(contentsOfFile: path)!
                    self.stub(uri(PatientsServiceClient.endpointForPatients()), jsonData(data as Data, status: 201))
                    
                    var wasSuccess = false
                    var wasFailure = false
                    expect { try self.patientsClient
                        .create(username: username,
                                  password1: password,
                                  password2: password,
                                  email: email,
                                  firstName: firstName,
                                  lastName: lastName,
                                  onSuccess: { _ in
                                    wasSuccess = true
                                    
                        },
                                  onError: { error in
                                    wasFailure = true
                        })
                        }.toNot(throwError())
                    expect(wasSuccess).toEventually(beTrue())
                    expect(wasFailure).toEventually(beFalse())
                }
            }
            context("Invalid Email") {
                it("Throws an emailIsInvalid error"){
                    expect { try self.patientsClient
                        .create(username: username,
                                  password1: password,
                                  password2: password,
                                  email: "not valid",
                                  firstName: firstName,
                                  lastName: lastName,
                                  onSuccess: {_ in},
                                  onError: {_ in})
                        }.to(throwError(RegistrationError.emailIsInvalid))
                }
            }
            context("Passwords don't match") {
                it("Throws a passwordsDontMatch error") {
                    expect { try self.patientsClient
                        .create(username: username,
                                  password1: password,
                                  password2: "not same password",
                                  email: email,
                                  firstName: firstName,
                                  lastName: lastName,
                                  onSuccess: {_ in},
                                  onError: {_ in})
                        }.to(throwError(RegistrationError.passwordsDontMatch))
                }
            }
            context("Username is taken") {
                it("Returns an error, failure block is run, success block is not") {
                    var requestError: NSError!
                    
                    let error = NSError(domain: "Server Error", code: 400, userInfo: nil)
                    self.stub(uri(PatientsServiceClient.endpointForPatients()), failure(error))
                    
                    var wasSuccess = false
                    var wasFailure = false
                    expect { try self.patientsClient
                        .create(username: username,
                                  password1: password,
                                  password2: password,
                                  email: email,
                                  firstName: firstName,
                                  lastName: lastName,
                                  onSuccess: {_ in
                                    wasSuccess = true
                        },
                                  onError: {error in
                                    wasFailure = true
                                    requestError = error
                        })
                        }.toNot(throwError())
                    expect(wasSuccess).toEventually(beFalse())
                    expect(wasFailure).toEventually(beTrue())
                    expect(requestError).toEventuallyNot(beNil())
                    if(requestError != nil){
                        expect(requestError.code).toEventually(equal(400))
                    }
                }
            }
            context("Server error"){
                it("Returns an error, failure block is run, success block is not"){
                    var requestError: NSError!
                    
                    let error = NSError(domain: "Server Error", code: 500, userInfo: nil)
                    self.stub(uri(PatientsServiceClient.endpointForPatients()), failure(error))
                    
                    var wasSuccess = false
                    var wasFailure = false
                    expect { try self.patientsClient
                        .create(username: username,
                                  password1: password,
                                  password2: password,
                                  email: email,
                                  firstName: firstName,
                                  lastName: lastName,
                                  onSuccess: {_ in
                                    wasSuccess = true
                        },
                                  onError: {error in
                                    wasFailure = true
                                    requestError = error
                        })
                        }.toNot(throwError())
                    expect(wasSuccess).toEventually(beFalse())
                    expect(wasFailure).toEventually(beTrue())
                    expect(requestError).toEventuallyNot(beNil())
                    if(requestError != nil){
                        expect(requestError.code).toEventually(equal(500))
                    }
                }
            }
        }
        describe("Login"){
            let username = "user1"
            let password = "password"
            let id = 3
            context("Success") {
                it("Returns token") {
                    let path = Bundle(for: type(of: self)).path(forResource: "Login", ofType: "json")!
                    let data = NSData(contentsOfFile: path)!
                    self.stub(uri(PatientsServiceClient.endpointForLogin()), jsonData(data as Data, status: 200))
                    
                    var wasSuccess = false
                    var wasFailure = false
                    var userToken: String!
                    var user: String!
                    self.patientsClient.login(username: username, password: password,
                                              onSuccess: { token, username in
                                                wasSuccess = true
                                                userToken = token.value
                                                user = username
                    },
                                              onError: { _ in
                                                wasFailure = true
                    })
                    expect(wasSuccess).toEventually(beTrue())
                    expect(wasFailure).toEventually(beFalse())
                    expect(userToken).toEventually(equal("6f6a7ff11a8c2ff44423a3982ff81623cc35ed87"))
                    expect(user).toEventually(equal(username))
                }
                
            }
            context("Credentials incorrect") {
                it("Does not throw frontend error but returns a backend one") {
                    var requestError: NSError!
                    
                    let error = NSError(domain: "Server Error", code: 400, userInfo: nil)
                    self.stub(uri(PatientsServiceClient.endpointForLogin()), failure(error))
                    
                    
                    var wasSuccess = false
                    var wasFailure = false
                    self.patientsClient.login(username: username, password: "Not the right password",
                                             onSuccess: {_ in
                                                wasSuccess = true
                    },
                                             onError: { error in
                                                wasFailure = true
                                                requestError = error
                    })
                    expect(wasSuccess).toEventually(beFalse())
                    expect(wasFailure).toEventually(beTrue())
                    expect(requestError).toEventuallyNot(beNil())
                    if(requestError != nil){
                        expect(requestError.code).toEventually(equal(400))
                    }
                }
            }
            context("Getting a server error") {
                it("Does not throw frontend error but returns a backend one") {
                    var requestError: NSError!
                    
                    let error = NSError(domain: "Server Error", code: 500, userInfo: nil)
                    self.stub(uri(PatientsServiceClient.endpointForLogin()), failure(error))
                    
                    var wasSuccess = false
                    var wasFailure = false
                    self.patientsClient.login(username: username, password: "Not the right password",
                                             onSuccess: {_ in
                                                wasSuccess = true
                    },
                                             onError: { error in
                                                wasFailure = true
                                                requestError = error
                    })
                    expect(wasSuccess).toEventually(beFalse())
                    expect(wasFailure).toEventually(beTrue())
                    expect(requestError).toEventuallyNot(beNil())
                    if(requestError != nil){
                        expect(requestError.code).toEventually(equal(500))
                    }
                }
            }
        }
        describe("Get patient info, including instructions and patients"){
            let id = 7
            context("Success"){
                it("Returns account data"){
                    CurrentUser.token = "dummytoken"
                    let path = Bundle(for: type(of: self)).path(forResource: "GetPatient", ofType: "json")!
                    let data = NSData(contentsOfFile: path)!
                    self.stub(uri(PatientsServiceClient.endpointForPatients()), jsonData(data as Data, status: 200))
                    
                    var wasSuccess = false
                    var wasFailure = false
                    var patient: Patient!
                    try! self.patientsClient.get(id: id,
                                           onSuccess: { ptnt in
                                            wasSuccess = true
                                            patient = ptnt
                    },
                                           onError: {_ in
                                            wasFailure = true})
                    expect(wasSuccess).toEventually(beTrue())
                    expect(wasFailure).toEventually(beFalse())
                    expect(patient).toEventuallyNot(beNil())
                    if patient != nil {
                        expect(patient.username).to(equal("mddrill"))
                        expect(patient.email).to(equal("mddrill@email.com"))
                        expect(patient.firstName).to(equal("Matt"))
                        expect(patient.lastName).to(equal("Drill"))
                        expect(patient.doctors[0].firstName).to(equal("Donald"))
                        expect(patient.instructions[0].text).to(equal("Just stop being sick"))
                    }
                }
            }
            context("Didn't log in"){
                it("Throws a frontend error"){
                    CurrentUser.token = nil
                    
                    expect { try self.patientsClient.get(id: id,
                                                        onSuccess: {_ in},
                                                        onError: {_ in}
                        ) }.to(throwError(PatientError.notLoggedIn))
                }
            }
            context("Logged In as wrong user"){
                it("Returns a backend error, failure block runs"){
                    CurrentUser.token = "dummytoken"
                    var requestError: NSError!
                    
                    let error = NSError(domain: "Server Error", code: 401, userInfo: nil)
                    self.stub(uri(PatientsServiceClient.endpointForPatients(id: id)), failure(error))
                    
                    var wasSuccess = false
                    var wasFailure = false
                    expect { try self.patientsClient.get(id: id,
                                                        onSuccess: {_ in
                                                            wasSuccess = true
                    },
                                                        onError: {error in
                                                            wasFailure = true
                                                            requestError = error
                    })
                        }.toNot(throwError(PatientError.notLoggedIn))
                    
                    expect(wasSuccess).toEventually(beFalse())
                    expect(wasFailure).toEventually(beTrue())
                    expect(requestError).toEventuallyNot(beNil())
                    if(requestError != nil){
                        expect(requestError.code).toEventually(equal(401))
                    }
                }
            }
        }
    }
}

