import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

#if canImport(MacrosImplementation)
    import MacrosImplementation

    let testURLMacro: [String: Macro.Type] = [
        "url": URLMacro.self
    ]
#endif

final class URLMacroTests: XCTestCase {
    func testValid() throws {
        #if canImport(MacrosImplementation)
            assertMacroExpansion(
                #"let url = #url("https://apple.com")"#,
                expandedSource: #"let url = URL(string: "https://apple.com")"#,
                macros: testURLMacro
            )
        #else
            throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testNotString() throws {
        #if canImport(MacrosImplementation)
            assertMacroExpansion(
                #"let url = #url(1)"#,
                expandedSource: #"let url = #url(1)"#,
                diagnostics: [DiagnosticSpec(
                    message: "Expected a string literal as the argument to the `url` macro.",
                    line: 1,
                    column: 11
                )],
                macros: testURLMacro
            )
        #else
            throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testInvalidURL() throws {
        #if canImport(MacrosImplementation)
            assertMacroExpansion(
                #"let url = #url("")"#,
                expandedSource: #"let url = #url("")"#,
                diagnostics: [DiagnosticSpec(
                    message: "The argument to the `url` macro must be a valid URL string.",
                    line: 1,
                    column: 11
                )],
                macros: testURLMacro
            )
        #else
            throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
}
