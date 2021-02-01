//
//  UIViewController+Extensions.swift
//  NewsAppMVVMRx
//
//  Created by Alexander Milgunov on 01.02.2021.
//  Copyright © 2021 Alexander Milgunov. All rights reserved.
//

import UIKit

extension UIViewController {
    func showAlert(alertText : String, alertMessage : String) {
        let alert = UIAlertController(title: alertText, message: alertMessage, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
