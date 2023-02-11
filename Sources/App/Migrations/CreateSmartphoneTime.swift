//
//  CreateSmartphoneTime.swift
//  
//
//  Created by Yusuke Ishihara on 2022-11-25.
//

import Vapor
import Fluent

struct CreateSmartphoneTime: AsyncMigration {
	
	func prepare(on database: Database) async throws {
		try await database.schema(SmartphoneTime.schema)
			.id()
			.field("deviceId", .string, .references("tokens", "deviceId"))
			.field("recordDate", .datetime, .required)
			.field("start", .datetime)
			.field("end", .datetime)
			.field("debug", .bool, .required)
			.create()
	}
	
	func revert(on database: FluentKit.Database) async throws {
		try await database.schema(SmartphoneTime.schema).delete()
	}
}
