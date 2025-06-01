import Foundation
import UIKit

final class TaskListPresenter: TaskListPresenterProtocol {
    weak var view: TaskListViewProtocol?
    var interactor: TaskListInteractorInputProtocol?
    var router: TaskListRouterProtocol?

    private var tasks: [TaskModel] = []

    // MARK: - Жизненный цикл
    func viewDidLoad() {
        interactor?.loadTasks()
    }

    // MARK: - Обработка действий
    func didTapAddTask(title: String, detail: String) {
        interactor?.addTask(title: title, detail: detail)
    }

    func didTapUpdateTask(_ task: TaskModel) {
        interactor?.updateTask(task)
    }

    func didTapDeleteTask(at index: Int) {
        interactor?.deleteTask(at: index)
    }

    func didSearchTask(with query: String) {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else {
            view?.displayTasks(tasks)
            return
        }

        let filtered = tasks.filter {
            $0.title.lowercased().contains(trimmedQuery.lowercased()) ||
            ($0.detail?.lowercased().contains(trimmedQuery.lowercased()) ?? false)
        }
        view?.displayTasks(filtered)
    }

    func didSelectTask(at index: Int) {
        guard index < tasks.count, let viewController = view as? UIViewController else { return }
        let task = tasks[index]
        router?.navigateToTaskDetail(from: viewController, task: task)
    }
}

// MARK: - TaskListInteractorOutputProtocol
extension TaskListPresenter: TaskListInteractorOutputProtocol {
    func didLoadTasks(_ tasks: [TaskModel]) {
        self.tasks = tasks
        view?.displayTasks(tasks)
    }

    func onError(_ error: Error) {
        view?.displayError(error.localizedDescription)
    }
}
