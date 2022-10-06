import UIKit
import CoreData

class CategoryViewController: UITableViewController {
	
	var categories = [Category]()
	let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

	override func viewDidLoad() {
		super.viewDidLoad()
		loadCategories()
	}
	
	// MARK: - Data manipulation methods
	func loadCategories(request: NSFetchRequest<Category> = Category.fetchRequest()) {
		do {
			categories = try context.fetch(request)
		} catch {
			print("Error loading categories \(error)")
		}
		tableView.reloadData()
	}
	
	func saveCategories() {
		do {
			try context.save()
		} catch {
			print("Error saving categories \(error)")
		}
		tableView.reloadData()
	}
	
	// MARK: - Add new category
	@IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
		let alert = UIAlertController(title: "Add New Todoey Category", message: "", preferredStyle: .alert)
		let action = UIAlertAction(title: "Add Category", style: .default) { action in
			if let text = alert.textFields?[0].text {
				let newCategory = Category(context: self.context)
				newCategory.name = text
				
				self.categories.append(newCategory)
				self.saveCategories()
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
		return categories.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
		
		var content = cell.defaultContentConfiguration()
		content.text = categories[indexPath.row].name
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
			destinationVC.selectedCategory = categories[indexPath.row]
		}
	}
}
