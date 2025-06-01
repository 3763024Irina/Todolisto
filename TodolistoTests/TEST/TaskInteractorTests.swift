//
//  TaskInteractorTests.swift
//  Todolisto
//
//  Created by Irina on 27/5/25.
//

import Foundation
import UIKit
import XCTest
@testable import Todolisto


final class TaskInteractorTests: XCTestCase {
    func testLoadTasksReturnsNonEmptyArray() {
        let interactor = TaskListInteractor()
        let tasks = CoreDataService.shared.fetchTasks()
        XCTAssertFalse(tasks.isEmpty)
    }
}
