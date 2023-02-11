//
//  Report.swift
//  
//
//  Created by Yusuke Ishihara on 2022-11-26.
//

import Vapor
import Fluent

final class Report: Model {
	static let schema = "reports"
	
	@ID(key: .id) var id: UUID?
	@Field(key: "deviceId") var deviceId: String
	@Field(key: "startDayOfWeek") var startDayOfWeek: Date
	@Field(key: "recordDate") var recordDate: Date
	@Field(key: "duration") var duration: Int
	@Field(key: "debug") var debug: Bool
	
	init() { }
	
	init(deviceId: String, recordDate: Date, startDayOfWeek: Date, debug: Bool) {
		self.deviceId = deviceId
		self.recordDate = recordDate
		self.startDayOfWeek = startDayOfWeek
		self.duration = 0
		self.debug = debug
	}
	
}
