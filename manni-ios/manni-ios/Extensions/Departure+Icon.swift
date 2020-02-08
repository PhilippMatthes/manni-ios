//
//  Departure+Icon.swift
//  manni-ios
//
//  Created by yaaarrrnnn on 08.02.20.
//  Copyright © 2020 Philipp Matthes. All rights reserved.
//

import DVB
import FontAwesome_swift


extension Departure {
    
    public var icon: UIImage {
        get {
            var image: UIImage
            switch mode {
            case .cableway:
                image = UIImage.fontAwesomeIcon(
                    name: .tram,
                    style: .solid,
                    textColor: .white,
                    size: .init(width: 256, height: 256)
                ).withRenderingMode(.alwaysTemplate)
            case .cityBus:
                image = UIImage.fontAwesomeIcon(
                    name: .bus,
                    style: .solid,
                    textColor: .white,
                    size: .init(width: 256, height: 256)
                ).withRenderingMode(.alwaysTemplate)
            case .ferry:
                image = UIImage.fontAwesomeIcon(
                    name: .ship,
                    style: .solid,
                    textColor: .white,
                    size: .init(width: 256, height: 256)
                ).withRenderingMode(.alwaysTemplate)
            case .footpath:
                image = UIImage.fontAwesomeIcon(
                    name: .walking,
                    style: .solid,
                    textColor: .white,
                    size: .init(width: 256, height: 256)
                ).withRenderingMode(.alwaysTemplate)
            case .hailedSharedTaxi:
                image = UIImage.fontAwesomeIcon(
                    name: .taxi,
                    style: .solid,
                    textColor: .white,
                    size: .init(width: 256, height: 256)
                ).withRenderingMode(.alwaysTemplate)
            case .intercityBus:
                image = UIImage.fontAwesomeIcon(
                    name: .busAlt,
                    style: .solid,
                    textColor: .white,
                    size: .init(width: 256, height: 256)
                ).withRenderingMode(.alwaysTemplate)
            case .plusBus:
                image = UIImage.fontAwesomeIcon(
                    name: .busAlt,
                    style: .solid,
                    textColor: .white,
                    size: .init(width: 256, height: 256)
                ).withRenderingMode(.alwaysTemplate)
            case .rapidTransit:
                image = UIImage.fontAwesomeIcon(
                    name: .train,
                    style: .solid,
                    textColor: .white,
                    size: .init(width: 256, height: 256)
                ).withRenderingMode(.alwaysTemplate)
            case .suburbanRailway:
                image = UIImage.fontAwesomeIcon(
                    name: .subway,
                    style: .solid,
                    textColor: .white,
                    size: .init(width: 256, height: 256)
                ).withRenderingMode(.alwaysTemplate)
            case .train:
                image = UIImage.fontAwesomeIcon(
                    name: .train,
                    style: .solid,
                    textColor: .white,
                    size: .init(width: 256, height: 256)
                ).withRenderingMode(.alwaysTemplate)
            case .tram:
                image = UIImage.fontAwesomeIcon(
                    name: .subway,
                    style: .solid,
                    textColor: .white,
                    size: .init(width: 256, height: 256)
                ).withRenderingMode(.alwaysTemplate)
            default:
                image = UIImage.fontAwesomeIcon(
                    name: .train,
                    style: .solid,
                    textColor: .white,
                    size: .init(width: 256, height: 256)
                ).withRenderingMode(.alwaysTemplate)
            }
            return image
        }
    }
    
}
