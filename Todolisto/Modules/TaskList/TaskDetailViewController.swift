//
//  TaskDetailViewController.swift
//  Todolisto
//
//  Created by Irina on 1/6/25.
//

import UIKit

final class TaskDetailViewController: UIViewController {
    private var task: TaskModel?

    // Инициализатор с передачей задачи (может быть nil для новой задачи)
    init(task: TaskModel?) {
        self.task = task
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        if let task = task {
            title = "Редактировать задачу"
            // Настройка интерфейса с данными task
        } else {
            title = "Новая задача"
            // Настройка интерфейса для создания новой задачи
        }
    }
}
