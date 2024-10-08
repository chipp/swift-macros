import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

// Macro implementations build for the host, so the corresponding module is not available when cross-compiling. Cross-compiled tests may still make use of the macro itself in end-to-end tests.
#if canImport(MacrosImplementation)
    import MacrosImplementation

    let testMacros: [String: Macro.Type] = [
        "HasLogger": HasLoggerMacro.self
    ]
#endif

final class HasLoggerMacroTests: XCTestCase {
    func testNoParams() throws {
        #if canImport(MacrosImplementation)
            assertMacroExpansion(
                """
                @HasLogger
                final class Model {}
                """,
                expandedSource: """
                final class Model {}

                extension Model {
                    static let logger = Logger(subsystem: "TestModule", category: "Model")
                }
                """,
                macros: testMacros
            )
        #else
            throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testWithSubsystem() throws {
        #if canImport(MacrosImplementation)
            assertMacroExpansion(
                """
                @HasLogger(subsystem: "MyGame")
                final class Model {}
                """,
                expandedSource: """
                final class Model {}

                extension Model {
                    static let logger = Logger(subsystem: "MyGame", category: "Model")
                }
                """,
                macros: testMacros
            )
        #else
            throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testWithCategory() throws {
        #if canImport(MacrosImplementation)
            assertMacroExpansion(
                """
                @HasLogger(category: "MyModel")
                final class Model {}
                """,
                expandedSource: """
                final class Model {}

                extension Model {
                    static let logger = Logger(subsystem: "TestModule", category: "MyModel")
                }
                """,
                macros: testMacros
            )
        #else
            throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testWithSubsystemAndCategory() throws {
        #if canImport(MacrosImplementation)
            assertMacroExpansion(
                """
                @HasLogger(subsystem: "MyGame", category: "MyModel")
                final class Model {}
                """,
                expandedSource: """
                final class Model {}

                extension Model {
                    static let logger = Logger(subsystem: "MyGame", category: "MyModel")
                }
                """,
                macros: testMacros
            )
        #else
            throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
}
