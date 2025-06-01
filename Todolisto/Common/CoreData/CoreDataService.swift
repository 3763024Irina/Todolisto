import CoreData
import UIKit

final class CoreDataService {
    static let shared = CoreDataService()
    
    private init() {}
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "TasksModel") // Название модели Core Data
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("CoreData load error: \(error)")
            }
        }
        return container
    }()
    
    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    func fetchTasks() -> [TaskModel] {
        let request: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
        do {
            let entities = try context.fetch(request)
            return entities.compactMap { TaskModel(entity: $0) }
        } catch {
            print("Fetch error: \(error)")
            return []
        }
    }

    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Save context error: \(error)")
            }
        }
    }
    
    func saveTask(from model: TaskModel, context: NSManagedObjectContext? = nil) throws {
        let ctx = context ?? self.context
        
        // Проверим, нет ли уже задачи с таким ID, чтобы не дублировать
        let fetchRequest: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "taskID == %@", model.id as CVarArg)
        
        let existingEntities = try ctx.fetch(fetchRequest)
        if !existingEntities.isEmpty {
            // Задача с таким ID уже есть — вызови update
            try updateTask(model, context: ctx)
            return
        }
        
        // Создаем новую задачу
        let taskEntity = TaskEntity(context: ctx)
        taskEntity.taskID = model.id
        taskEntity.title = model.title
        taskEntity.detail = model.detail
        taskEntity.isCompleted = model.isCompleted
        
        // При создании дата создания и обновления — текущая
        let now = Date()
        taskEntity.createdAt = model.createdAt ?? now
        taskEntity.updatedAt = model.updatedAt ?? now
        
        if context == nil {
            saveContext()
        } else {
            try ctx.save()
        }
    }

    func updateTask(_ model: TaskModel, context: NSManagedObjectContext? = nil) throws {
        let ctx = context ?? self.context
        let request: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
        request.predicate = NSPredicate(format: "taskID == %@", model.id as CVarArg)

        if let entity = try ctx.fetch(request).first {
            entity.title = model.title
            entity.detail = model.detail
            entity.isCompleted = model.isCompleted
            
            // Обновляем только дату обновления
            entity.updatedAt = Date()

            if context == nil {
                saveContext()
            } else {
                try ctx.save()
            }
        } else {
            // Если не нашли задачу для обновления, можно создать новую или кинуть ошибку
            throw NSError(domain: "CoreDataService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Task not found for update"])
        }
    }
    
    func deleteTask(_ model: TaskModel, context: NSManagedObjectContext? = nil) throws {
        let ctx = context ?? self.context
        let request: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
        request.predicate = NSPredicate(format: "taskID == %@", model.id as CVarArg)
        
        if let entity = try ctx.fetch(request).first {
            ctx.delete(entity)
            if context == nil {
                saveContext()
            } else {
                try ctx.save()
            }
        }
    }
    
    func clearAllTasks(context: NSManagedObjectContext? = nil) {
        let ctx = context ?? self.context
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = TaskEntity.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try ctx.execute(deleteRequest)
            if context == nil {
                saveContext()
            }
        } catch {
            print("Failed to clear tasks: \(error)")
        }
    }
}
