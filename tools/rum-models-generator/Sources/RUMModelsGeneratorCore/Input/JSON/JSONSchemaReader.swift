/*
* Unless explicitly stated otherwise all files in this repository are licensed under the Apache License Version 2.0.
* This product includes software developed at Datadog (https://www.datadoghq.com/).
* Copyright 2019-2020 Datadog, Inc.
*/

import Foundation

/// Reads `JSONSchema` from file.
internal class JSONSchemaReader {
    private let jsonDecoder = JSONDecoder()

    func readJSONSchema(
        from schemaFile: File,
        resolvingAgainst referencedSchemaFiles: [File] = []
    ) throws -> JSONSchema {
        let schema = try jsonDecoder.decode(JSONSchema.self, from: schemaFile.content)
        let referencedSchemas = try referencedSchemaFiles
            .map { try jsonDecoder.decode(JSONSchema.self, from: $0.content) }

        // Resolve references to other schemas
        try referencedSchemas.forEach { try schema.resolveReference(to: $0) }

        // Resolve subschemas
        schema.resolveSubschemas()

        return schema
    }
}
