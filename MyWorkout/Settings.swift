//
//  Settings.swift
//  MyWorkout
//
//  Created by Ligmab Allz on 14/02/23.
//

import SwiftUI

// MARK: - Settings
struct Settings: Codable {
    var defaultREST: Int
    var lastREST, imperial: Bool
    var weights: [Weight]

    enum CodingKeys: String, CodingKey {
        case defaultREST = "defaultRest"
        case lastREST = "lastRest"
        case imperial, weights
    }
}

// MARK: - Weight
struct Weight: Codable, Identifiable, Hashable, Comparable {
    var id, name: String
    
    static func <(lhs: Weight, rhs: Weight) -> Bool {
            return lhs.name < rhs.name
        }
}

// MARK: - Setting
struct Workout: Codable, Identifiable, Hashable {
    var id, name: String
    var exercises: [Exercise]
}

// MARK: - Exercise
struct Exercise: Codable, Identifiable, Hashable {
    var id: String
    var exID: String
    var rest, dropSet: Int
    var dropWeight: Float
    var sets: [Set]
    var superset: Bool
    
    enum CodingKeys: String, CodingKey {
            case id
            case exID = "exId"
            case rest, dropSet, dropWeight, sets, superset
        }
}

// MARK: - Set
struct Set: Codable, Identifiable, Hashable {
    var id: String
    var reps: Int
    var weight: Float
}
