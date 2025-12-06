//
//  MainTabBarController.swift
//  LangugaLearnerForIOs
//
//  Created by Dzmitry Kudrashou on 2025-12-06.
//  Copyright © 2025 Dzmitry Kudrashou. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        var studyingType: StudyWodrsType = .all
        self.viewControllers?.forEach {
            guard let navigationController = $0 as? UINavigationController else { return }
            guard let viewController = navigationController.topViewController as? LLWordsTableViewController else { return }
            viewController.studyingType = studyingType.rawValue
            viewController.title = studyingType.localizedTitle
            studyingType = studyingType.next
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
