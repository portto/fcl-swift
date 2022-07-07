//
//  FCLError.swift
//  
//
//  Created by Andrew Wang on 2022/6/29.
//

import Foundation

public enum FCLError: Swift.Error {
    case authenticateFailed
    case userNotFound
    case walletProviderNotSpecified
    case presentableNotFound
    case responseUnexpected
    case urlNotFound
}
