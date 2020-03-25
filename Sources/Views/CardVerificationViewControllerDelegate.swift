//
//  CardVerificationViewControllerDelegate.swift
//  PAYJP
//
//  Created by Tadashi Wakayanagi on 2019/12/25.
//  Copyright © 2019 PAY, Inc. All rights reserved.
//

import Foundation

/// CardVerificationViewController delegate.
public protocol CardVerificationViewControllerDelegate: AnyObject {

    /// Callback when card verification is completed.
    /// - Parameters:
    ///   - tdsId: 3DSecure identifier
    func cardVarificationViewController(_: CardVerificationViewController,
                                        didVerified tdsId: String?)

    /// Callback when card verification is canceled.
    func cardVarificationViewControllerDidCancel(_: CardVerificationViewController)
}

/// Result of card verification.
public enum CardVerificationResult: Int {
    /// when card verification is successful
    case success = 0
    /// when card verification is canceled
    case cancel = 1
}
