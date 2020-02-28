//
//  Mode+Icon.swift
//  manni-ios
//
//  Created by yaaarrrnnn on 08.02.20.
//  Copyright © 2020 Philipp Matthes. All rights reserved.
//

import DVB
import FontAwesome_swift


extension Mode {
    
    public var icon: UIImage {
        get {
            print(self)
            let size = CGSize.init(width: 64, height: 64)
            var image: UIImage
            switch self {
            case .cableway:
                image = UIImage.fontAwesomeIcon(
                    name: .tram,
                    style: .solid,
                    textColor: .white,
                    size: size
                ).withRenderingMode(.alwaysTemplate)
            case .cityBus:
                image = UIImage.fontAwesomeIcon(
                    name: .bus,
                    style: .solid,
                    textColor: .white,
                    size: size
                ).withRenderingMode(.alwaysTemplate)
            case .bus:
                image = UIImage.fontAwesomeIcon(
                    name: .bus,
                    style: .solid,
                    textColor: .white,
                    size: size
                ).withRenderingMode(.alwaysTemplate)
            case .ferry:
                image = UIImage.fontAwesomeIcon(
                    name: .ship,
                    style: .solid,
                    textColor: .white,
                    size: size
                ).withRenderingMode(.alwaysTemplate)
            case .footpath:
                image = UIImage.fontAwesomeIcon(
                    name: .walking,
                    style: .solid,
                    textColor: .white,
                    size: size
                ).withRenderingMode(.alwaysTemplate)
            case .hailedSharedTaxi:
                image = UIImage.fontAwesomeIcon(
                    name: .taxi,
                    style: .solid,
                    textColor: .white,
                    size: size
                ).withRenderingMode(.alwaysTemplate)
            case .intercityBus:
                image = UIImage.fontAwesomeIcon(
                    name: .busAlt,
                    style: .solid,
                    textColor: .white,
                    size: size
                ).withRenderingMode(.alwaysTemplate)
            case .plusBus:
                image = UIImage.fontAwesomeIcon(
                    name: .busAlt,
                    style: .solid,
                    textColor: .white,
                    size: size
                ).withRenderingMode(.alwaysTemplate)
            case .rapidTransit:
                image = UIImage.fontAwesomeIcon(
                    name: .train,
                    style: .solid,
                    textColor: .white,
                    size: size
                ).withRenderingMode(.alwaysTemplate)
            case .suburbanRailway:
                image = UIImage.fontAwesomeIcon(
                    name: .subway,
                    style: .solid,
                    textColor: .white,
                    size: size
                ).withRenderingMode(.alwaysTemplate)
            case .train:
                image = UIImage.fontAwesomeIcon(
                    name: .train,
                    style: .solid,
                    textColor: .white,
                    size: size
                ).withRenderingMode(.alwaysTemplate)
            case .tram:
                image = UIImage.fontAwesomeIcon(
                    name: .subway,
                    style: .solid,
                    textColor: .white,
                    size: size
                ).withRenderingMode(.alwaysTemplate)
            case .unknown(let value):
                for mode in Mode.allRequest {
                    if mode.rawValue == value {
                        return mode.icon
                    }
                }
                image = UIImage.fontAwesomeIcon(
                    name: .train,
                    style: .solid,
                    textColor: .white,
                    size: size
                ).withRenderingMode(.alwaysTemplate)
            }
            return image
        }
    }
    
}
