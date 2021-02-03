//
//  AppCoordinator.swift
//  NewsAppMVVMRx
//
//  Created by Alexander Milgunov on 03.02.2021.
//  Copyright © 2021 Alexander Milgunov. All rights reserved.
//

import UIKit

class AppCoordinator: CoordinatorType {
    
    let window: UIWindow
    
    init(window: UIWindow) {
        self.window = window
    }
    
    func start() {
        
        let navigationController = UINavigationController()
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        
        let mainScreenCoordinator = MainCoordinator(controller: navigationController)
        coordinate(to: mainScreenCoordinator)
    }
}
