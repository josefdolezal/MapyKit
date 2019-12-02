//
//  ControllerFactory.swift
//  Example
//
//  Created by Josef Dolezal (Admin) on 01/12/2019.
//  Copyright © 2019 Josef Dolezal. All rights reserved.
//

import UIKit

final class ControllerFactory {
    func createMainTabBarController() -> UIViewController {
        let controller = UITabBarController()

        controller.viewControllers = [
            createMapyViewController(),
            createSearchViewController(),
            createNavigationViewController()
        ]

        return controller
    }

    func createMapyViewController() -> UIViewController {
        let controller = MapyViewController()

        controller.title = "Map"
        controller.tabBarItem.image = UIImage.withSystemName("map")

        return controller
    }

    func createSearchViewController() -> UIViewController {
        let controller = SearchViewController()

        controller.title = "Search"
        controller.tabBarItem.image = UIImage.withSystemName("magnifyingglass")

        return controller
    }

    func createNavigationViewController() -> UIViewController {
        let controller = NavigationViewController()

        controller.title = "Navigation"
        controller.tabBarItem.image = UIImage.withSystemName("mappin.circle")

        return controller
    }
}

extension UIImage {
    static func withSystemName(_ name: String) -> UIImage? {
        if #available(iOS 13.0, *) {
            return UIImage(systemName: name)
        } else {
            return nil
        }
    }
}
