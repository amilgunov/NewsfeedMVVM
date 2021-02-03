//
//  DetailCoordinator.swift
//  NewsAppMVVMRx
//
//  Created by Alexander Milgunov on 03.02.2021.
//  Copyright © 2021 Alexander Milgunov. All rights reserved.
//

import UIKit

class DetailCoordinator: CoordinatorType {
    
    let navigationController: UINavigationController?
    let viewModel: CellViewModelType
    
    func start() {
        
        let detailViewController = DetailViewController()
        detailViewController.viewModel = viewModel
        navigationController?.present(detailViewController, animated: true)
    }
    
    init(controller: UINavigationController, viewModel: CellViewModelType) {
        self.navigationController = controller
        self.viewModel = viewModel
    }
}
