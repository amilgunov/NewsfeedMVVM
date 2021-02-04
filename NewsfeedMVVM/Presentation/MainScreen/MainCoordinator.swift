//
//  MainCoordinator.swift
//  NewsfeedMVVM
//
//  Created by Alexander Milgunov on 03.02.2021.
//  Copyright © 2021 Alexander Milgunov. All rights reserved.
//

import UIKit

protocol DetailFlow: class {
    func coordinateToDetail(viewModel: CellViewModelType)
}

class MainCoordinator: CoordinatorType, DetailFlow {
    
    let navigationController: UINavigationController
    
    func start() {
        
        let container = CoreDataStack.shared.persistentContainer
        let coreDataManager = CoreDataManager(persistentContainer: container)
        let networkManager = NetworkManager()
        let dataManager = MainDataManager(coreDataManager: coreDataManager, networkManager: networkManager)
        let viewModel = MainViewModel(with: dataManager)
        
        let mainViewController = MainViewController(viewModel: viewModel)
        mainViewController.coordinator = self
        
        navigationController.pushViewController(mainViewController, animated: true)
    }
    
    func coordinateToDetail(viewModel: CellViewModelType) {
        
        let detailCoordinator = DetailCoordinator(controller: navigationController, viewModel: viewModel)
        coordinate(to: detailCoordinator)
    }

    init(controller: UINavigationController) {
        self.navigationController = controller
    }
}
