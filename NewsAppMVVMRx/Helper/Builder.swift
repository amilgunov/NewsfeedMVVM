//
//  Builder.swift
//  NewsAppMVVMRx
//
//  Created by Alexander Milgunov on 12.08.2020.
//  Copyright © 2020 Alexander Milgunov. All rights reserved.
//

import UIKit

protocol ModuleBuilder {
    
    func build() -> UIViewController
}

class Builder: ModuleBuilder {
    
    func build() -> UIViewController {
       
        let container = CoreDataStack.shared.persistentContainer
        let coreDataManager = CoreDataManager(persistentContainer: container)
        let networkManager = NetworkManager()
        let dataManager = MainDataManager(coreDataManager: coreDataManager, networkManager: networkManager)
        let viewModel = MainViewModel(with: dataManager)
        
        return MainViewController(viewModel: viewModel)
    }
}
