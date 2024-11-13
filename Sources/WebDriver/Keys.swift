/// Represents a sequence of WebDriver key events and characters.
public struct Keys: RawRepresentable {
    /// A string encoding the key sequence as defined by the WebDriver spec.
    public var rawValue: String

    public init(rawValue: String) { self.rawValue = rawValue }

    /// Concatenates multiple key sequences into a single one.
    public static func sequence(_ keys: [Self]) -> Self {
        Self(rawValue: keys.reduce("") { $0 + $1.rawValue })
    }

    /// Concatenates multiple key sequences into a single one.
    public static func sequence(_ keys: Self...) -> Self {
        sequence(keys)
    }
}

// MARK: Key constants
extension Keys {
    public static let a = Self(rawValue: "a")
    public static let b = Self(rawValue: "b")
    public static let c = Self(rawValue: "c")
    public static let d = Self(rawValue: "d")
    public static let e = Self(rawValue: "e")
    public static let f = Self(rawValue: "f")
    public static let g = Self(rawValue: "g")
    public static let h = Self(rawValue: "h")
    public static let i = Self(rawValue: "i")
    public static let j = Self(rawValue: "j")
    public static let k = Self(rawValue: "k")
    public static let l = Self(rawValue: "l")
    public static let m = Self(rawValue: "m")
    public static let n = Self(rawValue: "n")
    public static let o = Self(rawValue: "o")
    public static let p = Self(rawValue: "p")
    public static let q = Self(rawValue: "q")
    public static let r = Self(rawValue: "r")
    public static let s = Self(rawValue: "s")
    public static let t = Self(rawValue: "t")
    public static let u = Self(rawValue: "u")
    public static let v = Self(rawValue: "v")
    public static let w = Self(rawValue: "w")
    public static let x = Self(rawValue: "x")
    public static let y = Self(rawValue: "y")
    public static let z = Self(rawValue: "z")

    public static let digit1 = Self(rawValue: "1")
    public static let digit2 = Self(rawValue: "2")
    public static let digit3 = Self(rawValue: "3")
    public static let digit4 = Self(rawValue: "4")
    public static let digit5 = Self(rawValue: "5")
    public static let digit6 = Self(rawValue: "6")
    public static let digit7 = Self(rawValue: "7")
    public static let digit8 = Self(rawValue: "8")
    public static let digit9 = Self(rawValue: "9")
    public static let digit0 = Self(rawValue: "0")

    public static let cancel = Self(rawValue: "\u{E001}")
    public static let help = Self(rawValue: "\u{E002}")
    public static let backspace = Self(rawValue: "\u{E003}")
    public static let tab = Self(rawValue: "\u{E004}")
    public static let clear = Self(rawValue: "\u{E005}")
    public static let returnKey = Self(rawValue: "\u{E006}")
    public static let enter = Self(rawValue: "\u{E007}")
    public static let pause = Self(rawValue: "\u{E00B}")
    public static let escape = Self(rawValue: "\u{E00C}")
    public static let space = Self(rawValue: "\u{E00D}")
    public static let pageup = Self(rawValue: "\u{E00E}")
    public static let pagedown = Self(rawValue: "\u{E00F}")
    public static let end = Self(rawValue: "\u{E010}")
    public static let home = Self(rawValue: "\u{E011}")
    public static let leftArrow = Self(rawValue: "\u{E012}")
    public static let upArrow = Self(rawValue: "\u{E013}")
    public static let rightArrow = Self(rawValue: "\u{E014}")
    public static let downArrow = Self(rawValue: "\u{E015}")
    public static let insert = Self(rawValue: "\u{E016}")
    public static let delete = Self(rawValue: "\u{E017}")
    public static let semicolon = Self(rawValue: "\u{E018}")
    public static let equals = Self(rawValue: "\u{E019}")
    public static let numpad0 = Self(rawValue: "\u{E01A}")
    public static let numpad1 = Self(rawValue: "\u{E01B}")
    public static let numpad2 = Self(rawValue: "\u{E01C}")
    public static let numpad3 = Self(rawValue: "\u{E01D}")
    public static let numpad4 = Self(rawValue: "\u{E01E}")
    public static let numpad5 = Self(rawValue: "\u{E01F}")
    public static let numpad6 = Self(rawValue: "\u{E020}")
    public static let numpad7 = Self(rawValue: "\u{E021}")
    public static let numpad8 = Self(rawValue: "\u{E022}")
    public static let numpad9 = Self(rawValue: "\u{E023}")
    public static let multiply = Self(rawValue: "\u{E024}")
    public static let add = Self(rawValue: "\u{E025}")
    public static let separator = Self(rawValue: "\u{E026}")
    public static let subtract = Self(rawValue: "\u{E027}")
    public static let decimal = Self(rawValue: "\u{E028}")
    public static let divide = Self(rawValue: "\u{E029}")
    public static let f1 = Self(rawValue: "\u{E031}")
    public static let f2 = Self(rawValue: "\u{E032}")
    public static let f3 = Self(rawValue: "\u{E033}")
    public static let f4 = Self(rawValue: "\u{E034}")
    public static let f5 = Self(rawValue: "\u{E035}")
    public static let f6 = Self(rawValue: "\u{E036}")
    public static let f7 = Self(rawValue: "\u{E037}")
    public static let f8 = Self(rawValue: "\u{E038}")
    public static let f9 = Self(rawValue: "\u{E039}")
    public static let f10 = Self(rawValue: "\u{E03A}")
    public static let f11 = Self(rawValue: "\u{E03B}")
    public static let f12 = Self(rawValue: "\u{E03C}")

    /// Modifier keys are interpreted as toggles instead of key presses.
    public static let shiftModifier = Keys(rawValue: "\u{E008}")
    public static let controlModifier = Keys(rawValue: "\u{E009}")
    public static let altModifier = Keys(rawValue: "\u{E00A}")
    public static let metaModifier = Keys(rawValue: "\u{E03D}")

    public static var windowsModifier: Keys { metaModifier }
    public static var macCommandModifier: Keys { metaModifier }
    public static var macOptionModifier: Keys { altModifier }

    /// A special Keys value that causes all modifiers to be released.
    public static let releaseModifiers = Keys(rawValue: "\u{E000}")
}

// MARK: Modifier sequences
extension Keys {
    /// Wraps a keys sequence with holding and releasing the shift key.
    public static func shift(_ keys: Self) -> Self {
        sequence(shiftModifier, keys, shiftModifier)
    }

    /// Wraps a keys sequence with holding and releasing the control key.
    public static func control(_ keys: Self) -> Self {
        sequence(controlModifier, keys, controlModifier)
    }

    /// Wraps a keys sequence with holding and releasing the alt key.
    public static func alt(_ keys: Self) -> Self {
        sequence(altModifier, keys, altModifier)
    }

    /// Wraps a keys sequence with holding and releasing the meta key.
    public static func meta(_ keys: Self) -> Self {
        sequence(metaModifier, keys, metaModifier)
    }
}

// MARK: Text and typing
extension Keys {
    public enum TypingStrategy {
        case assumeUSKeyboard
        case windowsKeyboardAgnostic
    }

    public static func text(_ str: String, typingStrategy: TypingStrategy) -> Self {
        switch typingStrategy {
            case .assumeUSKeyboard: return Self(rawValue: str)
            case .windowsKeyboardAgnostic: return text_windowsKeyboardAgnostic(str)
        }
    }

    private static func text_windowsKeyboardAgnostic(_ str: String) -> Self {
        var result = ""
        for codePoint in str.unicodeScalars {
            if isUSKeyboardKeyCharacter(codePoint) {
                // Avoid sending it as a key event, which is dependent on keyboard layout.
                // For example, the "q" key would type "a" on an AZERTY keyboard layout.
                // Instead, use the alt+numpad code to type the character.
                result += altModifier.rawValue
                for digit in String(codePoint.value) {
                    switch digit {
                        case "0": result += Self.numpad0.rawValue
                        case "1": result += Self.numpad1.rawValue
                        case "2": result += Self.numpad2.rawValue
                        case "3": result += Self.numpad3.rawValue
                        case "4": result += Self.numpad4.rawValue
                        case "5": result += Self.numpad5.rawValue
                        case "6": result += Self.numpad6.rawValue
                        case "7": result += Self.numpad7.rawValue
                        case "8": result += Self.numpad8.rawValue
                        case "9": result += Self.numpad9.rawValue
                        default: fatalError()
                    }
                }
                result += altModifier.rawValue
            }
            else {
                // Other printable characters will be sent as character events,
                // independent of keyboard layout.
                result += String(codePoint)
            }
        }

        return Self(rawValue: result)
    }

    /// Tests whether a given character can be typed using a single key on a US English keyboard.
    /// The WebDriver spec will send these characters as key events, and expect them
    /// to be translated into the original character, but this depends on the keyboard layout.
    /// Characters like "A" and "!" are not listed because they require modifiers to type.
    private static func isUSKeyboardKeyCharacter(_ codePoint: UnicodeScalar) -> Bool {
        switch codePoint {
            case "a"..."z": return true
            case "0"..."9": return true
            case "`", "-", "=", "[", "]", "\\", ";", "'", ",", ".", "/": return true
            default: return false
        }
    }
}
