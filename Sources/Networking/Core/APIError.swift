//
//  APIError.swift
//  PAYJP
//
//  Created by k@binc.jp on 10/4/16.
//  Copyright © 2016 PAY, Inc. All rights reserved.
//

import Foundation
import PassKit

protocol NSErrorSerializable: Error {
    var errorCode: Int { get }
    var errorDescription: String? { get }
    var userInfo: [String: Any] { get }
}

extension NSErrorSerializable {

    var userInfo: [String: Any] {
        return [String: Any]()
    }
}

/// API error types.
public enum APIError: LocalizedError, NSErrorSerializable {
    /// The Apple Pay token is invalid.
    case invalidApplePayToken(PKPaymentToken)
    /// The system error.
    case systemError(Error)
    /// No body data or no response error.
    case invalidResponse(HTTPURLResponse?)
    /// The error response object that is coming back from the server side.
    case serviceError(PAYErrorResponseType)
    /// Invalid JSON object.
    case invalidJSON(Data, Error?)
    /// Required 3DSecure.
    case requiredThreeDSecure(ThreeDSecureToken)

    // MARK: - LocalizedError

    public var errorDescription: String? {
        switch self {
        case .invalidApplePayToken:
            return "Invalid Apple Pay Token"
        case .systemError(let error):
            return error.localizedDescription
        case .invalidResponse:
            return "The response is not a HTTPURLResponse instance."
        case .serviceError(let errorResponse):
            return errorResponse.message
        case .invalidJSON:
            return "Unable parse JSON object into expected classes."
        case .requiredThreeDSecure:
            return "Required 3DSecure process."
        }
    }

    public var errorCode: Int {
        switch self {
        case .invalidApplePayToken:
            return PAYErrorInvalidApplePayToken
        case .systemError:
            return PAYErrorSystemError
        case .invalidResponse:
            return PAYErrorInvalidResponse
        case .serviceError:
            return PAYErrorServiceError
        case .invalidJSON:
            return PAYErrorInvalidJSON
        case .requiredThreeDSecure:
            return PAYErrorRequiredThreeDSecure
        }
    }

    public var userInfo: [String: Any] {
        var userInfo = [String: Any]()
        switch self {
        case .invalidApplePayToken(let token):
            userInfo[PAYErrorInvalidApplePayTokenObject] = token
        case .systemError(let error):
            userInfo[PAYErrorSystemErrorObject] = error
        case .invalidResponse(let response):
            userInfo[PAYErrorInvalidResponseObject] = response
        case .serviceError(let errorResponse):
            userInfo[PAYErrorServiceErrorObject] = errorResponse
        case .invalidJSON(let json, let error):
            userInfo[PAYErrorInvalidJSONObject] = json
            if error != nil {
                userInfo[PAYErrorInvalidJSONErrorObject] = error
            }
        case .requiredThreeDSecure(let identifier):
            userInfo[PAYErrorRequiredThreeDSecureIdObject] = identifier
        }
        return userInfo
    }

    // MARK: - NSError helper

    /// Returns error response object if the type is `.serviceError`.
    public var payError: PAYErrorResponseType? {
        switch self {
        case .serviceError(let errorResponse):
            return errorResponse
        default:
            return nil
        }
    }
}
