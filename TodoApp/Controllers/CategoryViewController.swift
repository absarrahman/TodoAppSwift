//
//  CategoryViewController.swift
//  TodoApp
//
//  Created by Moh. Absar Rahman on 27/6/22.
//

import UIKit
import CoreData
import ChameleonFramework

class CategoryViewController: SwipeTableViewController {
    
    var categoryArray:[CategoryModel] = []
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategoryData()
        
    }
    
    //MARK: - TableView Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //THIS function is for giving total number of items
        return categoryArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // This function is for creating the cell/item of the table
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if (categoryArray[indexPath.row].color == nil) {
            let cellColor = UIColor.randomFlat()
            categoryArray[indexPath.row].color = cellColor.hexValue()
            cell.backgroundColor = cellColor
        } else {
            cell.backgroundColor = UIColor(hexString: categoryArray[indexPath.row].color!)
        }
        
        
        var content = cell.defaultContentConfiguration()
        content.text = categoryArray[indexPath.row].name
        content.textProperties.color = ContrastColorOf(cell.backgroundColor!, returnFlat: true)
        cell.contentConfiguration = content
        
        saveCategoryData()
        
        return cell
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        guard let navBar = navigationController?.navigationBar else {fatalError("Navigation controller does not exist")}
        
        navBar.scrollEdgeAppearance?.backgroundColor = .red
        navBar.standardAppearance.backgroundColor =  .red
        
        
        
        
    }
    
    
    //MARK: - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // THIS function is for selecting row cells
        //print("Selected \(indexPath.row)")
        performSegue(withIdentifier: "goToItems", sender: self)
        
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController
        if let indexPath = tableView.indexPathForSelectedRow{
            destinationVC.selectedCategory = categoryArray[indexPath.row]
        }
    }
    
    
    
    //MARK: - Data Manipulation Methods
    
    //MARK: -  Save items
    func saveCategoryData() {
        
        do {
            try context.save()
        } catch {
            print("Error saving context \(error)")
        }
    }
    
    //MARK: - Load Items
    func loadCategoryData(request: NSFetchRequest<CategoryModel> = CategoryModel.fetchRequest()) {
        
        do {
            categoryArray = try context.fetch(request)
        } catch {
            print("Error fetching data \(error)")
        }
        
        tableView.reloadData()
        
    }
    
    //MARK: - Remove items
    
    override func updateModel(at indexPath: IndexPath) {
        context.delete(categoryArray.remove(at: indexPath.row))
        saveCategoryData()
    }
    
    
    
    //MARK: - Add new categories
    
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add new category", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add category", style: .default) { [self](action) in
            
            let value = textField.text ?? "OK"
            let category = CategoryModel(context: context)
            category.name = value
            
            categoryArray.append(category)
            
            saveCategoryData()
            
            tableView.reloadData()
        }
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
            
        }
        alert.addAction(action)
        present(alert, animated: true)
    }
    
    
    
}
