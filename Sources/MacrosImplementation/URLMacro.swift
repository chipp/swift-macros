import Foundation
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros

public enum URLMacroError: CustomStringConvertible, LocalizedError {
    case expectedString
    case invalidURL

    public var description: String {
        switch self {
        case .expectedString:
            "Expected a string literal as the argument to the `url` macro."
        case .invalidURL:
            "The argument to the `url` macro must be a valid URL string."
        }
    }

    public var errorDescription: String? {
        description
    }
}

public struct URLMacro: ExpressionMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) throws -> ExprSyntax {
        guard let argument = node.arguments.first?.expression,
              let segments = argument.as(StringLiteralExprSyntax.self)?.segments,
              segments.count == 1,
              case let .stringSegment(literalSegment)? = segments.first
        else {
            throw URLMacroError.expectedString
        }

        let string = literalSegment.content.text
        guard let result = URL(string: string) else {
            throw URLMacroError.invalidURL
        }

        return #"URL(string: "\#(raw: result)")"#
    }
}
