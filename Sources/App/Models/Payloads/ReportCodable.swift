//
//  DailyReport.swift
//  
//
//  Created by Yusuke Ishihara on 2022-11-30.
//

import Vapor
import Fluent

enum ReportError: Error {
	case invalidDayOfWeek
}

enum WeekDay: String, Codable {
	case sunday = "Sun"
	case monday = "Mon"
	case tuesday = "Tue"
	case wednesday = "Wed"
	case thursday = "Thu"
	case friday = "Fri"
	case saturday = "Sat"
	
	static func numToCase(num: Int) throws -> WeekDay {
		switch num {
		case 1: return .sunday
		case 2: return .monday
		case 3: return .tuesday
		case 4: return .wednesday
		case 5: return .thursday
		case 6: return .friday
		case 7: return .saturday
		default: throw ReportError.invalidDayOfWeek
		}
	}
}

struct WeeklyReportRequest: Content {
	let deviceId: String
	let startDayOfWeek: Date
}

struct DailyReportRequest: Content {
	let deviceId: String
	let recordDate: Date
}

struct DailyReportResponse: Content {
	let startDayOfWeek: Date
	let weekDay: WeekDay
	let duration: Int
}

struct WeeklyReportResponse: Content {
	let reports: [DailyReportResponse]
}
