//
//  CoordinatorType.swift
//  NewsfeedMVVM
//
//  Created by Alexander Milgunov on 03.02.2021.
//  Copyright © 2021 Alexander Milgunov. All rights reserved.
//

import Foundation

protocol CoordinatorType {
    func start()
    func coordinate(to coordinator: CoordinatorType)
}

extension CoordinatorType {
    func coordinate(to coordinator: CoordinatorType) {
        coordinator.start()
    }
}
