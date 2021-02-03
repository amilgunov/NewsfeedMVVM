//
//  AppAppearance.swift
//  NewsfeedMVVM
//
//  Created by Alexander Milgunov on 03.02.2021.
//  Copyright © 2021 Alexander Milgunov. All rights reserved.
//

import UIKit

final class AppAppearance {
    
    static func setupAppearance() {
        
        let coloredAppearance = UINavigationBarAppearance()
        coloredAppearance.configureWithOpaqueBackground()
        coloredAppearance.backgroundColor = UIColor(displayP3Red: 100/255, green: 150/255, blue: 150/255, alpha: 1.0)
        coloredAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        coloredAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        UINavigationBar.appearance().standardAppearance = coloredAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = coloredAppearance
    }
}
