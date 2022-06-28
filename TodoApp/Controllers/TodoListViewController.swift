//
//  ViewController.swift
//  TodoApp
//
//  Created by Moh. Absar Rahman on 31/5/22.
//

import UIKit
import CoreData
import ChameleonFramework

class TodoListViewController: SwipeTableViewController {
    
    var itemArray:[ItemModel] = []
    
    var selectedCategory: CategoryModel? {
        didSet {
            loadItemData()
        }
    }
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    //let defaults = UserDefaults.standard
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        print("In viewDidLoad \(dataFilePath)")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if let colorHex = selectedCategory?.color {
            title = selectedCategory!.name
            guard let navBar = navigationController?.navigationBar else {fatalError("Navigation controller does not exist")}
            
            if let navBarColor = UIColor(hexString: colorHex) {
                navBar.scrollEdgeAppearance?.backgroundColor = navBarColor
                navBar.standardAppearance.backgroundColor =  navBarColor
                let contrastColor: UIColor = ContrastColorOf(navBarColor, returnFlat: true)
                navBar.tintColor = contrastColor
                view.backgroundColor = navBarColor
                searchBar.barTintColor = navBarColor
                navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor:contrastColor]
            }
            
        }
    }
    
    //MARK: - Table View functions
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        cell.backgroundColor = UIColor(hexString: (selectedCategory?.color)!)?.darken(byPercentage: CGFloat(indexPath.row)/CGFloat(itemArray.count))
        if itemArray[indexPath.row].isDone {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        var content = cell.defaultContentConfiguration()
        content.text = itemArray[indexPath.row].title
        content.textProperties.color = ContrastColorOf(cell.backgroundColor!, returnFlat: true)
        cell.contentConfiguration = content
        
        cell.accessoryType = itemArray[indexPath.row].isDone ? .checkmark : .none
        
        saveItemData()
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //print("Selected \(indexPath.row)")
        itemArray[indexPath.row].isDone = !itemArray[indexPath.row].isDone
        
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.reloadData()
    }
    
    //MARK: - ADD Button Function
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add new item", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add item", style: .default) { [self](action) in
            
            let value = textField.text ?? "OK"
            let item = ItemModel(context: context)
            item.title = value
            item.isDone = false
            item.parentCategory = selectedCategory
            itemArray.append(item)
            
            saveItemData()
            
            tableView.reloadData()
        }
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
            
        }
        alert.addAction(action)
        present(alert, animated: true)
    }
    
    
    //MARK: -  Save items
    func saveItemData() {
        
        do {
            try context.save()
        } catch {
            print("Error saving context \(error)")
        }
    }
    
    //MARK: -  Load items
    func loadItemData(request: NSFetchRequest<ItemModel> = ItemModel.fetchRequest(), predicate: NSPredicate? = nil) {
        
        let categoryPredicate = NSPredicate(format: "parentCategory.name == %@", selectedCategory!.name!)
        if let additionalPredicate = predicate {
            
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate,additionalPredicate])
        } else {
            request.predicate = categoryPredicate
        }
        
        
        do {
            itemArray = try context.fetch(request)
        } catch {
            print("Error fetching data \(error)")
        }
        
        tableView.reloadData()
        
    }
    
    override func updateModel(at indexPath: IndexPath) {
        context.delete(itemArray.remove(at: indexPath.row))
        saveItemData()
    }
}

//MARK: - Search bar methods
extension TodoListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request: NSFetchRequest<ItemModel> = ItemModel.fetchRequest()
        
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        
        request.predicate = predicate
        print("SEARCH TEXT ITEM \(searchBar.text!)")
        let sortDescriptor = NSSortDescriptor(key: "title", ascending: true)
        request.sortDescriptors = [sortDescriptor]
        
        searchBar.text!.isEmpty ? loadItemData(predicate: predicate) : loadItemData(request: request,predicate: predicate)
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text!.isEmpty {
            print("TRIGGERED")
            loadItemData()
            
            //RUNS IN FOREGROUND
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}
