//
//  ListVC.swift
//  KheloTechAssignment
//
//  Created by Muskan Gupta on 01/10/24.
//

import UIKit
import CoreData
import Network

class ListVC: UIViewController,UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var sportTableView: UITableView!
    private var sports: [SportEntity] = []
    var filteredData: [String] = []
    var isSearching = false
    var dataArray = [String]()
    var monitor: NWPathMonitor?
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    override func viewDidLoad() {
        super.viewDidLoad()
        monitorNetwork()
        searchBar.placeholder = "Search Sports"
        searchBar.delegate = self
       
       }
    func monitorNetwork() {
            monitor = NWPathMonitor()
            let queue = DispatchQueue.global(qos: .background)
            monitor?.start(queue: queue)
            monitor?.pathUpdateHandler = { path in
                if path.status == .satisfied {
                    print("We're connected!")
                    DispatchQueue.main.async {
                        self.fetchSportsFromAPI()
                    }
                } else {
                    print("No connection.")
                    self.fetchSportsFromCoreData()
                }
                
                print("Is Expensive (Cellular): \(path.isExpensive)")
            }
        }
        deinit {
            monitor?.cancel()
        }
    // MARK: - UISearchBarDelegate
      
      func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
          if searchText.isEmpty {
              isSearching = false
              filteredData = dataArray
          } else {
              isSearching = true
              filteredData = dataArray.filter { $0.lowercased().contains(searchText.lowercased()) }
              
          }
          sportTableView.reloadData()
      }
      
      func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
          searchBar.text = ""
          isSearching = false
          filteredData = dataArray
          sportTableView.reloadData()
          searchBar.resignFirstResponder()
      }
private func fetchSportsFromAPI() {
      let networkService = NetworkService()
      networkService.fetchSports(context: context) { [weak self] result in
          switch result {
          case .success:
              self?.fetchSportsFromCoreData() // Fetch from Core Data after a successful API call
          case .failure(let error):
              print("Error fetching sports: \(error)")
              self?.fetchSportsFromCoreData() // Attempt to fetch from Core Data if API fails
          }
      }
  }

  private func fetchSportsFromCoreData() {
      guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
      let context = appDelegate.persistentContainer.viewContext

      let fetchRequest: NSFetchRequest<SportEntity> = SportEntity.fetchRequest()
      do {
          sports = try context.fetch(fetchRequest)
          DispatchQueue.main.async {
              for name in self.sports{
                  self.dataArray.append(name.sportName ?? "")
              }
              
              self.sportTableView.reloadData() // Update UI on the main thread
          }
      } catch {
          print("Failed to fetch sports from Core Data: \(error)")
      }
  }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearching {
                    return filteredData.count
                } else {
                    return sports.count
                }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListCell", for: indexPath) as! ListCell
        cell.bgView.layer.cornerRadius = 25
        cell.lblStatus.layer.masksToBounds = true
        cell.lblStatus.layer.cornerRadius = 12
        let sport = sports[indexPath.row]
        if isSearching {
            cell.lblName?.text = filteredData[indexPath.row]
               } else {
                           cell.lblName?.text =  (sport.sportName ?? "")
                           cell.lblId?.text =  String(sport.sportID)
                           cell.lblStatus?.text = (sport.status ?? "")
               }
        return cell
    }
    // Swipe to delete the row and remove it from Core Data
      func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
          if editingStyle == .delete {
              // Get the item to delete
              let itemToDelete = sports[indexPath.row]
              
              // Delete the item from Core Data
              context.delete(itemToDelete)
              
              // Save the context
              do {
                  try context.save()
              } catch {
                  print("Failed to save context after deletion: \(error)")
              }
              
              // Remove the item from the array
              sports.remove(at: indexPath.row)
              
              // Delete the row from the table view
              sportTableView.deleteRows(at: [indexPath], with: .fade)
          }
      }
}
