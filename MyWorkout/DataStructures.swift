//
//  Settings.swift
//  MyWorkout
//
//  Created by Ligmab Allz on 14/02/23.
//

import SwiftUI

// MARK: - Weight
struct ExList: Codable, Identifiable, Hashable, Comparable {
    var id: UUID
    var name: String
    var topWeight: Double
    static func <(lhs: ExList, rhs: ExList) -> Bool {
            return lhs.name < rhs.name
        }
}

// MARK: - Setting
struct Workout: Codable, Identifiable, Hashable {
    var id: UUID
    var name: String
    var exercises: [Exercise]
}

// MARK: - Exercise
struct Exercise: Codable, Identifiable, Hashable {
    var id, exID: UUID
    var maxWeight: Double
    var rmOrW: Bool
    var rest, dropSet: Int
    var dropWeight: Double
    var warmingSets: [Set]
    var sets: [Set]
    var superset: Bool
    
    enum CodingKeys: String, CodingKey {
            case id
            case exID = "exId"
            case maxWeight, rmOrW, rest, dropSet, dropWeight, warmingSets, sets, superset
        }
}

// MARK: - Set
struct Set: Codable, Identifiable, Hashable {
    var id: UUID
    var nSets, reps: Int
    var weight: Double
}
