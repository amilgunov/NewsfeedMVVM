//
//  MainCoordinator.swift
//  NewsfeedMVVM
//
//  Created by Alexander Milgunov on 03.02.2021.
//  Copyright © 2021 Alexander Milgunov. All rights reserved.
//

import UIKit
import Swinject

protocol DetailFlow: class {
    func coordinateToDetail(viewModel: CellViewModelType)
}

class MainCoordinator: CoordinatorType, DetailFlow {
    
    let navigationController: UINavigationController
    let container: Container
    
    func start() {
        
        let viewModel = MainViewModel(with: container)
        
        let mainViewController = MainViewController(viewModel: viewModel)
        mainViewController.coordinator = self
        
        navigationController.pushViewController(mainViewController, animated: true)
    }
    
    func coordinateToDetail(viewModel: CellViewModelType) {
        
        let detailCoordinator = DetailCoordinator(controller: navigationController, viewModel: viewModel)
        coordinate(to: detailCoordinator)
    }

    init(container: Container, controller: UINavigationController) {
        self.navigationController = controller
        self.container = container
    }
}
