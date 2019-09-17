//
//  CardFormViewViewModel.swift
//  PAYJP
//
//  Created by Li-Hsuan Chen on 2019/07/19.
//  Copyright © 2019 PAY, Inc. All rights reserved.
//

import Foundation

protocol CardFormViewViewModelType {
    var isBrandChanged: Bool { get }
    /// カード番号の入力値を更新する
    ///
    /// - Parameter cardNumber: カード番号
    /// - Returns: 入力結果
    func update(cardNumber: String?) -> Result<CardNumber, FormError>
    /// 有効期限の入力値を更新する
    ///
    /// - Parameter expiration: 有効期限
    /// - Returns: 入力結果
    func update(expiration: String?) -> Result<String, FormError>
    /// CVCの入力値を更新する
    ///
    /// - Parameter cvc: CVC
    /// - Returns: 入力結果
    func update(cvc: String?) -> Result<String, FormError>
    /// カード名義の入力値を更新する
    ///
    /// - Parameter cardHolder: カード名義
    /// - Returns: 入力結果
    func update(cardHolder: String?) -> Result<String, FormError>
    /// カード名義入力の有効を更新する
    ///
    /// - Parameter isCardHolderEnabled: true 有効にする
    func update(isCardHolderEnabled: Bool)
    /// 全フィールドのバリデーションチェック
    ///
    /// - Returns: true バリデーションOK
    func isValid() -> Bool
    /// トークンを生成する
    ///
    /// - Parameters:
    ///   - tenantId: テナントID
    ///   - completion: 取得結果
    func createToken(with tenantId: String?, completion: @escaping (Result<Token, Error>) -> Void)
    /// 利用可能ブランドを取得する
    ///
    /// - Parameters:
    ///   - tenantId: テナントID
    ///   - completion: 取得結果
    func fetchAcceptedBrands(with tenantId: String?, completion: CardBrandsResult?)
}

class CardFormViewViewModel: CardFormViewViewModelType {

    private let cardNumberFormatter: CardNumberFormatterType
    private let cardNumberValidator: CardNumberValidatorType
    private let expirationFormatter: ExpirationFormatterType
    private let expirationValidator: ExpirationValidatorType
    private let expirationExtractor: ExpirationExtractorType
    private let cvcFormatter: CvcFormatterType
    private let cvcValidator: CvcValidatorType
    private let accountsService: AccountsServiceType
    private let tokenService: TokenServiceType

    private var cardNumber: String? = nil
    private var cardBrand: CardBrand = .unknown
    private var acceptedCardBrands: [CardBrand]? = nil
    private var monthYear: (month: String, year: String)? = nil
    private var cvc: String? = nil
    private var cardHolder: String? = nil
    
    private var isCardHolderEnabled: Bool = false

    var isBrandChanged = false

    // MARK: - Lifecycle

    init(cardNumberFormatter: CardNumberFormatterType = CardNumberFormatter(),
        cardNumberValidator: CardNumberValidatorType = CardNumberValidator(),
        expirationFormatter: ExpirationFormatterType = ExpirationFormatter(),
        expirationValidator: ExpirationValidatorType = ExpirationValidator(),
        expirationExtractor: ExpirationExtractorType = ExpirationExtractor(),
        cvcFormatter: CvcFormatterType = CvcFormatter(),
        cvcValidator: CvcValidatorType = CvcValidator(),
        accountsService: AccountsServiceType = AccountsService.shared,
        tokenService: TokenServiceType = TokenService.shared) {
        self.cardNumberFormatter = cardNumberFormatter
        self.cardNumberValidator = cardNumberValidator
        self.expirationFormatter = expirationFormatter
        self.expirationValidator = expirationValidator
        self.expirationExtractor = expirationExtractor
        self.cvcFormatter = cvcFormatter
        self.cvcValidator = cvcValidator
        self.accountsService = accountsService
        self.tokenService = tokenService
    }

    // MARK: - CardFormViewViewModelType

    func update(cardNumber: String?) -> Result<CardNumber, FormError> {
        guard let cardNumberInput = self.cardNumberFormatter.string(from: cardNumber), let cardNumber = cardNumber, !cardNumber.isEmpty else {
            self.cardNumber = nil
            self.cardBrand = .unknown
            self.isBrandChanged = false
            return .failure(.cardNumberEmptyError(value: nil, isInstant: false))
        }
        self.isBrandChanged = self.cardBrand != cardNumberInput.brand
        self.cardNumber = cardNumberInput.formatted.numberfy()
        self.cardBrand = cardNumberInput.brand

        if let cardNumber = self.cardNumber {
            // 利用可能ブランドのチェック
            if let acceptedCardBrands = self.acceptedCardBrands {
                if cardNumberInput.brand != .unknown && !acceptedCardBrands.contains(cardNumberInput.brand) {
                    return .failure(.cardNumberInvalidError(value: cardNumberInput, isInstant: false))
                }
            }
            // 桁数チェック
            if cardNumber.count == cardNumberInput.brand.numberLength {
                if !self.cardNumberValidator.isLuhnValid(cardNumber: cardNumber) {
                    return .failure(.cardNumberInvalidError(value: cardNumberInput, isInstant: true))
                }
            } else if cardNumber.count > cardNumberInput.brand.numberLength {
                return .failure(.cardNumberInvalidError(value: cardNumberInput, isInstant: true))
            } else {
                return .failure(.cardNumberInvalidError(value: cardNumberInput, isInstant: false))
            }

            if cardNumberInput.brand == .unknown {
                return .failure(.cardNumberInvalidBrandError(value: cardNumberInput, isInstant: false))
            }
        }
        return .success(cardNumberInput)
    }

    func update(expiration: String?) -> Result<String, FormError> {
        guard let expirationInput = self.expirationFormatter.string(from: expiration), let expiration = expiration, !expiration.isEmpty else {
            self.monthYear = nil
            return .failure(.expirationEmptyError(value: nil, isInstant: false))
        }

        do {
            self.monthYear = try self.expirationExtractor.extract(expiration: expirationInput)
        } catch {
            return .failure(.expirationInvalidError(value: expirationInput, isInstant: true))
        }

        if let (month, year) = self.monthYear {
            if !self.expirationValidator.isValid(month: month, year: year) {
                return .failure(.expirationInvalidError(value: expirationInput, isInstant: true))
            }
        } else {
            return .failure(.expirationInvalidError(value: expirationInput, isInstant: false))
        }
        return .success(expirationInput)
    }

    func update(cvc: String?) -> Result<String, FormError> {
        guard var cvcInput = self.cvcFormatter.string(from: cvc, brand: self.cardBrand), let cvc = cvc, !cvc.isEmpty else {
            self.cvc = nil
            return .failure(.cvcEmptyError(value: nil, isInstant: false))
        }
        if self.isBrandChanged  {
            cvcInput = cvc
        }
        self.cvc = cvcInput

        if let cvc = self.cvc {
            let result = self.cvcValidator.isValid(cvc: cvc, brand: self.cardBrand)
            if !result.validated {
                return .failure(.cvcInvalidError(value: cvc, isInstant: result.isInstant))
            }
        }
        return .success(cvcInput)
    }

    func update(cardHolder: String?) -> Result<String, FormError> {
        guard let holderInput = cardHolder, let cardHolder = cardHolder, !cardHolder.isEmpty else {
            self.cardHolder = nil
            return .failure(.cardHolderEmptyError(value: nil, isInstant: false))
        }
        self.cardHolder = holderInput

        return .success(holderInput)
    }

    func update(isCardHolderEnabled: Bool) {
        self.isCardHolderEnabled = isCardHolderEnabled
    }

    func isValid() -> Bool {
        return checkCardNumberValid() &&
            checkExpirationValid() &&
            checkCvcValid() &&
            (!self.isCardHolderEnabled || checkCardHolderValid())
    }
    
    func createToken(with tenantId: String?, completion: @escaping (Result<Token, Error>) -> Void) {
        if let cardNumber = cardNumber, let month = monthYear?.month, let year = monthYear?.year, let cvc = cvc {
            tokenService.createToken(cardNumber: cardNumber,
                                     cvc: cvc,
                                     expirationMonth: month,
                                     expirationYear: year,
                                     name: cardHolder,
                                     tenantId: tenantId) { result in
                                        switch result {
                                        case .success(let token): completion(.success(token))
                                        case .failure(let error): completion(.failure(error))
                                        }
            }
        } else {
            completion(.failure(LocalError.invalidFormInput))
        }
    }

    func fetchAcceptedBrands(with tenantId: String?, completion: CardBrandsResult?) {
        accountsService.getAcceptedBrands(tenantId: tenantId) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let brands):
                self.acceptedCardBrands = brands
                completion?(.success(brands))
            case .failure(let error):
                completion?(.failure(error))
            }
        }
    }

    // MARK: - Helpers

    private func checkCardNumberValid() -> Bool {
        if let cardNumber = self.cardNumber {
            return self.cardNumberValidator.isValid(cardNumber: cardNumber, brand: self.cardBrand)
        }
        return false
    }

    private func checkExpirationValid() -> Bool {
        if let (month, year) = self.monthYear {
            return self.expirationValidator.isValid(month: month, year: year)
        }
        return false
    }

    private func checkCvcValid() -> Bool {
        if let cvc = self.cvc {
            let result = self.cvcValidator.isValid(cvc: cvc, brand: self.cardBrand)
            return result.validated
        }
        return false
    }

    private func checkCardHolderValid() -> Bool {
        if let cardHolder = self.cardHolder {
            return !cardHolder.isEmpty
        }
        return false
    }
}
