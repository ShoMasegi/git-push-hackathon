import UIKit

extension UIColor {
    static var primary_main: UIColor { return primary_800 }
    static var primary_900: UIColor { return UIColor(hex: "14131D") }
    static var primary_800: UIColor { return UIColor(hex: "33333D") }
    static var primary_700: UIColor { return UIColor(hex: "51515C") }
    static var primary_600: UIColor { return UIColor(hex: "64646F") }
    static var primary_500: UIColor { return UIColor(hex: "8C8B97") }
    static var primary_400: UIColor { return UIColor(hex: "ACACB8") }
    static var primary_300: UIColor { return UIColor(hex: "D1D1DD") }

    static var secondary_main: UIColor { return secondary_600 }
    static var secondary_900: UIColor { return UIColor(hex: "006064") }
    static var secondary_800: UIColor { return UIColor(hex: "00838F") }
    static var secondary_700: UIColor { return UIColor(hex: "0097A7") }
    static var secondary_600: UIColor { return UIColor(hex: "00ACC1") }
    static var secondary_500: UIColor { return UIColor(hex: "00BCD4") }
    static var secondary_400: UIColor { return UIColor(hex: "26C6DA") }
    static var secondary_300: UIColor { return UIColor(hex: "4DD0E1") }
}

extension UIColor {
    convenience init(hex: String, alpha: CGFloat) {
        let v = hex.map { String($0) } + Array(repeating: "0", count: max(6 - hex.count, 0))
        let r = CGFloat(Int(v[0] + v[1], radix: 16) ?? 0) / 255.0
        let g = CGFloat(Int(v[2] + v[3], radix: 16) ?? 0) / 255.0
        let b = CGFloat(Int(v[4] + v[5], radix: 16) ?? 0) / 255.0
        self.init(red: r, green: g, blue: b, alpha: alpha)
    }

    public convenience init(hex: String) {
        self.init(hex: hex, alpha: 1.0)
    }
}
