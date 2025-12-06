//
//  CopyableLabel.swift
//  LangugaLearnerForIOs
//
//  Created by Dzmitry Kudrashou on 2025-12-06.
//  Copyright © 2025 Dzmitry Kudrashou. All rights reserved.
//

import UIKit

@IBDesignable
class CopyableLabel: UILabel {

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setup()
    }

    private func setup() {
        self.isUserInteractionEnabled = true

        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(self.showMenu(_:)))

        self.addGestureRecognizer(longPress)
    }

    @objc private func showMenu(_ recognizer: UIGestureRecognizer) {
        guard recognizer.state == .began else { return }

        self.becomeFirstResponder()

        let menu = UIMenuController.shared
        menu.menuItems = nil
        menu.showMenu(from: self, rect: self.bounds)
    }

    override var canBecomeFirstResponder: Bool {
        return true
    }

    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return action == #selector(self.copy(_:))
    }

    override func copy(_ sender: Any?) {
        UIPasteboard.general.string = self.text
    }
}
