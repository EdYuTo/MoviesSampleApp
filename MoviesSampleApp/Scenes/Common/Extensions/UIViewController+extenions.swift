//
//  UIViewController+extenions.swift
//  MoviesSampleApp
//
//  Created by Edson Yudi Toma on 18/05/25.
//

import UIKit

extension UIViewController {
    func makeAlertView(
        title: String,
        description: String? = nil,
        style: UIAlertController.Style = .alert,
        buttonTitle: String,
        action: (() -> Void)?
    ) -> UIAlertController {
        let alert = UIAlertController(
            title: title,
            message: description,
            preferredStyle: style
        )
        let action = UIAlertAction(
            title: buttonTitle,
            style: .default
        ) { _ in
            action?()
        }
        alert.addAction(action)
        return alert
    }
}
