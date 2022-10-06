import UIKit
import RealmSwift

class ToDoListViewController: UITableViewController {
	
	let realm = try! Realm()
	var todoItems: Results<Item>?
	var selectedCategory: Category? {
		didSet {
			loadItems()
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()
	}

	// MARK: - TableView Datasource Methods
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return todoItems?.count ?? 1
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
		var content = cell.defaultContentConfiguration()
		if let item = todoItems?[indexPath.row] {
			content.text = item.title
			cell.accessoryType = item.done ? .checkmark : .none
		} else {
			content.text = "No Items Added"
		}
		cell.contentConfiguration = content
		return cell

	}
	
	// MARK: - TableView Delegate Methods
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if let item = todoItems?[indexPath.row] {
			do {
				try realm.write({
					item.done = !item.done
				})
			} catch {
				print("Error saving done status, \(error)")
			}
		}
		tableView.reloadData()
		tableView.deselectRow(at: indexPath, animated: true)
	}
	
	// MARK: - Add new items
	@IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
		let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
		let action = UIAlertAction(title: "Add Item", style: .default) { action in
			if let text = alert.textFields?[0].text, let currentCategory = self.selectedCategory {
				do {
					try self.realm.write({
						let item = Item()
						item.title = text
						item.dateCreated = Date()
						currentCategory.items.append(item)
					})
				} catch {
					print("Error saving new items, \(error)")
				}
			}
			self.tableView.reloadData()
		}
		alert.addAction(action)
		alert.addTextField { textfield in
			textfield.placeholder = "Create new item"
		}
		present(alert, animated: true, completion: nil)
	}
	
	// MARK: - Model manipulation methods
	func loadItems() {
		todoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
		tableView.reloadData()
	}
	
	func saveItems(new item: Item) {
		do {
			try realm.write({
				realm.add(item)
			})
		} catch {
			print("Error saving context \(error)")
		}
		self.tableView.reloadData()
	}
}

// MARK: - UISearchBarDelegate methods
extension ToDoListViewController: UISearchBarDelegate {
	func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
		if let searchText = searchBar.text {
			todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchText).sorted(byKeyPath: "dateCreated", ascending: true)
			tableView.reloadData()
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
