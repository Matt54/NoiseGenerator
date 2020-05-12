//  Created by Daniel Brotsky on 02/02/2020 (aka "international palindrome day").
//  Based on code from this StackOverflow question:
//  https://stackoverflow.com/q/59621625/558006
//  No Copyright is asserted on this code.
//

import SwiftUI
import Combine

//MARK: - Parse and format decimal strings with remembered precision

class DecimalPrecision {
    private let validCharSet = CharacterSet(charactersIn: "1234567890.")

    var integerDigits : Int = -2
    var fractionDigits : Int = -2
    var defaultFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.alwaysShowsDecimalSeparator = false
        formatter.maximumFractionDigits = 10
        return formatter
    }()

    func parseDecimal(_ text: String) -> Decimal? {
        if text.rangeOfCharacter(from: validCharSet.inverted) != nil {
            return nil
        }
        if text.isEmpty {
            integerDigits = -1
            fractionDigits = -1
            return 0
        }
        if let value = Decimal(string: text) {
            let substring = text.split(separator: Character("."),
                                       maxSplits: 2,
                                       omittingEmptySubsequences: false)
            switch substring.count {
                case 1:
                    integerDigits = substring[0].count
                    fractionDigits = -1
                    return value
                case 2:
                    integerDigits = substring[0].count
                    fractionDigits = substring[1].count
                    return value
                default:
                    return nil
            }
        } else {
            return nil
        }
    }

    func formatDecimal(_ value: Decimal) -> String {
        if integerDigits == -2 && fractionDigits == -2 {
            let formatter = NumberFormatter()
            formatter.minimumIntegerDigits = 0
            formatter.alwaysShowsDecimalSeparator = false
            formatter.maximumFractionDigits = 10
            let result = formatter.string(from: value as NSDecimalNumber)!
            return result
        }
        if integerDigits == -1 && fractionDigits == -1 {
            return ""
        }
        if value == Decimal.zero && integerDigits == 0 && fractionDigits == 0 {
            return "."
        }
        let formatter = NumberFormatter()
        formatter.minimumIntegerDigits = integerDigits
        formatter.maximumIntegerDigits = integerDigits
        if fractionDigits >= 0 {
            formatter.alwaysShowsDecimalSeparator = true
            formatter.minimumFractionDigits = fractionDigits
            formatter.maximumFractionDigits = fractionDigits
        } else {
            formatter.alwaysShowsDecimalSeparator = false
            formatter.maximumFractionDigits = 0
        }
        return formatter.string(from: value as NSDecimalNumber)!
    }

    convenience init(using: NumberFormatter) {
        self.init()
        defaultFormatter = using
    }
}

//MARK: - Decimal Text Field with allowed external precision

public struct DecimalTextField: View {
    private class DecimalTextModel: ObservableObject {
        var valueBinding: Binding<Decimal>
        var precision: DecimalPrecision
        @Published var text: String {
            didSet{
                if self.text != oldValue {
//                    print("set text: was: ", oldValue, "is:", self.text)
                    if let value = self.precision.parseDecimal(self.text) {
                        if value != self.valueBinding.wrappedValue {
                            self.valueBinding.wrappedValue = value
                        }
                    } else {
                        self.text = oldValue
                    }
                }
            }
        }
        init(value: Binding<Decimal>, precision: DecimalPrecision) {
            valueBinding = value
            self.precision = precision
            text = precision.formatDecimal(value.wrappedValue)
        }
    }

    @ObservedObject private var viewModel: DecimalTextModel
    private let placeHolder: String
    init(_ placeHolder: String = "", value: Binding<Decimal>, precision: DecimalPrecision) {
//        print("init field: value:", value.wrappedValue, "int dig:", precision.integerDigits, "frac dig:", precision.fractionDigits, "prec ptr:", Unmanaged.passUnretained(precision).toOpaque())
        self.placeHolder = placeHolder
        self.viewModel = DecimalTextModel(value: value, precision: precision)
    }
    init(_ placeHolder: String = "", value: Binding<Decimal>) {
        self.init(placeHolder, value: value, precision: DecimalPrecision())
    }

    public var body: some View {
        TextField(placeHolder, text: $viewModel.text)
            .keyboardType(.decimalPad)
    }
}

// MARK: - self-tests

struct testView: View {
    var placeholder: String
    @State var value1: Decimal
    @State var value2: Decimal
    @State private var precision1 = DecimalPrecision()
    var body: some View {
        return VStack(alignment: .center) {
            Text("value1: \(String(format: "%.2f", Double(truncating: value1 as NSNumber)))")
            DecimalTextField(placeholder, value: $value1, precision: precision1)
            Text("value2: \(String.init(format: "%.2f", Double(truncating: value2 as NSNumber)))")
            DecimalTextField(placeholder, value: $value2)
        }
    }
}

struct decimalTextField_Previews: PreviewProvider {
    static var previews: some View {
        testView(placeholder: "0",
                 value1: 350.4975,
                 value2: 25.49)
    }
}
