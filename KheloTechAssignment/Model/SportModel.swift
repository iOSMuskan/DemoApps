//
//  SportModel.swift
//  KheloTechAssignment
//
//  Created by Muskan Gupta on 01/10/24.
//

import Foundation
// MARK: - Welcome
struct SportModel: Codable {
    let status: String
    let statusCode: Int
    let message: String
    let data: [Datum]
}

struct Datum: Codable {
    let sportID: Int
    let nsrsSportID: Int
    let sportName: String
    let rfSportDBName: String
    let status: String // Change to String as it was a simple type

    enum CodingKeys: String, CodingKey {
        case sportID = "sport_id"
        case nsrsSportID = "nsrs_sport_id"
        case sportName = "sport_name"
        case rfSportDBName = "rf_sport_db_name"
        case status
    }
}
