//
//  CardNumberFormatter.swift
//  PAYJP
//
//  Created by Tadashi Wakayanagi on 2019/07/17.
//  Copyright © 2019 PAY, Inc. All rights reserved.
//

import Foundation

protocol CardNumberFormatterType {
    func string(from number: String?) -> String?
}

struct CardNumberFormatter: CardNumberFormatterType {
    func string(from number: String?) -> String? {
        if let number = number {
            let digitSet = CharacterSet.decimalDigits
            let filtered = String(number.unicodeScalars.filter { digitSet.contains($0) })

            if filtered.isEmpty { return nil }

            // ブランドによって区切り方を変える
            let transfomer = CardBrandTransformer.shared
            let brand = transfomer.transform(cardNumber: number)
            switch brand {
            case .americanExpress, .dinersClub:
                let formattedNumber = filtered
                    .enumerated()
                    .map { offset, element in
                        ((offset == 4 || offset == 10) && offset != filtered.count) ? [" ", element] : [element]
                    }
                    .joined()
                return String(formattedNumber)
            default:
                let formattedNumber = filtered
                    .enumerated()
                    .map { offset, element in
                        (offset != 0 && offset % 4 == 0 && offset != filtered.count) ? [" ", element] : [element]
                    }
                    .joined()
                return String(formattedNumber)
            }
        }
        return nil
    }
}
