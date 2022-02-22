//
//  SymbolicTraitsModifer.swift
//  SakuMemo
//
//  Created by Nekokichi on 2022/02/19.
//

import UIKit

final class SymbolicTraitsModifer {
    private let font: UIFont
    private var traits: UIFontDescriptor.SymbolicTraits = []

    init(font: UIFont) {
        self.font = font
        traits = font.fontDescriptor.symbolicTraits
    }

    func bold() -> SymbolicTraitsModifer {
        if traits.contains(.traitBold) == true {
            traits.remove(.traitBold)
        } else {
            traits.insert(.traitBold)
        }
        return self
    }

    func italic() -> SymbolicTraitsModifer {
        if traits.contains(.traitItalic) == true {
            traits.remove(.traitItalic)
        } else {
            traits.insert(.traitItalic)
        }
        return self
    }

    func build() -> UIFont {
        if let descriptor = font.fontDescriptor.withSymbolicTraits(traits) {
            return UIFont(descriptor: descriptor, size: font.pointSize)
        } else {
            return font
        }
    }
}

extension UIFont {
    var stm: SymbolicTraitsModifer {
        SymbolicTraitsModifer(font: self)
    }
}
