import Foundation
import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public enum HasLoggerMacroError: LocalizedError {
    case cannotExtractModuleName
    case invalidArgumentType(any SyntaxProtocol.Type)

    public var errorDescription: String? {
        switch self {
            case .cannotExtractModuleName:
                #"Cannot extract module name from file path. Specify subsystem name manually @HasLogger(subsystem: "MyModule")"#
            case .invalidArgumentType:
                #"Subsystem and category should be provided as strings: @HasLogger(subsystem: "MyModule", category: "MyClass")"#
        }
    }
}

public struct HasLoggerMacro: ExtensionMacro {
    private typealias OptionalArgs = (subsystem: StringLiteralExprSyntax?, category: StringLiteralExprSyntax?)
    private typealias Args = (subsystem: StringLiteralExprSyntax, category: StringLiteralExprSyntax)

    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        let (subsystem, category) = try handleOptionalArgs(
            parse(arguments: node.arguments),
            declaration: declaration,
            type: type,
            context: context
        )

        return try [
            ExtensionDeclSyntax(
                """
                extension \(type.trimmed) {
                    static let logger = Logger(subsystem: \(subsystem), category: \(category))
                }
                """
            )
        ]
    }

    private static func parse(arguments: AttributeSyntax.Arguments?) throws -> OptionalArgs {
        guard let arguments else {
            return (nil, nil)
        }

        guard case let .argumentList(labeledExprListSyntax) = arguments else {
            return (nil, nil)
        }

        var subsystem: StringLiteralExprSyntax?
        var category: StringLiteralExprSyntax?

        for labeled in labeledExprListSyntax {
            guard let label = labeled.label else {
                continue
            }

            switch label.text {
                case "subsystem":
                    guard let value = labeled.expression.as(StringLiteralExprSyntax.self) else {
                        throw HasLoggerMacroError.invalidArgumentType(labeled.expression.syntaxNodeType)
                    }

                    subsystem = value
                case "category":
                    guard let value = labeled.expression.as(StringLiteralExprSyntax.self) else {
                        throw HasLoggerMacroError.invalidArgumentType(labeled.expression.syntaxNodeType)
                    }

                    category = value
                default:
                    continue
            }
        }

        return (subsystem, category)
    }

    private static func handleOptionalArgs(
        _ values: OptionalArgs,
        declaration: some DeclGroupSyntax,
        type: some TypeSyntaxProtocol,
        context: some MacroExpansionContext
    ) throws -> Args {
        switch values {
            case let (.some(subsystem), .some(category)):
                (subsystem, category)
            case let (.some(subsystem), nil):
                (subsystem, defaultCategory(type: type))
            case let (nil, .some(category)):
                try (defaultSubsystem(declaration: declaration, context: context), category)
            case (nil, nil):
                try (
                    defaultSubsystem(declaration: declaration, context: context),
                    defaultCategory(type: type)
                )
        }
    }

    private static func defaultSubsystem(
        declaration: some DeclGroupSyntax,
        context: some MacroExpansionContext
    ) throws -> StringLiteralExprSyntax {
        guard let location = context.location(of: declaration, at: .afterLeadingTrivia, filePathMode: .fileID) else {
            throw HasLoggerMacroError.cannotExtractModuleName
        }

        let components = location.file.description.trimmingCharacters(in: ["\""]).split(separator: "/")
        guard components.count == 2 else {
            throw HasLoggerMacroError.cannotExtractModuleName
        }

        return StringLiteralExprSyntax(content: String(components[0]))
    }

    private static func defaultCategory(type: some TypeSyntaxProtocol) -> StringLiteralExprSyntax {
        StringLiteralExprSyntax(content: "\(type.trimmed)")
    }
}
