//
//  Data+Extension.swift
//  InstabugNetworkClient
//
//  Created by Afnan MacBook Pro on 01/03/2022.
//

import Foundation

extension Data {
    
    func convertToMB() -> Double {
        let bcf = ByteCountFormatter()
        bcf.allowedUnits = [.useMB]
        bcf.countStyle = .file
        let sizeString = bcf.string(fromByteCount: Int64(self.count))
        guard let size = Double(sizeString.replacingOccurrences(of: " MB", with: "")) else { return 0}
        return size
    }
}
