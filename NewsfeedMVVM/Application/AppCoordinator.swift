//
//  AppCoordinator.swift
//  NewsfeedMVVM
//
//  Created by Alexander Milgunov on 03.02.2021.
//  Copyright © 2021 Alexander Milgunov. All rights reserved.
//

import UIKit
import Swinject

class AppCoordinator: CoordinatorType {
    
    let window: UIWindow
    let container: Container
    
    func start() {
        
        let navigationController = UINavigationController()
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        
        let mainScreenCoordinator = MainCoordinator(container: container, navigationController: navigationController)
        coordinate(to: mainScreenCoordinator)
    }
    
    init(window: UIWindow) {
        self.window = window
        self.container = Container()
        setupDependencies()
    }
}

extension AppCoordinator {
    
    internal func setupDependencies() {
        container.register(NetworkManager.self) { _ in NetworkManager() }
        container.register(MainDataManager.self) { r in
            let coreDataManager = CoreDataManager(persistentContainer: CoreDataStack.shared.persistentContainer)
            let networkManager = r.resolve(NetworkManager.self) ?? NetworkManager()
            return MainDataManager(coreDataManager: coreDataManager, networkManager: networkManager)
        }
        container.register(MainViewModel.self) { _ -> MainViewModel in
            return MainViewModel(with: self.container)
        }
        container.register(MainViewController.self) { (r) -> MainViewController in
            let mainViewController = MainViewController(viewModel: r.resolve(MainViewModel.self))
            return mainViewController
        }
    }
}
