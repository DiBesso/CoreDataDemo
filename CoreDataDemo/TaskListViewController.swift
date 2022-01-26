//
//  ViewController.swift
//  CoreDataDemo
//
//  Created by brubru on 24.01.2022.
//

import UIKit

class TaskListViewController: UITableViewController {
    
    var storageManager = StorageManager ()
    private let context = (UIApplication.shared.delegate as! AppDelegate).storageManager.persistentContainer.viewContext
    
    private let cellID = "task"
    private var taskList: [Task] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        setupNavigationBar()
        fetchData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchData()
        tableView.reloadData()
    }
 
    private func setupNavigationBar() {
        title = "Task List"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let navBarAppearence = UINavigationBarAppearance()
        navBarAppearence.configureWithOpaqueBackground()
        navBarAppearence.titleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearence.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        navBarAppearence.backgroundColor = UIColor(
            red: 21/255,
            green: 101/255,
            blue: 192/255,
            alpha: 194/255
        )
        
        navigationController?.navigationBar.standardAppearance = navBarAppearence
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearence
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addNewTask)
        )
        
        navigationController?.navigationBar.tintColor = .white
        
    }
    
    @objc private func addNewTask() {
        showAlert(with: "New Task", and: "What do you want to do?")
    }
    
    private func fetchData() {
        let fetchRequest = Task.fetchRequest()
        
        do {
            taskList = try context.fetch(fetchRequest)
        } catch {
           print("Faild to fetch data", error)
        }
    }
    
    // MARK: - Alert
    
    private func showAlert(with title: String, and message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            guard let task = alert.textFields?.first?.text, !task.isEmpty else { return }
            self.save(task)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        alert.addTextField { textField in
            textField.placeholder = "New Task"
        }
        present(alert, animated: true)
    }
    
    private func showAlertForSetup(with title: String, and message: String){
        
       let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
       let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
           guard let task = alert.textFields?.first?.text, !task.isEmpty else { return }
           self.saveSetup(task)

       }
       
       let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
       
       alert.addAction(saveAction)
       alert.addAction(cancelAction)
       alert.addTextField { textField in
           textField.placeholder = "New Task"
       }
       present(alert, animated: true)
   }
    
    // MARK: - Saving Methods
    
    private func saveSetup(_ taskName:String) {
        let task = Task(context: context)
        task.name = taskName
        taskList.append(task)
        
        // Вот в этом месте не понимаю, как обратиться к той же самой ячейке, которую я хочу отредактировать
        
//        let cellIndex = IndexPath(row: taskList.count, section: 0)
//        tableView.cellForRow(at: cellIndex)
        
        do {
            try context.save()
        } catch let error {
            print(error)
        }
    }
    
    private func save(_ taskName: String) {
        
        let task = Task(context: context)
        task.name = taskName
        taskList.append(task)
        
        let cellIndex = IndexPath(row: taskList.count - 1, section: 0)
        tableView.insertRows(at: [cellIndex], with: .automatic)
        
        do {
            try context.save()
        } catch let error {
            print(error)
        }
    }
}

// MARK: - Extension

extension TaskListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        taskList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        let task = taskList[indexPath.row]
        
        var content = cell.defaultContentConfiguration()
        content.text = task.name
        cell.contentConfiguration = content
        
        return cell
    }
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {

            // тут не могу правильно прописать удаление из coreData
            
            taskList.remove(at: indexPath.row)
        }
        do {
            try context.save()
            tableView.deleteRows(at: [indexPath], with: .automatic)
        } catch let error {
            print(error)
        }
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let setup = setupAction(at: indexPath)
        return UISwipeActionsConfiguration(actions: [setup])
    }
    
    func setupAction (at indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .normal, title: "Setup") { _,_,_ in
            self.showAlertForSetup(with: "Save", and: "")
            
        }
        return action
    }
}
