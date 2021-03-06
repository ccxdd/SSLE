//
//  Codable+extension+mw.swift
//  StandardLibraryExtension
//
//  Created by 陈晓东 on 2018/1/10.
//  Copyright © 2018年 陈晓东. All rights reserved.
//

import Foundation

public extension Encodable {
    func tJSONString(prettyPrinted: Bool = false) -> String? {
        do {
            let encoder = JSONEncoder()
            if prettyPrinted {
                encoder.outputFormatting = .prettyPrinted
            }
            let result = try encoder.encode(self).tS
            return result
        } catch {
            print("❌", error, "❌")
            return nil
        }
    }
}

public extension Data {
    func tModel<T>(_ model: T.Type, log: Bool = false) -> T? where T: Decodable {
        let decoder = JSONDecoder()
        do {
            let result = try decoder.decode(model, from: self)
            return result
        } catch {
            if log {
                print("❌", error, "❌")
            }
            return nil
        }
    }
    
    func tJSONString() -> String? {
        do {
            let jsonObj = try JSONSerialization.jsonObject(with: self)
            let jsonData = try JSONSerialization.data(withJSONObject: jsonObj, options: .prettyPrinted)
            return jsonData.tS
        } catch {
            print("❌", error, "❌")
        }
        return nil
    }
}

public extension String {
    func tModel<T>(_ model: T.Type, log: Bool = false) -> T? where T: Decodable {
        return data(using: .utf8)?.tModel(model, log: log)
    }
}
