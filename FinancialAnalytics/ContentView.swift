//
//  ContentView.swift
//  FinancialAnalytics
//
//  Created by Анастасия Лелекова on 06.02.2024.
//

import SwiftUI

struct BankAccount: Equatable {
    let bankLogo: String
    let cardNumber: String
    let expirationDate: String
    let cvv: String
    let balance: Double
}

struct ContentView: View {
    @State private var accounts: [BankAccount] = []
    @State private var isAddingAccount = false
    @State private var cardNumber = ""
    @State private var expirationDate = ""
    @State private var cvv = ""
    @State private var isCardNumberValid = true
    @State private var isExpirationDateValid = true
    @State private var isCVVValid = true
    @State private var selectedBank: String = "Выберите банк"

    var body: some View {
        VStack {
            if accounts.isEmpty {
                Spacer()
                Text("Ваш Wallet пуст")
                    .fontWeight(.bold)
                    .foregroundColor(.red)
                    .font(.title)
                    .padding()
                Text("Сначала подключите банковский счет для отслеживания операций")
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 30)
            } else {
                ForEach(accounts, id: \.cardNumber) { account in
                    CardView(bankLogo: account.bankLogo, cardNumber: account.cardNumber, balance: account.balance) {
                        removeCard(card: account)
                    }
                }
            }
            Button("Подключить банковский счет") {
                isAddingAccount.toggle()
            }
            .buttonStyle(BlueButtonStyle())
            .sheet(isPresented: $isAddingAccount) {
                AddAccountView(cardNumber: $cardNumber, expirationDate: $expirationDate, cvv: $cvv, accounts: $accounts, isAddingAccount: $isAddingAccount, isCardNumberValid: $isCardNumberValid, isExpirationDateValid: $isExpirationDateValid, isCVVValid: $isCVVValid, selectedBank: $selectedBank)
            }
            Spacer()
        }
        .padding()
    }

    // Функция для удаления карточки из списка
    private func removeCard(card: BankAccount) {
        withAnimation {
            if let index = accounts.firstIndex(where: { $0 == card }) {
                accounts.remove(at: index)
            }
        }
    }
}

struct CardView: View {
    let bankLogo: String
    let cardNumber: String
    let balance: Double
    var onRemove: (() -> Void)?

    var body: some View {
        HStack {
            Image(bankLogo)
                .resizable()
                .frame(width: 50, height: 50)

            VStack(alignment: .leading) {
                Text("Номер: \(cardNumber)")
                Text("Баланс: \(balance)")
            }

            Spacer()

            if let onRemove = onRemove {
                Button(action: {
                    onRemove()
                }) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 3)
        .padding(.bottom, 10)
    }
}

struct AddAccountView: View {
    @Binding var cardNumber: String
    @Binding var expirationDate: String
    @Binding var cvv: String
    @Binding var accounts: [BankAccount]
    @Binding var isAddingAccount: Bool
    @Binding var isCardNumberValid: Bool
    @Binding var isExpirationDateValid: Bool
    @Binding var isCVVValid: Bool
    @Binding var selectedBank: String
    let availableBanks = ["Сбербанк", "Тинькофф", "ВТБ"]

    var body: some View {
        VStack {
            Picker("Выберите банк", selection: $selectedBank) {
                            ForEach(availableBanks, id: \.self) { bank in
                                Text(bank)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .textFieldStyle(RoundedBorderTextFieldStyle())
            
            TextField("Введите номер карты", text: $cardNumber)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .cornerRadius(8)
                .autocapitalization(.none)
                .textContentType(.creditCardNumber)
                .keyboardType(.numberPad)
                .onChange(of: cardNumber) { newValue in
                    cardNumber = formatCardNumber(newValue)
                }
            
            HStack {
                TextField("MM/YY", text: $expirationDate)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .cornerRadius(8)
                    .keyboardType(.numberPad)
                    .onChange(of: expirationDate) { newValue in
                        expirationDate = formatExpirationDate(newValue)
                    }

                Spacer()

                TextField("CVV", text: $cvv)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .cornerRadius(8)
                    .keyboardType(.numberPad)
            }

            Button("Добавить") {
                // Проверяем валидность данных
                isCardNumberValid = isValidCardNumber(cardNumber)
                isExpirationDateValid = isValidExpirationDate(expirationDate)
                isCVVValid = isValidCVV(cvv)

                // Если все данные валидны, добавляем новый счет
                // Если все данные валидны, добавляем новый счет
                if isCardNumberValid && isExpirationDateValid && isCVVValid {
                    accounts.append(BankAccount(bankLogo: "bankLogo", cardNumber: formatCardNumber(cardNumber), expirationDate: expirationDate, cvv: cvv, balance: 0.0))
                    isAddingAccount.toggle()

                    // Сброс значений полей
                    cardNumber = ""
                    expirationDate = ""
                    cvv = ""
                    isCardNumberValid = true
                    isExpirationDateValid = true
                    isCVVValid = true
                }

            }
            .buttonStyle(BlueButtonStyle())
        }
        .padding()
    }

    // Функция для форматирования номера карты
    private func formatCardNumber(_ cardNumber: String) -> String {
        let strippedNumber = cardNumber.replacingOccurrences(of: " ", with: "")
        return strippedNumber
            .enumerated()
            .map { (index, character) in
                return index > 0 && index % 4 == 0 ? " \(character)" : String(character)
            }
            .joined()
    }

    // Функция для форматирования срока действия
    private func formatExpirationDate(_ expirationDate: String) -> String {
        let strippedDate = expirationDate.replacingOccurrences(of: "/", with: "")
        return strippedDate
            .enumerated()
            .map { (index, character) in
                return index > 1 && index % 2 == 0 ? "/\(character)" : String(character)
            }
            .joined()
    }

    // Функция для валидации номера карты
    private func isValidCardNumber(_ cardNumber: String) -> Bool {
        let strippedNumber = cardNumber.replacingOccurrences(of: " ", with: "")
        return strippedNumber.count == 16 && strippedNumber.range(of: #"^\d+$"#, options: .regularExpression) != nil
    }

    // Функция для валидации срока действия
    private func isValidExpirationDate(_ expirationDate: String) -> Bool {
        return expirationDate.count == 5 && expirationDate.range(of: #"^\d{2}/\d{2}$"#, options: .regularExpression) != nil
    }

    // Функция для валидации CVV кода
    private func isValidCVV(_ cvv: String) -> Bool {
        return cvv.count == 3 && cvv.range(of: #"^\d{3}$"#, options: .regularExpression) != nil
    }
}

struct BlueButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .padding()
            .foregroundColor(.white)
            .background(Color.blue)
            .cornerRadius(10)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
