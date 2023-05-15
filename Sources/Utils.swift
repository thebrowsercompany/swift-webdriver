    
// Build the argument string of a command line from an array of arguments
// properly excaping each argument
func buildArgString(args: [String]?) -> String? {
    func escapeArg(arg: String) -> String {
        var escapedArg = arg.replacingOccurrences(of: "\\", with: "\\\\").replacingOccurrences(of: "\"", with: "\\\"") // Escape backslashes and double quotes
        if escapedArg.contains(" ") || arg.contains("\t") {
            escapedArg = "\"\(escapedArg)\"" // quote args with spaces
        }
        return escapedArg
    }

    return args?.map(escapeArg).joined(separator: " ")
}
