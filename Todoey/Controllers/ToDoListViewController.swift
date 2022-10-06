import UIKit

class ToDoListViewController: UITableViewController {
	
	// Variables
	var items = [Item]()
	let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")

	override func viewDidLoad() {
		super.viewDidLoad()
		loadItems()
	}

	// MARK: - TableView Datasource Methods
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		items.count
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
				let newItem = Item()
				newItem.title = text
				
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
	func loadItems() {
		if let data = try? Data(contentsOf: dataFilePath!) {
			let decoder = PropertyListDecoder()
			do {
				items = try decoder.decode([Item].self, from: data)
			} catch {
				print("Error decoding items, \(error)")
			}
		}
	}
	
	func saveItems() {
		let encoder = PropertyListEncoder()
		do {
			let data = try encoder.encode(items)
			try data.write(to: dataFilePath!)
		} catch {
			print("Error encoding items, \(error)")
		}
		
		self.tableView.reloadData()
	}
}

