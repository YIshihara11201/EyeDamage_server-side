//
//  SmartphoneTimeController.swift
//  
//
//  Created by Yusuke Ishihara on 2022-11-25.
//

import Vapor
import Fluent
import APNS

struct SmartphoneTimeController {
	func create(req: Request) async throws -> HTTPStatus {
		let smartphoneTime = try req.content.decode(SmartphoneTime.self)
		if let lastRecordForSameDay = try await SmartphoneTime.query(on: req.db)
			.filter(\.$deviceId == smartphoneTime.deviceId)
			.filter(\.$recordDate == smartphoneTime.recordDate)
			.sort(SmartphoneTime.self, \.$recordDate, .descending)
			.first() {
			
			if lastRecordForSameDay.end != nil { // when last record's end field is empty, ignore it and create new record
				try await smartphoneTime.create(on: req.db)
				return .created
			}
			return .noContent
		} else {
			try await smartphoneTime.create(on: req.db)
			return .created
		}
	}
	
	func update(req: Request) async throws -> HTTPStatus {
		let body = try req.content.decode(SmartphoneTime.self)
		let deviceId = body.deviceId
		let recordDate = body.recordDate
		let endDate = body.end!
		
		guard let target = try await SmartphoneTime.query(on: req.db)
			.filter(\.$deviceId == deviceId)
			.filter(\.$recordDate == recordDate)
			.filter(\.$end == nil)
			.sort(SmartphoneTime.self, \.$start, .descending)
			.first() else { return .notFound }
		target.end = endDate
		try await target.save(on: req.db)
		
		let startDate = target.start!
		let duration = DateInterval(start: startDate, end: endDate)
		guard let report = try await Report.query(on: req.db)
			.filter(\.$deviceId == deviceId)
			.filter(\.$recordDate == recordDate)
			.first() else { return .notFound }
		report.duration += Int(duration.duration)
		try await report.save(on: req.db)
		let updatedDuration = report.duration
		
		guard let token = try await Token.query(on: req.db)
			.filter(\.$deviceId == deviceId)
			.first(),
					let activityToken = token.activityToken else { return .notFound }
		
		return try await notify(req: req, token: activityToken, duration: updatedDuration)
	}
	
	func notify(req: Request, token: String, duration: Int) async throws -> HTTPStatus {
		do {
			try await APNSManager.sendLiveActivityNotification(activityToken: token, client: APNSManager.getClient(), duration: duration, type: .update)
			return .accepted
		} catch {
			print("\(error)")
			return .badRequest
		}
	}
	
}

extension SmartphoneTimeController: RouteCollection {
	func boot(routes: Vapor.RoutesBuilder) throws {
		let phone = routes.grouped("phone")
		phone.post(use: create)
		phone.post("update", use: update)
	}
}

