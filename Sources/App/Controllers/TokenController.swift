//
//  TokenController.swift
//  
//
//  Created by Yusuke Ishihara on 2022-11-25.
//

import Vapor
import Fluent
import APNS

struct TokenController {
	func create(req: Request) async throws -> HTTPStatus {
		let token = try req.content.decode(Token.self)
		
		if let existingToken = try await Token.query(on: req.db)
			.filter(\.$deviceId == token.deviceId)
			.first() {
			
			if let push = token.pushToken {
				existingToken.pushToken = push
			}
			if let activity = token.activityToken {
				existingToken.activityToken = activity
			}
			
			try await existingToken.save(on: req.db)
			return .accepted
		} else {
			try await token.create(on: req.db)
			return .created
		}
	}
}

extension TokenController: RouteCollection {
	func boot(routes: Vapor.RoutesBuilder) throws {
		let tokens = routes.grouped("token")
		tokens.post(use: create)
	}
}

