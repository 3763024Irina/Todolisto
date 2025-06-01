import Foundation

final class TaskAPIClient {
    func fetchTasks(completion: @escaping (Result<[TaskModel], Error>) -> Void) {
        guard let url = URL(string: "https://dummyjson.com/todos") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0)))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: 0)))
                return
            }
            
            do {
                struct Response: Codable {
                    struct TodoItem: Codable {
                        let id: Int
                        let todo: String
                        let completed: Bool
                    }
                    let todos: [TodoItem]
                }
                
                let decoded = try JSONDecoder().decode(Response.self, from: data)
                
                let tasks = decoded.todos.map {
                    TaskModel(
                        id: UUID(),
                        title: $0.todo,
                        detail: nil,
                        isCompleted: $0.completed,
                        createdAt: Date(),     // ← добавлено
                        updatedAt: Date(),     // ← добавлено
                        deletedAt: nil         // ← можно оставить nil
                    )
                }
                completion(.success(tasks))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
