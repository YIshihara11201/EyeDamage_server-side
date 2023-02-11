//
//  SmartphoneTime.swift
//  
//
//  Created by Yusuke Ishihara on 2022-11-25.
//

import Vapor
import Fluent

final class SmartphoneTime: Model {
	static let schema = "smartphoneTime"
	
	@ID(key: .id) var id: UUID?
	@Field(key: "deviceId") var deviceId: String
	@Field(key: "recordDate") var recordDate: Date
	@OptionalField(key: "start") var start: Date?
	@OptionalField(key: "end") var end: Date?
	@Field(key: "debug") var debug: Bool
	
	init() { }
	
	init(deviceId: String, recordDate: Date, start: Date? = nil, end: Date? = nil, debug: Bool) {
		self.deviceId = deviceId
		self.recordDate = recordDate
		self.start = start
		self.end = end
		self.debug = debug
	}
}

