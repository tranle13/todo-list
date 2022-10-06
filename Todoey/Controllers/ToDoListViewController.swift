import UIKit
import CoreData

class ToDoListViewController: UITableViewController {
	
	// Variables
	var items = [Item]()
	var selectedCategory: Category? {
		didSet {
			loadItems()
		}
	}
	let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

	override func viewDidLoad() {
		super.viewDidLoad()
	}

	// MARK: - TableView Datasource Methods
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return items.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let item = items[indexPath.row]
		let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
		var content = cell.defaultContentConfiguration()
		
		content.text = item.title
		cell.contentConfiguration = content
		cell.accessoryType = item.done ? .checkmark : .none
		return cell
	}
	
	// MARK: - TableView Delegate Methods
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		items[indexPath.row].done = !items[indexPath.row].done
		saveItems()
		tableView.deselectRow(at: indexPath, animated: true)
	}
	
	// MARK: - Add new items
	@IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
		let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
		let action = UIAlertAction(title: "Add Item", style: .default) { action in
			if let text = alert.textFields?[0].text {
				let newItem = Item(context: (self.context))
				newItem.title = text
				newItem.parentCategory = self.selectedCategory
				
				self.items.append(newItem)
				self.saveItems()
			}
		}
		alert.addAction(action)
		alert.addTextField { textfield in
			textfield.placeholder = "Create new item"
		}
		present(alert, animated: true, completion: nil)
	}
	
	// MARK: - Model manipulation methods
	func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate? = nil) {
		let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
		if let additionalPredicate = predicate {
			request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, additionalPredicate])
		} else {
			request.predicate = categoryPredicate
		}
		do {
			items = try context.fetch(request)
		} catch {
			print("Error fetching data from context \(error)")
		}
		tableView.reloadData()
	}
	
	func saveItems() {
		do {
			try context.save()
		} catch {
			print("Error saving context \(error)")
		}
		self.tableView.reloadData()
	}
}

// MARK: - UISearchBarDelegate methods
extension ToDoListViewController: UISearchBarDelegate {
	func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
		let request: NSFetchRequest<Item> = Item.fetchRequest()
		if let searchText = searchBar.text {
			request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
			loadItems(with: request, predicate: NSPredicate(format: "title CONTAINS[cd] %@", searchText))
		}
	}
	
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		if searchText.count == 0 {
			loadItems()
			
			DispatchQueue.main.async {
				searchBar.resignFirstResponder()
			}
		}
	}
}
