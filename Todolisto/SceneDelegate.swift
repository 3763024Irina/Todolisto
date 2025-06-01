import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {

        guard let windowScene = (scene as? UIWindowScene) else { return }

        let window = UIWindow(windowScene: windowScene)
        let viewController = TaskListViewController()

        let presenter = TaskListPresenter()
        let interactor = TaskListInteractor()

        viewController.presenter = presenter
        presenter.view = viewController
        presenter.interactor = interactor
        interactor.presenter = presenter

        let navController = UINavigationController(rootViewController: viewController) // вот тут добавил закрывающую скобку

        window.rootViewController = navController
        self.window = window
        window.makeKeyAndVisible()
    }
}
