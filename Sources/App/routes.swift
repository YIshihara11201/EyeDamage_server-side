import Vapor
import Fluent

func routes(_ app: Application) throws {
	try app.register(collection: TokenController())
	try app.register(collection: SmartphoneTimeController())
	try app.register(collection: ReportController())
}
