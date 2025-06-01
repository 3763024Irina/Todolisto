//
//  TaskEntity+CoreDataProperties.swift
//  Todolisto
//
//  Created by Irina on 1/6/25.
//
//

import Foundation
import CoreData


extension TaskEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TaskEntity> {
        return NSFetchRequest<TaskEntity>(entityName: "TaskEntity")
    }

    @NSManaged public var taskID: UUID?
    @NSManaged public var title: String?
    @NSManaged public var detail: String?
    @NSManaged public var isCompleted: Bool
    @NSManaged public var createdAt: Date?
    @NSManaged public var updatedAt: Date?
    @NSManaged public var deletedAt: Date?

}

extension TaskEntity : Identifiable {

}
