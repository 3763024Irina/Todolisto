import Foundation
import CoreData
final class TaskListInteractor: TaskListInteractorInputProtocol {
    weak var presenter: TaskListInteractorOutputProtocol?

    private var tasks: [TaskModel] = []
    private let coreDataService = CoreDataService.shared
    private let apiClient = TaskAPIClient()

    // MARK: - Загрузка задач
    func loadTasks() {
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else { return }

            self.tasks = self.coreDataService.fetchTasks()

            if self.tasks.isEmpty {
                self.loadFromAPI()
            } else {
                DispatchQueue.main.async {
                    self.presenter?.didLoadTasks(self.tasks)
                }
            }
        }
    }

    private func loadFromAPI() {
        apiClient.fetchTasks { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let tasksFromAPI):
                DispatchQueue.global(qos: .background).async {
                    let bgContext = self.coreDataService.persistentContainer.newBackgroundContext()

                    self.coreDataService.clearAllTasks(context: bgContext)

                    for task in tasksFromAPI {
                        do {
                            // Обязательно сохраняем даты из API (если есть), либо текущие
                            let taskWithDates = TaskModel(
                                id: task.id,
                                title: task.title,
                                detail: task.detail,
                                isCompleted: task.isCompleted,
                                createdAt: task.createdAt ?? Date(),
                                updatedAt: task.updatedAt ?? Date(),
                                deletedAt: task.deletedAt
                            )
                            try self.coreDataService.saveTask(from: taskWithDates, context: bgContext)
                        } catch {
                            print("❌ Error saving task from API: \(error)")
                        }
                    }

                    self.tasks = self.coreDataService.fetchTasks()

                    DispatchQueue.main.async {
                        self.presenter?.didLoadTasks(self.tasks)
                    }
                }

            case .failure(let error):
                DispatchQueue.main.async {
                    self.presenter?.onError(error)
                }
            }
        }
    }

    // MARK: - Добавление задачи
    func addTask(title: String, detail: String) {
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else { return }

            let now = Date()
            let newTask = TaskModel(
                id: UUID(),
                title: title,
                detail: detail,
                isCompleted: false,
                createdAt: now,
                updatedAt: now,
                deletedAt: nil
            )

            let bgContext = self.coreDataService.persistentContainer.newBackgroundContext()
            do {
                try self.coreDataService.saveTask(from: newTask, context: bgContext)
                self.tasks.append(newTask)
                DispatchQueue.main.async {
                    self.presenter?.didLoadTasks(self.tasks)
                }
            } catch {
                print("❌ Error saving new task: \(error)")
                DispatchQueue.main.async {
                    self.presenter?.onError(error)
                }
            }
        }
    }

    // MARK: - Обновление задачи
    func updateTask(_ task: TaskModel) {
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else { return }

            var updatedTask = task
            updatedTask.updatedAt = Date() // Обновляем дату изменения

            let bgContext = self.coreDataService.persistentContainer.newBackgroundContext()
            do {
                try self.coreDataService.updateTask(updatedTask, context: bgContext)
                if let index = self.tasks.firstIndex(where: { $0.id == task.id }) {
                    self.tasks[index] = updatedTask
                }
                DispatchQueue.main.async {
                    self.presenter?.didLoadTasks(self.tasks)
                }
            } catch {
                print("❌ Error updating task: \(error)")
                DispatchQueue.main.async {
                    self.presenter?.onError(error)
                }
            }
        }
    }

    // MARK: - Удаление задачи (soft delete)
    func deleteTask(at index: Int) {
        guard index < tasks.count else { return }

        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else { return }

            var taskToDelete = self.tasks[index]
            taskToDelete.deletedAt = Date() // ставим дату удаления

            let bgContext = self.coreDataService.persistentContainer.newBackgroundContext()
            do {
                try self.coreDataService.updateTask(taskToDelete, context: bgContext) // обновляем с deletedAt
                self.tasks.remove(at: index)
                DispatchQueue.main.async {
                    self.presenter?.didLoadTasks(self.tasks)
                }
            } catch {
                print("❌ Error deleting task: \(error)")
                DispatchQueue.main.async {
                    self.presenter?.onError(error)
                }
            }
        }
    }

    // MARK: - Переключение выполнения
    func toggleTaskCompletion(at index: Int) {
        guard index < tasks.count else { return }

        var task = tasks[index]
        task.isCompleted.toggle()
        task.updatedAt = Date() // обновляем дату изменения
        updateTask(task)
    }
}
