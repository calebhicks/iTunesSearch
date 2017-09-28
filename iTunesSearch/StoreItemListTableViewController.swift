
import UIKit

class StoreItemListTableViewController: UITableViewController {
    
    @IBOutlet weak var filterSegmentedControl: UISegmentedControl!
    
    let itemController = StoreItemController()
    
    var items = [StoreItem]()
    
    let queryOptions = ["movie", "music", "software", "ebook"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.delegate = self
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    func fetchMatchingItems() {
        
        let searchTerm = navigationItem.searchController?.searchBar.text ?? ""
        let mediaType = queryOptions[filterSegmentedControl.selectedSegmentIndex]
        
        if !searchTerm.isEmpty {
            let query = [
                "term": searchTerm,
                "lang": "en_us",
                "media": mediaType
            ]
            
            itemController.fetchItems(matching: query, completion: { (items) in
                if let items = items {
                    self.items = items
                    self.tableView.reloadData()
                } else {
                    print("Unable to load data.")
                }
            })
        }
    }
    
    
    @IBAction func filterOptionUpdated(_ sender: UISegmentedControl) {
        fetchMatchingItems()
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath)
        configure(cell: cell, forItemAt: indexPath)
        return cell
    }
    
    func configure(cell: UITableViewCell, forItemAt indexPath: IndexPath) {
        let item = items[indexPath.row]
        
        cell.textLabel?.text = item.name
        cell.detailTextLabel?.text = item.artist
        
        if let imageData = try? Data(contentsOf: item.artworkURL) {
            let image = UIImage(data: imageData)
            cell.imageView?.image = image
        }
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension StoreItemListTableViewController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.text = ""
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        fetchMatchingItems()
    
        // Dismiss search bar to allow user to scroll immediately after searching
        self.navigationItem.searchController?.dismiss(animated: true, completion: nil)
    }
}
