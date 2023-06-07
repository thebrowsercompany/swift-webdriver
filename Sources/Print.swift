import Foundation

// stdout is not flush when we crash
// Use this utility functon to force flush
func printAndFlush(_ msg: String) {
    print(msg)
    fflush(stdout)
}
