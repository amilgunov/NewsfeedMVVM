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
        let networkManager = NetworkManager.shared
        let dataManager = DataManager(persistentContainer: container, networkManager: networkManager)
        let viewModel = MainViewModel(with: dataManager)
        
        return MainViewController(viewModel: viewModel)
    }
}
