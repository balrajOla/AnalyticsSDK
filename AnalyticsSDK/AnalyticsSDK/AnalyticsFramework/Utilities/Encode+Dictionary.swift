//
//  Encode+Dictionary.swift
//  AnalyticsSDKFramework
//
//  Created by Balraj Singh on 08/09/19.
//  Copyright © 2019 Balraj Singh. All rights reserved.
//

import Foundation

extension Encodable {
    var dictionary: [String: Any]? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: Any] }
    }
}

public struct Single: Codable {
    static public let value = Single()
    private init() {}
}
