//
//  APNSManager.swift
//  
//
//  Created by Yusuke Ishihara on 2022-11-27.
//

import Vapor
import APNS

enum APNSError: Error {
	case invalidToken
	case invalidAppStoreKey
	case invalidTeamIdentifier
}

struct APNSManager {
	
	private static func getAuthentication() throws -> APNSClientConfiguration.AuthenticationMethod {
		guard let token = Environment.get("APNS_TOKEN") else { throw APNSError.invalidToken }
		guard let appStoreKey = Environment.get("APPSTORE_KEY") else { throw APNSError.invalidAppStoreKey }
		guard let teamId = Environment.get("TEAM_IDENTIFIER") else { throw APNSError.invalidTeamIdentifier }
		do {
			return APNSClientConfiguration.AuthenticationMethod.jwt(
				privateKey: try .init(pemRepresentation: token),
				keyIdentifier: appStoreKey,
				teamIdentifier: teamId)
		} catch {
			fatalError("\(error)")
		}
	}
	
	static func getClient() throws -> APNSClient<JSONDecoder, JSONEncoder> {
		var environment: APNSClientConfiguration.Environment = .production
#if DEBUG
		environment = .sandbox
#endif
		let client = APNSClient(
			configuration: .init(
				authenticationMethod: try APNSManager.getAuthentication(),
				environment: environment),
			eventLoopGroupProvider: .createNew,
			responseDecoder: JSONDecoder(),
			requestEncoder: JSONEncoder())
		
		return client
	}
	
	static func sendLiveActivityNotification(activityToken: String, client: APNSClient<JSONDecoder, JSONEncoder>, duration: Int, type: APNSLiveActivityNotificationEvent) async throws {
		
		defer {
			do {
				try client.syncShutdown()
			} catch {
				fatalError("\(error)")
			}
		}
		
		try await client.sendLiveActivityNotification(
			.init(
				expiration: .none,
				priority: .immediately,
				appID: "com.yusuke.eyedamageapp",
				contentState: LiveActivityContentState(phoneActiveTime: duration),
				event: type,
				timestamp: Int(Date().timeIntervalSince1970)
			),
			deviceToken: activityToken,
			deadline: .distantFuture
		)
	}
	
	static func sendBackgroundNotification(token: String, client: APNSClient<JSONDecoder, JSONEncoder>, activityInfo: ActivityInfo) async throws {
		
		defer {
			do {
				try client.syncShutdown()
			} catch {
				fatalError("\(error)")
			}
		}
		
		let backgroundNotification = APNSBackgroundNotification(expiration: .none, topic: "com.yusuke.eyedamageapp", payload: activityInfo)
		try await client.sendBackgroundNotification(backgroundNotification, deviceToken: activityInfo.pushToken, deadline: .distantFuture)
	}
}
