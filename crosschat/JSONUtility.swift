//
//  JSONUtility.swift
//  crosschat
//
//  Created by arafetksiksi on 27/4/2024.
//

import Foundation

class JSONUtility {

    class func getJson(objects: [Any]?) -> Any? {
        if (objects == nil){
            return nil
        }
        for objectsString in objects! {
            do {
                if let objectData = (objectsString as? String)?.data(using: .utf8){
                    return try JSONSerialization.jsonObject(with: objectData, options: .mutableContainers )
                }
            }
            catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }

    class func jsonString(obj: Any, prettyPrint: Bool) -> String {
        guard let data = try? JSONSerialization.data(withJSONObject: obj, options: []) else{
            return "{}"
        }
        return String(data: data, encoding: .utf8) ?? "{}"
    }
    
}
