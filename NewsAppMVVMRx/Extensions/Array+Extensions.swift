//
//  Array+Extensions.swift
//  NewsAppMVVMRx
//
//  Created by Alexander Milgunov on 21.01.2021.
//  Copyright © 2021 Alexander Milgunov. All rights reserved.
//

import Foundation

extension Array where Element: Hashable {
    func unique() -> Array<Element> {
        return Array(Set(self))
    }
}
