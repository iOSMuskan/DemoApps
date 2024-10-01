//
//  NetworkService.swift
//  KheloTechAssignment
//
//  Created by Muskan Gupta on 01/10/24.
//

import Foundation
import CoreData
import UIKit

class NetworkService {
    func fetchSports(context: NSManagedObjectContext, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "https://admin.37nationalgamesgoa.in/api/mock/get_all_sport_list") else {
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                return
            }

            do {
                let sportModel = try JSONDecoder().decode(SportModel.self, from: data)
                print(sportModel.data)
                // Save to Core Data
                for sport in sportModel.data {
                    let sportEntity = SportEntity(context: context)
                    sportEntity.sportID = Int64(sport.sportID)
                    sportEntity.nsrsSportID = Int64(sport.nsrsSportID)
                    sportEntity.sportName = sport.sportName
                    sportEntity.rfSportDBName = sport.rfSportDBName
                    sportEntity.status = sport.status
                }

                // Save the context
                try context.save()
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }

        task.resume()
    }
}
