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
    let container: Container = {
        let container = Container()
        container.register(NetworkManager.self) { _ in NetworkManager() }
        container.register(MainDataManager.self) { r in
            let coreDataManager = CoreDataManager(persistentContainer: CoreDataStack.shared.persistentContainer)
            let networkManager = r.resolve(NetworkManager.self) ?? NetworkManager()
            return MainDataManager(coreDataManager: coreDataManager, networkManager: networkManager)
        }
        return container
    }()
    
    func start() {
        
        let navigationController = UINavigationController()
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        
        let mainScreenCoordinator = MainCoordinator(container: container, controller: navigationController)
        coordinate(to: mainScreenCoordinator)
    }
    
    init(window: UIWindow) {
        self.window = window
    }
}
