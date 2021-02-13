//
//  DetailCoordinator.swift
//  NewsfeedMVVM
//
//  Created by Alexander Milgunov on 03.02.2021.
//  Copyright © 2021 Alexander Milgunov. All rights reserved.
//

import UIKit
import Swinject

class DetailCoordinator: CoordinatorType {
    
    let navigationController: UINavigationController?
    let cellViewModel: CellViewModelType?
    
    func start() {
        let detailViewController = DetailViewController()
        detailViewController.cellViewModel = cellViewModel
        navigationController?.present(detailViewController, animated: true)
    }
    
    init(navigationController: UINavigationController, cellViewModel: CellViewModelType) {
        self.navigationController = navigationController
        self.cellViewModel = cellViewModel
    }
}
