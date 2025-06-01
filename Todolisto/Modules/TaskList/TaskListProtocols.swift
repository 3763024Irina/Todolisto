import UIKit
import Foundation

// MARK: - View
protocol TaskListViewProtocol: AnyObject {
    func displayTasks(_ tasks: [TaskModel])
    func displayError(_ message: String)
}

// MARK: - Presenter
protocol TaskListPresenterProtocol: AnyObject {
    var view: TaskListViewProtocol? { get set }
    var interactor: TaskListInteractorInputProtocol? { get set }
    var router: TaskListRouterProtocol? { get set }

    func viewDidLoad()
    func didTapAddTask(title: String, detail: String)
    func didTapUpdateTask(_ task: TaskModel)
    func didTapDeleteTask(at index: Int)
    func didSearchTask(with query: String)
    func didSelectTask(at index: Int)
}


// MARK: - Interactor Input
protocol TaskListInteractorInputProtocol: AnyObject {
    func loadTasks()
    func addTask(title: String, detail: String)
    func updateTask(_ task: TaskModel)
    func deleteTask(at index: Int)
    func toggleTaskCompletion(at index: Int)
}

// MARK: - Interactor Output
protocol TaskListInteractorOutputProtocol: AnyObject {
    func didLoadTasks(_ tasks: [TaskModel])
    func onError(_ error: Error)
}

// MARK: - Router
protocol TaskListRouterProtocol: AnyObject {
    func navigateToTaskDetail(from view: UIViewController, task: TaskModel)
}
