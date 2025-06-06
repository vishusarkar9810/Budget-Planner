//
//  Currency.swift
//  Budget Planner
//
//  Created for improved currency support
//

import Foundation

enum Currency: String, CaseIterable, Identifiable, Codable {
    // Major currencies
    case usd = "USD"
    case eur = "EUR"
    case gbp = "GBP"
    case jpy = "JPY"
    case chf = "CHF"
    case cad = "CAD"
    case aud = "AUD"
    case nzd = "NZD"
    
    // Asian currencies
    case cny = "CNY"
    case hkd = "HKD"
    case sgd = "SGD"
    case inr = "INR"
    case krw = "KRW"
    case thb = "THB"
    case idr = "IDR"
    case myr = "MYR"
    case php = "PHP"
    case twd = "TWD"
    case pkr = "PKR"
    case bdt = "BDT"
    case vnd = "VND"
    
    // European currencies
    case sek = "SEK"
    case nok = "NOK"
    case dkk = "DKK"
    case pln = "PLN"
    case czk = "CZK"
    case huf = "HUF"
    case ron = "RON"
    case bgn = "BGN"
    case hrk = "HRK"
    case rsd = "RSD"
    case isk = "ISK"
    case lira = "TRY" // Turkish Lira
    case rub = "RUB"
    case uah = "UAH"
    
    // Middle Eastern currencies
    case ils = "ILS"
    case aed = "AED"
    case sar = "SAR"
    case qar = "QAR"
    case kwd = "KWD"
    case bhd = "BHD"
    case omr = "OMR"
    case egp = "EGP"
    
    // American currencies
    case mxn = "MXN"
    case brl = "BRL"
    case ars = "ARS"
    case clp = "CLP"
    case cop = "COP"
    case pen = "PEN"
    case uyu = "UYU"
    
    // African currencies
    case zar = "ZAR"
    case ngn = "NGN"
    case kes = "KES"
    case ghs = "GHS"
    case mad = "MAD"
    case xof = "XOF" // CFA Franc BCEAO
    case xaf = "XAF" // CFA Franc BEAC
    
    // Pacific currencies
    case fjd = "FJD"
    case pgk = "PGK"
    case top = "TOP"
    case vuv = "VUV"
    case wst = "WST"
    
    var id: String { rawValue }
    
    var symbol: String {
        switch self {
        case .usd: return "$"
        case .eur: return "€"
        case .gbp: return "£"
        case .jpy: return "¥"
        case .chf: return "Fr"
        case .cad: return "C$"
        case .aud: return "A$"
        case .nzd: return "NZ$"
        case .cny, .hkd: return "¥"
        case .sgd: return "S$"
        case .inr: return "₹"
        case .krw: return "₩"
        case .thb: return "฿"
        case .idr: return "Rp"
        case .myr: return "RM"
        case .php: return "₱"
        case .twd: return "NT$"
        case .pkr: return "₨"
        case .bdt: return "৳"
        case .vnd: return "₫"
        case .sek: return "kr"
        case .nok: return "kr"
        case .dkk: return "kr"
        case .pln: return "zł"
        case .czk: return "Kč"
        case .huf: return "Ft"
        case .ron: return "lei"
        case .bgn: return "лв"
        case .hrk: return "kn"
        case .rsd: return "дин"
        case .isk: return "kr"
        case .lira: return "₺"
        case .rub: return "₽"
        case .uah: return "₴"
        case .ils: return "₪"
        case .aed: return "د.إ"
        case .sar: return "﷼"
        case .qar: return "﷼"
        case .kwd: return "د.ك"
        case .bhd: return ".د.ب"
        case .omr: return "﷼"
        case .egp: return "£"
        case .mxn: return "$"
        case .brl: return "R$"
        case .ars: return "$"
        case .clp: return "$"
        case .cop: return "$"
        case .pen: return "S/"
        case .uyu: return "$U"
        case .zar: return "R"
        case .ngn: return "₦"
        case .kes: return "KSh"
        case .ghs: return "₵"
        case .mad: return "د.م."
        case .xof, .xaf: return "CFA"
        case .fjd: return "FJ$"
        case .pgk: return "K"
        case .top: return "T$"
        case .vuv: return "VT"
        case .wst: return "WS$"
        }
    }
    
    var displayName: String {
        switch self {
        // Major currencies
        case .usd: return "US Dollar ($)"
        case .eur: return "Euro (€)"
        case .gbp: return "British Pound (£)"
        case .jpy: return "Japanese Yen (¥)"
        case .chf: return "Swiss Franc (Fr)"
        case .cad: return "Canadian Dollar (C$)"
        case .aud: return "Australian Dollar (A$)"
        case .nzd: return "New Zealand Dollar (NZ$)"
        
        // Asian currencies
        case .cny: return "Chinese Yuan (¥)"
        case .hkd: return "Hong Kong Dollar (HK$)"
        case .sgd: return "Singapore Dollar (S$)"
        case .inr: return "Indian Rupee (₹)"
        case .krw: return "South Korean Won (₩)"
        case .thb: return "Thai Baht (฿)"
        case .idr: return "Indonesian Rupiah (Rp)"
        case .myr: return "Malaysian Ringgit (RM)"
        case .php: return "Philippine Peso (₱)"
        case .twd: return "Taiwan Dollar (NT$)"
        case .pkr: return "Pakistani Rupee (₨)"
        case .bdt: return "Bangladeshi Taka (৳)"
        case .vnd: return "Vietnamese Dong (₫)"
        
        // European currencies
        case .sek: return "Swedish Krona (kr)"
        case .nok: return "Norwegian Krone (kr)"
        case .dkk: return "Danish Krone (kr)"
        case .pln: return "Polish Złoty (zł)"
        case .czk: return "Czech Koruna (Kč)"
        case .huf: return "Hungarian Forint (Ft)"
        case .ron: return "Romanian Leu (lei)"
        case .bgn: return "Bulgarian Lev (лв)"
        case .hrk: return "Croatian Kuna (kn)"
        case .rsd: return "Serbian Dinar (дин)"
        case .isk: return "Icelandic Króna (kr)"
        case .lira: return "Turkish Lira (₺)"
        case .rub: return "Russian Ruble (₽)"
        case .uah: return "Ukrainian Hryvnia (₴)"
        
        // Middle Eastern currencies
        case .ils: return "Israeli Shekel (₪)"
        case .aed: return "UAE Dirham (د.إ)"
        case .sar: return "Saudi Riyal (﷼)"
        case .qar: return "Qatari Riyal (﷼)"
        case .kwd: return "Kuwaiti Dinar (د.ك)"
        case .bhd: return "Bahraini Dinar (د.ب)"
        case .omr: return "Omani Rial (﷼)"
        case .egp: return "Egyptian Pound (£)"
        
        // American currencies
        case .mxn: return "Mexican Peso ($)"
        case .brl: return "Brazilian Real (R$)"
        case .ars: return "Argentine Peso ($)"
        case .clp: return "Chilean Peso ($)"
        case .cop: return "Colombian Peso ($)"
        case .pen: return "Peruvian Sol (S/)"
        case .uyu: return "Uruguayan Peso ($U)"
        
        // African currencies
        case .zar: return "South African Rand (R)"
        case .ngn: return "Nigerian Naira (₦)"
        case .kes: return "Kenyan Shilling (KSh)"
        case .ghs: return "Ghanaian Cedi (₵)"
        case .mad: return "Moroccan Dirham (د.م.)"
        case .xof: return "CFA Franc BCEAO (CFA)"
        case .xaf: return "CFA Franc BEAC (CFA)"
        
        // Pacific currencies
        case .fjd: return "Fijian Dollar (FJ$)"
        case .pgk: return "Papua New Guinean Kina (K)"
        case .top: return "Tongan Paʻanga (T$)"
        case .vuv: return "Vanuatu Vatu (VT)"
        case .wst: return "Samoan Tala (WS$)"
        }
    }
    
    // Get the currency's locale for proper formatting
    var locale: Locale? {
        switch self {
        case .usd: return Locale(identifier: "en_US")
        case .eur: return Locale(identifier: "de_DE")
        case .gbp: return Locale(identifier: "en_GB")
        case .jpy: return Locale(identifier: "ja_JP")
        case .chf: return Locale(identifier: "de_CH")
        case .cad: return Locale(identifier: "en_CA")
        case .aud: return Locale(identifier: "en_AU")
        case .nzd: return Locale(identifier: "en_NZ")
        case .cny: return Locale(identifier: "zh_CN")
        case .hkd: return Locale(identifier: "zh_HK")
        case .sgd: return Locale(identifier: "en_SG")
        case .inr: return Locale(identifier: "hi_IN")
        case .krw: return Locale(identifier: "ko_KR")
        case .thb: return Locale(identifier: "th_TH")
        case .idr: return Locale(identifier: "id_ID")
        case .myr: return Locale(identifier: "ms_MY")
        case .php: return Locale(identifier: "en_PH")
        case .twd: return Locale(identifier: "zh_TW")
        case .pkr: return Locale(identifier: "ur_PK")
        case .bdt: return Locale(identifier: "bn_BD")
        case .vnd: return Locale(identifier: "vi_VN")
        case .sek: return Locale(identifier: "sv_SE")
        case .nok: return Locale(identifier: "no_NO")
        case .dkk: return Locale(identifier: "da_DK")
        case .pln: return Locale(identifier: "pl_PL")
        case .czk: return Locale(identifier: "cs_CZ")
        case .huf: return Locale(identifier: "hu_HU")
        case .ron: return Locale(identifier: "ro_RO")
        case .bgn: return Locale(identifier: "bg_BG")
        case .hrk: return Locale(identifier: "hr_HR")
        case .rsd: return Locale(identifier: "sr_RS")
        case .isk: return Locale(identifier: "is_IS")
        case .lira: return Locale(identifier: "tr_TR")
        case .rub: return Locale(identifier: "ru_RU")
        case .uah: return Locale(identifier: "uk_UA")
        case .ils: return Locale(identifier: "he_IL")
        case .aed: return Locale(identifier: "ar_AE")
        case .sar: return Locale(identifier: "ar_SA")
        case .qar: return Locale(identifier: "ar_QA")
        case .kwd: return Locale(identifier: "ar_KW")
        case .bhd: return Locale(identifier: "ar_BH")
        case .omr: return Locale(identifier: "ar_OM")
        case .egp: return Locale(identifier: "ar_EG")
        case .mxn: return Locale(identifier: "es_MX")
        case .brl: return Locale(identifier: "pt_BR")
        case .ars: return Locale(identifier: "es_AR")
        case .clp: return Locale(identifier: "es_CL")
        case .cop: return Locale(identifier: "es_CO")
        case .pen: return Locale(identifier: "es_PE")
        case .uyu: return Locale(identifier: "es_UY")
        case .zar: return Locale(identifier: "en_ZA")
        case .ngn: return Locale(identifier: "en_NG")
        case .kes: return Locale(identifier: "en_KE")
        case .ghs: return Locale(identifier: "en_GH")
        case .mad: return Locale(identifier: "ar_MA")
        case .xof: return Locale(identifier: "fr_SN") // Using Senegal as representative
        case .xaf: return Locale(identifier: "fr_CM") // Using Cameroon as representative
        case .fjd: return Locale(identifier: "en_FJ")
        case .pgk: return Locale(identifier: "en_PG")
        case .top: return Locale(identifier: "to_TO")
        case .vuv: return Locale(identifier: "en_VU")
        case .wst: return Locale(identifier: "en_WS")
        }
    }
    
    // Format a number according to this currency's standards
    func format(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = self.symbol
        formatter.maximumFractionDigits = 2
        
        // Use the appropriate locale if available
        if let locale = self.locale {
            formatter.locale = locale
        }
        
        return formatter.string(from: NSNumber(value: amount)) ?? "\(self.symbol)\(amount)"
    }
} 