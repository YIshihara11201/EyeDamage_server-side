//
//  ReportController.swift
//  
//
//  Created by Yusuke Ishihara on 2022-11-26.
//

import Vapor
import Fluent
import Queues

struct ReportController {
	
	func create(req: Request) async throws -> HTTPStatus {
		
		let record = try req.content.decode(Report.self)
		if try await Report.query(on: req.db)
			.filter(\.$deviceId == record.deviceId)
			.filter(\.$recordDate == record.recordDate)
			.count() == 0 {
			try await record.create(on: req.db)
			
			// schedule LiveActivity terminate job 7h+55min after sleep-start-time (to avoid LiveActivity display time from being 0)
			let currDate = Date()
			var liveActivityEndTime = Calendar.current.date(byAdding: .hour, value: 7, to: currDate)!
			liveActivityEndTime = Calendar.current.date(byAdding: .minute, value: 55, to: liveActivityEndTime)!
			
			guard let pushToken = try await Token.query(on: req.db)
				.filter(\.$deviceId == record.deviceId)
				.first()?.pushToken else { return .notFound }
			
			let activityInfo = ActivityInfo(pushToken: pushToken)
			
			try await dispathLiveActivityEndJob(queue: req.queue, activityInfo: activityInfo, dispatchDate: liveActivityEndTime)
			
			return .created
		}
		
		return .badRequest
	}
	
	func read(req: Request) async throws -> DailyReportResponse {
		let reqContent = try req.content.decode(DailyReportRequest.self)
		let deviceId = reqContent.deviceId
		let recordDate = reqContent.recordDate
		
		guard let report = try await Report.query(on: req.db)
			.filter(\.$deviceId == deviceId)
			.filter(\.$recordDate == recordDate)
			.first() else { throw Abort(.notFound) }
		
		let weekDayNumber = Calendar.current.dateComponents([.weekday], from: report.recordDate).weekday!
		let weekDay = try WeekDay.numToCase(num: weekDayNumber)
		
		return DailyReportResponse(startDayOfWeek: report.startDayOfWeek, weekDay: weekDay, duration: report.duration)
	}
	
}

extension ReportController: RouteCollection {
	func boot(routes: Vapor.RoutesBuilder) throws {
		let reports = routes.grouped("report")
		reports.post(use: create)
		reports.post("daily", use: read)
	}
}

extension ReportController {
	
	func dispathLiveActivityEndJob(queue: Queue, activityInfo: ActivityInfo, dispatchDate: Date) async throws {
		try await queue.dispatch(
			BackgroundLiveActivitiesUpdateJob.self,
			activityInfo,
			delayUntil: dispatchDate
		)
	}
	
}
