//
//  Bundle-Decodable.swift
//  UltimatePortfolio
//
//  Created by Albert on 02.11.23.
//

import Foundation

extension Bundle {
    /// the generic decode function will decode JSON data to the provided type
    /// - Parameters:
    ///   - file: file that contains the JSON data
    ///   - type: type that the JSON data shall be decoded to
    ///   - dateDecodingStrategy: how date data shall be recognized
    ///   - keyDecodingStrategy: how keys shall be analysed
    /// - Returns: the decoded JSON data is the type that is provided as parameter
    func decode<T: Decodable>(
        _ file: String,
        as type: T.Type = T.self,
        dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .deferredToDate,
        keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy = .useDefaultKeys
    ) -> T {
        guard let url = self.url(forResource: file, withExtension: nil) else {
            fatalError("unable to find the file: \(file) in the bundle.")
        }

        guard let data = try? Data(contentsOf: url) else {
            fatalError("unable to load data from \(file) from bundle.")
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = dateDecodingStrategy
        decoder.keyDecodingStrategy = keyDecodingStrategy

        do {
            return try decoder.decode(type, from: data)
        } catch DecodingError.keyNotFound(let key, let context) {
            fatalError("failed to decode data from \(file) in bundle "
                       + "due to missing key \(key.stringValue) - \(context.debugDescription)")
        } catch DecodingError.typeMismatch( _, let context) {
            fatalError("failed to decode data from \(file) in bundle "
                       + "due to type mismatch - \(context.debugDescription)")
        } catch DecodingError.valueNotFound(let type, let context) {
            fatalError("failed to decode data from \(file) in bundle "
                       + "dueto missing \(type) value - \(context.debugDescription)")
        } catch DecodingError.dataCorrupted(let context) {
            fatalError("failed to decode data from \(file) in bundle "
                       + "due to corrupted data - \(context.debugDescription)")
        } catch {
            fatalError("failed to decode data from \(file) in bundle - \(error.localizedDescription)")
        }
    }
}
