//
//  Settings.swift
//  MyWorkout
//
//  Created by Ligmab Allz on 14/02/23.
//

import SwiftUI

// MARK: - Weight
struct ExList: Codable, Identifiable, Hashable, Comparable {
    var id, name: String
    
    static func <(lhs: ExList, rhs: ExList) -> Bool {
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
    var dropWeight: Double
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
    var weight: Double
}
