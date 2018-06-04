//
//  StoryboardExtension.swift
//  manni
//
//  Created by Philipp Matthes on 04.06.18.
//  Copyright © 2018 Philipp Matthes. All rights reserved.
//

import Foundation
import UIKit

extension UIStoryboard {
    static func instanciateController(withId id: String) -> UIViewController {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        return storyBoard.instantiateViewController(withIdentifier: id)
    }
}
