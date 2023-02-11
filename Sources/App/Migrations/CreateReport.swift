//
//  File.swift
//  
//
//  Created by Yusuke Ishihara on 2022-11-26.
//

import Vapor
import Fluent

struct CreateReport: AsyncMigration {
	
	func prepare(on database: Database) async throws {
		try await database.schema(Report.schema)
			.id()
			.field("deviceId", .string, .references("tokens", "deviceId"))
			.field("recordDate", .datetime, .required)
			.field("startDayOfWeek", .datetime, .required)
			.field("duration", .int16, .required)
			.field("debug", .bool, .required)
			.create()
	}
	
	func revert(on database: FluentKit.Database) async throws {
		try await database.schema(Report.schema).delete()
	}
}
