/// Special keyboard keys in sendKeys and keys WebDriver commands
public enum KeyCode: String {
    case a = "a"
    case b = "b"
    case c = "c"
    case d = "d"
    case e = "e"
    case f = "f"
    case g = "g"
    case h = "h"
    case i = "i"
    case j = "j"
    case k = "k"
    case l = "l"
    case m = "m"
    case n = "n"
    case o = "o"
    case p = "p"
    case q = "q"
    case r = "r"
    case s = "s"
    case t = "t"
    case u = "u"
    case v = "v"
    case w = "w"
    case x = "x"
    case y = "y"
    case z = "z"

    case digit1 = "1"
    case digit2 = "2"
    case digit3 = "3"
    case digit4 = "4"
    case digit5 = "5"
    case digit6 = "6"
    case digit7 = "7"
    case digit8 = "8"
    case digit9 = "9"
    case digit0 = "0"

    /// Resets the state of modifier keys
    case null = "\u{E000}"
    case cancel = "\u{E001}"
    case help = "\u{E002}"
    case backspace = "\u{E003}"
    case tab = "\u{E004}"
    case clear = "\u{E005}"
    case returnKey = "\u{E006}"
    case enter = "\u{E007}"
    case shift = "\u{E008}"
    case control = "\u{E009}"
    case alt = "\u{E00A}"
    case pause = "\u{E00B}"
    case escape = "\u{E00C}"
    case space = "\u{E00D}"
    case pageup = "\u{E00E}"
    case pagedown = "\u{E00F}"
    case end = "\u{E010}"
    case home = "\u{E011}"
    case leftArrow = "\u{E012}"
    case upArrow = "\u{E013}"
    case rightArrow = "\u{E014}"
    case downArrow = "\u{E015}"
    case insert = "\u{E016}"
    case delete = "\u{E017}"
    case semicolon = "\u{E018}"
    case equals = "\u{E019}"
    case numpad0 = "\u{E01A}"
    case numpad1 = "\u{E01B}"
    case numpad2 = "\u{E01C}"
    case numpad3 = "\u{E01D}"
    case numpad4 = "\u{E01E}"
    case numpad5 = "\u{E01F}"
    case numpad6 = "\u{E020}"
    case numpad7 = "\u{E021}"
    case numpad8 = "\u{E022}"
    case numpad9 = "\u{E023}"
    case multiply = "\u{E024}"
    case add = "\u{E025}"
    case separator = "\u{E026}"
    case subtract = "\u{E027}"
    case decimal = "\u{E028}"
    case divide = "\u{E029}"
    case f1 = "\u{E031}"
    case f2 = "\u{E032}"
    case f3 = "\u{E033}"
    case f4 = "\u{E034}"
    case f5 = "\u{E035}"
    case f6 = "\u{E036}"
    case f7 = "\u{E037}"
    case f8 = "\u{E038}"
    case f9 = "\u{E039}"
    case f10 = "\u{E03A}"
    case f11 = "\u{E03B}"
    case f12 = "\u{E03C}"
    case meta = "\u{E03D}"

    public static var macOSCommand: KeyCode { .meta }
}

extension KeyCode {
    public var isModifier: Bool {
        switch self {
            case .shift, .control, .alt, .meta: return true
            default: return false
        }
    }

    public static func typeTextUsingWindowsAltCodes(_ text: String) -> [KeyCode] {
        var result = [KeyCode]()
        for codePoint in text.unicodeScalars {
            result.append(KeyCode.alt)
            for digit in String(codePoint.value) {
                switch digit {
                    case "0": result.append(KeyCode.numpad0)
                    case "1": result.append(KeyCode.numpad1)
                    case "2": result.append(KeyCode.numpad2)
                    case "3": result.append(KeyCode.numpad3)
                    case "4": result.append(KeyCode.numpad4)
                    case "5": result.append(KeyCode.numpad5)
                    case "6": result.append(KeyCode.numpad6)
                    case "7": result.append(KeyCode.numpad7)
                    case "8": result.append(KeyCode.numpad8)
                    case "9": result.append(KeyCode.numpad9)
                    default: fatalError()
                }
            }
            result.append(KeyCode.alt)
        }
        return result
    }

    public static func shift(_ key: KeyCode) -> [KeyCode] {
        precondition(!key.isModifier && key != .null)
        return [.shift, key, .shift]
    }

    public static func control(_ key: KeyCode) -> [KeyCode] {
        precondition(!key.isModifier && key != .null)
        return [.control, key, .control]
    }

    public static func alt(_ key: KeyCode) -> [KeyCode] {
        precondition(!key.isModifier && key != .null)
        return [.alt, key, .alt]
    }

    public static func meta(_ key: KeyCode) -> [KeyCode] {
        precondition(!key.isModifier && key != .null)
        return [.meta, key, .meta]
    }

    public static func combo(key: KeyCode, shift: Bool = false, control: Bool = false, alt: Bool = false, meta: Bool = false) -> [KeyCode] {
        precondition(!key.isModifier && key != .null)

        var result = [KeyCode]()

        if shift { result.append(KeyCode.shift) }
        if control { result.append(KeyCode.control) }
        if alt { result.append(KeyCode.alt) }
        if meta { result.append(KeyCode.meta) }

        result.append(key)

        if meta { result.append(KeyCode.meta) }
        if alt { result.append(KeyCode.alt) }
        if control { result.append(KeyCode.control) }
        if shift { result.append(KeyCode.shift) }

        return result
    }
}