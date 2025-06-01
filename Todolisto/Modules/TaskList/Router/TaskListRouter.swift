import UIKit

final class TaskListRouter: TaskListRouterProtocol {
    // MARK: - Навигация
    func navigateToTaskDetail(from view: UIViewController, task: TaskModel) {
        let detailVC = TaskDetailViewController(task: task)
        view.navigationController?.pushViewController(detailVC, animated: true)
    }

    // MARK: - Сборка модуля
    static func createModule() -> UIViewController {
        let view = TaskListViewController()
        let presenter = TaskListPresenter()
        let interactor = TaskListInteractor()
        let router = TaskListRouter()

        view.presenter = presenter
        presenter.view = view
        presenter.interactor = interactor
        presenter.router = router
        interactor.presenter = presenter

        return UINavigationController(rootViewController: view)
    }
}
