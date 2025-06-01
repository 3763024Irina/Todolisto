import UIKit

final class TaskListViewController: UIViewController {
    private var tasks: [TaskModel] = []
    var presenter: TaskListPresenterProtocol?

    private let tableView = UITableView()
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Todolisto"
        view.backgroundColor = .white

        setupTableView()
        setupAddButton()

        presenter?.viewDidLoad()
    }

    private func setupTableView() {
        view.addSubview(tableView)
        tableView.frame = view.bounds
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "TaskCell")
    }

    private func setupAddButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addTaskTapped)
        )
    }

    @objc private func addTaskTapped() {
        let alert = UIAlertController(title: "Новая задача", message: nil, preferredStyle: .alert)
        alert.addTextField { $0.placeholder = "Название" }
        alert.addTextField { $0.placeholder = "Описание" }

        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        alert.addAction(UIAlertAction(title: "Добавить", style: .default) { [weak self] _ in
            guard let self = self else { return }
            let title = alert.textFields?[0].text ?? ""
            let detail = alert.textFields?[1].text ?? ""
            guard !title.isEmpty else { return }
            self.presenter?.didTapAddTask(title: title, detail: detail)
        })

        present(alert, animated: true)
    }
}

// MARK: - TableView Delegate & DataSource

extension TaskListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tasks.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let task = tasks[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        
        content.text = task.title
        
        let created = "Создано: \(dateFormatter.string(from: task.createdAt))"
        let updated = "Обновлено: \(dateFormatter.string(from: task.updatedAt))"
        let detail = task.detail ?? ""
        
        content.secondaryText = "\(detail)\n\(created)\n\(updated)"
        content.secondaryTextProperties.numberOfLines = 0
        
        cell.contentConfiguration = content
        cell.accessoryType = task.isCompleted ? .checkmark : .none
        
        return cell
    }


    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter?.didSelectTask(at: indexPath.row)
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView,
                   commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            presenter?.didTapDeleteTask(at: indexPath.row)
        }
    }
}

// MARK: - View Protocol

extension TaskListViewController: TaskListViewProtocol {
    func displayTasks(_ tasks: [TaskModel]) {
        self.tasks = tasks
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }

    func displayError(_ message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        DispatchQueue.main.async {
            self.present(alert, animated: true)
        }
    }
}
