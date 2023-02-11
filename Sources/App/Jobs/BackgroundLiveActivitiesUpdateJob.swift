//
//  BackgroundLiveActivitiesUpdateJob.swift
//  
//
//  Created by Yusuke Ishihara on 2023-01-21.
//

import Vapor
import Fluent
import Queues

struct ActivityInfo: Codable {
	let pushToken: String
}

struct BackgroundLiveActivitiesUpdateJob: AsyncJob {
	typealias Payload = ActivityInfo
	
	func dequeue(_ context: Queues.QueueContext, _ payload: ActivityInfo) async throws {
		try await APNSManager.sendBackgroundNotification(token: payload.pushToken, client: APNSManager.getClient(), activityInfo: payload)
	}
}
