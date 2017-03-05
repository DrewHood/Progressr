//
//  HTTPInterface.swift
//  Progressr
//
//  Created by Drew Hood on 2/28/17.
//
//

import Foundation

class HTTPInterface {
    // Not to be instantiated
    private init() {}
    
    static func get(_ url: URL, callback: @escaping (Data?, String?) -> Void) {
        let session = URLSession(configuration: .default)
        session.dataTask(with: url) {
            (data, response, error) in
            if error != nil {
                callback(nil, error!.localizedDescription)
            } else {
                callback(data, nil)
            }
            }.resume()
    }
}
