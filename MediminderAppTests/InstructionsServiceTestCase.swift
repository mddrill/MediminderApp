//
//  InstructionsTestCase.swift
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

class InstructionsServiceTestCase: QuickSpec {
    let instructionsClient = InstructionsServiceClient.sharedInstance
    
    override func spec() {
        let patientId = 1
        super.spec()
        
        describe("Create Instruction"){
            let testText = "Test Text"
            context("Without Logging In") {
                it("Throws a frontend error") {
                    CurrentUser.token = nil
                    expect{ try self.instructionsClient.create(patient: patientId,
                                                        text: testText,
                                                       onSuccess: {_ in},
                                                       onError: {_ in})
                        }.to(throwError(InstructionError.notLoggedIn))
                }
            }
            context("After Logging In") {
                it("Does not throw or return an error, run success block, not failure block") {
                    CurrentUser.token = "dummytoken"
                    var requestError: NSError!
                    
                    let path = Bundle(for: type(of: self)).path(forResource: "CreateInstruction", ofType: "json")!
                    let data = NSData(contentsOfFile: path)!
                    self.stub(uri(InstructionsServiceClient.endpointForInstructions()), jsonData(data as Data, status: 201))
                    
                    var wasSuccess = false
                    var wasFailure = false
                    expect{ try self.instructionsClient
                        .create(patient: patientId, text: testText,
                                onSuccess: {_ in
                                    wasSuccess = true
                        },
                                onError:{ error in
                                    wasFailure = true
                                    requestError = error
                        })
                        }.toNot(throwError())
                    expect(wasSuccess).toEventually(beTrue())
                    expect(wasFailure).toEventually(beFalse())
                    expect(requestError).toEventually(beNil())
                }
            }
            // The UI should keep the user from being able to try to create an instruction as a patient, but this is here just in case
            context("After Logging In as pateint") {
                it("Throws front end error") {
                    CurrentUser.token = nil
                    expect{ try self.instructionsClient.create(patient: patientId,
                                                               text: testText,
                                                               onSuccess: {_ in},
                                                               onError: {_ in})
                        }.to(throwError(InstructionError.notDoctor))
                }
            }
            
            context("Getting a server error") {
                it("Does not throw frontend errror but returns a backend one, runs failure block, not success block") {
                    CurrentUser.token = "dummytoken"
                    var requestError: NSError!
                    
                    let error = NSError(domain: "Server Error", code: 500, userInfo: nil)
                    self.stub(uri(InstructionsServiceClient.endpointForInstructions()), failure(error))
                    
                    var wasSuccess = false
                    var wasFailure = false
                    expect{ try self.instructionsClient
                        .create(patient: patientId,
                                text: testText,
                                onSuccess: {_ in
                                    wasSuccess = true
                        },
                                onError:{ error in
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
        describe("Edit Instructions") {
            let testText = "Test Text"
            let id = 1
            context("Not Logged In"){
                it("Throws a frontend error"){
                    CurrentUser.token = nil
                    
                    expect { try self.instructionsClient.edit(id: id,
                                                      text: testText,
                                                      onSuccess: {_ in},
                                                      onError: {_ in}
                        ) }.to(throwError(InstructionError.notLoggedIn))
                }
            }
            context("Logged In"){
                it("Runs success block, not failure block"){
                    CurrentUser.token = "dummytoken"
                    let path = Bundle(for: type(of: self)).path(forResource: "EditInstruction", ofType: "json")!
                    let data = NSData(contentsOfFile: path)!
                    self.stub(uri(InstructionsServiceClient.endpointForInstructions(id: id)), jsonData(data as Data))
                    
                    var wasSuccess = false
                    var wasFailure = false
                    expect { try self.instructionsClient.edit(id: id,
                                                      text: testText,
                                                      onSuccess: {_ in
                                                        wasSuccess = true
                    },
                                                      onError: {error in
                                                        wasFailure = true
                    })
                        }.toNot(throwError(InstructionError.notLoggedIn))
                    
                    expect(wasSuccess).toEventually(beTrue())
                    expect(wasFailure).toEventually(beFalse())
                }
                
            }
            // The UI should keep the user from being able to try to create an instruction as a patient, but this is here just in case
            context("After Logging In as patient") {
                it("Throws front end error") {
                    CurrentUser.token = nil
                    expect{ try self.instructionsClient.edit(id:id,
                                                              text: testText,
                                                               onSuccess: {_ in},
                                                               onError: {_ in})
                        }.to(throwError(InstructionError.notDoctor))
                }
            }
            context("Logged In as wrong user"){
                it("Returns a backend error, failure block runs"){
                    CurrentUser.token = "dummytoken"
                    var requestError: NSError!
                    
                    let error = NSError(domain: "Server Error", code: 401, userInfo: nil)
                    self.stub(uri(InstructionsServiceClient.endpointForInstructions(id: id)), failure(error))
                    
                    var wasSuccess = false
                    var wasFailure = false
                    expect { try self.instructionsClient.edit(id: id,
                                                      text: testText,
                                                      onSuccess: {_ in
                                                        wasSuccess = true
                    },
                                                      onError: {error in
                                                        wasFailure = true
                                                        requestError = error
                    })
                        }.toNot(throwError(InstructionError.notLoggedIn))
                    
                    expect(wasSuccess).toEventually(beFalse())
                    expect(wasFailure).toEventually(beTrue())
                    expect(requestError).toEventuallyNot(beNil())
                    if(requestError != nil){
                        expect(requestError.code).toEventually(equal(401))
                    }
                }
            }
            context("Server error") {
                it("Returns a backend error, failure block runs"){
                    CurrentUser.token = "dummytoken"
                    var requestError: NSError!
                    
                    let error = NSError(domain: "Server Error", code: 500, userInfo: nil)
                    self.stub(uri(InstructionsServiceClient.endpointForInstructions(id: id)), failure(error))
                    
                    var wasSuccess = false
                    var wasFailure = false
                    expect { try self.instructionsClient.edit(id: id,
                                                      text: testText,
                                                      onSuccess: {_ in
                                                        wasSuccess = true
                    },
                                                      onError: {error in
                                                        wasFailure = true
                                                        requestError = error
                    })
                        }.toNot(throwError(InstructionError.notLoggedIn))
                    
                    expect(wasSuccess).toEventually(beFalse())
                    expect(wasFailure).toEventually(beTrue())
                    expect(requestError).toEventuallyNot(beNil())
                    if(requestError != nil){
                        expect(requestError.code).toEventually(equal(500))
                    }
                }
            }
        }
        describe("Delete Instruction") {
            let id = 1
            context("Not Logged In"){
                it("Throws a frontend error"){
                    CurrentUser.token = nil
                    
                    expect { try self.instructionsClient.delete(id: id,
                                                        onSuccess: {_ in},
                                                        onError: {_ in}
                        )
                        }.to(throwError(InstructionError.notLoggedIn))
                }
            }
            context("Logged In"){
                it("Does not throw or return an error"){
                    CurrentUser.token = "dummytoken"
                    var requestError: Error!
                    
                    let path = Bundle(for: type(of: self)).path(forResource: "DeleteInstruction", ofType: "json")!
                    let data = NSData(contentsOfFile: path)!
                    self.stub(uri(InstructionsServiceClient.endpointForInstructions(id: id)), jsonData(data as Data, status: 204))
                    
                    var wasSuccess = false
                    var wasFailure = false
                    expect { try self.instructionsClient.delete(id: id,
                                                        onSuccess: {_ in
                                                            wasSuccess = true
                    },
                                                        onError: {error in
                                                            wasFailure = true
                    })
                        }.toNot(throwError(InstructionError.notLoggedIn))
                    
                    expect(wasSuccess).toEventually(beTrue())
                    expect(wasFailure).toEventually(beFalse())
                    expect(requestError).toEventually(beNil())
                    
                }
                
            }
            context("Logged In as wrong user"){
                it("Returns a backend error"){
                    CurrentUser.token = "dummytoken"
                    var requestError: NSError!
                    
                    let error = NSError(domain: "Server Error", code: 401, userInfo: nil)
                    self.stub(uri(InstructionsServiceClient.endpointForInstructions(id: id)), failure(error))
                    
                    var wasSuccess = false
                    var wasFailure = false
                    expect { try self.instructionsClient.delete(id: id,
                                                        onSuccess: {_ in
                                                            wasSuccess = true
                    },
                                                        onError: {error in
                                                            wasFailure = true
                                                            requestError = error
                    })
                        }.toNot(throwError(InstructionError.notLoggedIn))
                    
                    expect(wasSuccess).toEventually(beFalse())
                    expect(wasFailure).toEventually(beTrue())
                    expect(requestError).toEventuallyNot(beNil())
                    if(requestError != nil){
                        expect(requestError.code).toEventually(equal(401))
                    }
                }
            }
            context("Server error") {
                it("Returns a backend error"){
                    CurrentUser.token = "dummytoken"
                    var requestError: NSError!
                    
                    let error = NSError(domain: "Server Error", code: 500, userInfo: nil)
                    self.stub(uri(InstructionsServiceClient.endpointForInstructions(id: id)), failure(error))
                    
                    var wasSuccess = false
                    var wasFailure = false
                    expect { try self.instructionsClient.delete(id: id,
                                                        onSuccess: {_ in
                                                            wasSuccess = true
                    },
                                                        onError: {error in
                                                            wasFailure = true
                                                            requestError = error
                    })
                        }.toNot(throwError(InstructionError.notLoggedIn))
                    
                    expect(wasSuccess).toEventually(beFalse())
                    expect(wasFailure).toEventually(beTrue())
                    expect(requestError).toEventuallyNot(beNil())
                    if(requestError != nil){
                        expect(requestError.code).toEventually(equal(500))
                    }
                }
            }
        }
    }
}
