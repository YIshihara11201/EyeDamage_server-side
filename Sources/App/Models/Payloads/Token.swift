//
//  Token.swift
//  
//
//  Created by Yusuke Ishihara on 2022-11-25.
//

import Vapor
import Fluent

final class Token: Model {
	static let schema = "tokens"
	
	@ID(key: .id) var id: UUID?
	@Field(key: "deviceId") var deviceId: String
	@Field(key: "pushToken") var pushToken: String?
	@Field(key: "activityToken") var activityToken: String?
	@Field(key: "debug") var debug: Bool
	
	init() { }
	
	init(deviceId: String, pushToken: String?, activityToken: String?, debug: Bool) {
		self.deviceId = deviceId
		self.pushToken = pushToken
		self.activityToken = activityToken
		self.debug = debug
	}
	
}
