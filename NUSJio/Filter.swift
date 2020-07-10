//
//  Filter.swift
//  NUSJio
//
//  Created by Zeling Long on 2020/7/3.
//  Copyright © 2020 Zeling Long. All rights reserved.
//

import Foundation
    
struct Filter {
    var categories: [String]?
    var numOfParticipants: Int?
    var gender: Gender?
    var faculties: [String]?
    var selectedFacultiesBoolArray: [Bool]
        
    static func filterToTags(filter: Filter) -> [String] {
        var tags: [String] = []
        if let categories = filter.categories {
            tags.append(contentsOf: categories)
        }
        if let gender = filter.gender {
            tags.append(gender.description)
        }
        if let faculties = filter.faculties {
            tags.append(contentsOf: faculties)
        }
        if let numOfParticipants = filter.numOfParticipants {
            tags.append("\(numOfParticipants) participants")
        }
        return tags
    }
}

enum Gender: CustomStringConvertible {
       case mixed
       case male
       case female
       
       var description: String {
           switch self {
           case .mixed:
               return "Mixed Gender"
           case .male:
               return "Males Only"
           case .female:
               return "Females Only"
       }
    }
}
