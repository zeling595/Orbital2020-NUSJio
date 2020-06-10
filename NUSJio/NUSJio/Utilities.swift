//
//  Utilities.swift
//  NUSJio
//
//  Created by Zeling Long on 2020/6/4.
//  Copyright © 2020 Zeling Long. All rights reserved.
//

import Foundation
class Utilities {
    static func isNUSNETIDValid(_ NUSNETID: String) -> Bool {
        let NUSNETIDTest1 = NSPredicate(format: "SELF MATCHES %@","^nusstu\\[a-z][0-9]{7}$")
        
        let NUSNETIDTest2 = NSPredicate(format: "SELF MATCHES %@","^nusstf\\[a-z][0-9]{7}$")
        
        let NUSNETIDTest3 = NSPredicate(format: "SELF MATCHES %@","^nusext\\[a-z][0-9]{7}$")
        
        let NUSNETIDTest4 = NSPredicate(format: "SELF MATCHES %@","^[a-z][0-9]{7}@nusstu$")
        
        let NUSNETIDTest5 = NSPredicate(format: "SELF MATCHES %@","^[a-z][0-9]{7}@nusstf$")
        
        let NUSNETIDTest6 = NSPredicate(format: "SELF MATCHES %@","^[a-z][0-9]{7}@nusext$")
        
        return NUSNETIDTest1.evaluate(with: NUSNETID) || NUSNETIDTest2.evaluate(with: NUSNETID) || NUSNETIDTest3.evaluate(with: NUSNETID) || NUSNETIDTest4.evaluate(with: NUSNETID) || NUSNETIDTest5.evaluate(with: NUSNETID) || NUSNETIDTest6.evaluate(with: NUSNETID)
    }
    
    static func isNUSEmailValid(_ NUSEmail: String) -> Bool {
        let defaultEmailTest = NSPredicate(format: "SELF MATCHES %@","[a-z][0-9]{7}@u.nus.edu")
        let friendlyEmailTest1 = NSPredicate(format: "SELF MATCHES %@","[a-zA-Z0-9._]+@nus.edu.sg")
        let friendlyEmailTest2 = NSPredicate(format: "SELF MATCHES %@","[a-zA-Z0-9._]+@u.nus.edu")
        return defaultEmailTest.evaluate(with: NUSEmail) || friendlyEmailTest1.evaluate(with: NUSEmail) || friendlyEmailTest2.evaluate(with: NUSEmail)
    }
}
