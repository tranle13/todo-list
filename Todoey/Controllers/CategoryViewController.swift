import UIKit
import RealmSwift

class CategoryViewController: SwipeTableViewController {
	
	var categories: Results<Category>?
	let realm = try! Realm()

	override func viewDidLoad() {
		super.viewDidLoad()
		loadCategories()
	}
	
	// MARK: - Data manipulation methods
	func loadCategories() {
		categories = realm.objects(Category.self)
		tableView.reloadData()
	}
	
	func saveCategories(new category: Category) {
		do {
			try realm.write({
				realm.add(category)
			})
		} catch {
			print("Error saving categories \(error)")
		}
		tableView.reloadData()
	}
	
	// Delete category
	override func updateModel(at indexPath: IndexPath) {
		if let category = categories?[indexPath.row] {
			do {
				try realm.write {
					realm.delete(category)
				}
			} catch {
				print("Error deleting category, \(error)")
			}
		}
	}
	
	// MARK: - Add new category
	@IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
		let alert = UIAlertController(title: "Add New Todoey Category", message: "", preferredStyle: .alert)
		let action = UIAlertAction(title: "Add Category", style: .default) { action in
			if let text = alert.textFields?[0].text {
				let category = Category()
				category.name = text
				self.saveCategories(new: category)
			}
		}
		alert.addAction(action)
		alert.addTextField { textField in
			textField.placeholder = "Create new category"
		}
		present(alert, animated: true, completion: nil)
	}

	// MARK: - UITableViewDataSource methods
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return categories?.count ?? 1
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = super.tableView(tableView, cellForRowAt: indexPath)
		var content = cell.defaultContentConfiguration()
		content.text = categories?[indexPath.row].name ?? "No Categories Added Yet"
		cell.contentConfiguration = content
		return cell
	}
	
	// MARK: - UITableViewDelegate methods
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		performSegue(withIdentifier: "goToItems", sender: self)
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		let destinationVC = segue.destination as! ToDoListViewController
		if let indexPath = tableView.indexPathForSelectedRow {
			destinationVC.selectedCategory = categories?[indexPath.row]
		}
	}
}
