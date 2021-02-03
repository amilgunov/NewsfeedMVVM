//
//  MainScreenCoordinator.swift
//  NewsAppMVVMRx
//
//  Created by Alexander Milgunov on 03.02.2021.
//  Copyright © 2021 Alexander Milgunov. All rights reserved.
//

import UIKit

protocol DetailFlow: class {
    func coordinateToDetail(cellViewModel: CellViewModel?)
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
    
    func coordinateToDetail(cellViewModel: CellViewModel?) {
        let detailViewController = DetailViewController()
        detailViewController.viewModel = cellViewModel
        navigationController.present(detailViewController, animated: true, completion: nil)
    }
    
    init(controller: UINavigationController) {
        self.navigationController = controller
    }
}
