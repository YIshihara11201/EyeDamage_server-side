//
//  CreateToken.swift
//  
//
//  Created by Yusuke Ishihara on 2022-11-25.
//

import Vapor
import Fluent

struct CreateToken: AsyncMigration {
	
	func prepare(on database: Database) async throws {
		try await database.schema(Token.schema)
			.id()
			.field("deviceId", .string, .required)
			.field("pushToken", .string)
			.field("activityToken", .string)
			.field("debug", .bool, .required)
			.unique(on: "deviceId")
			.create()
	}
	
	func revert(on database: FluentKit.Database) async throws {
		try await database.schema(Token.schema).delete()
	}
}
