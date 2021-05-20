//
//  Utilities.swift
//  SimulatorsManager
//
//  Created by Tomasz Bartkowski on 11/05/2021.
//

import Foundation

extension Array where Element: Hashable {
    func difference(from other: [Element]) -> [Element] {
        let thisSet = Set(self)
        let otherSet = Set(other)
        return Array(thisSet.symmetricDifference(otherSet))
    }
}


extension Array {
    subscript(safe index: Index) -> Element? {
        index >= 0 && index < count ? self[index] : nil
    }
}
