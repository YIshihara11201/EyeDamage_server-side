import Vapor
import Fluent
import FluentPostgresDriver
import Queues
import QueuesRedisDriver

public func configure(_ app: Application) throws {
	
	configureDecoder()
	try configureDatabase(for: app)
	handleMigration(for: app)
	try configureJobQueue(for: app)
	
	app.http.server.configuration.hostname = "0.0.0.0"
	if let port = Environment.get("PORT").flatMap(Int.init(_:)) {
		app.http.server.configuration.port = port
	}
	
	try routes(app)
}

func handleMigration(for app: Application) {
	app.migrations.add(CreateToken())
	app.migrations.add(CreateSmartphoneTime())
	app.migrations.add(CreateReport())
	try! app.autoMigrate().wait()
}

func configureDatabase(for app: Application) throws {
	if let databaseURL = Environment.get("DATABASE_URL"),
	   var postgresConfig = PostgresConfiguration(url: databaseURL) {
		app.logger.debug("remote db")
		
		postgresConfig.tlsConfiguration = .makeClientConfiguration()
		postgresConfig.tlsConfiguration?.certificateVerification = .none
		app.databases.use(.postgres(configuration: postgresConfig), as: .psql)
	} else {
		app.logger.debug("local db")
		
		app.databases.use(.postgres(
			hostname: Environment.get("DATABASE_HOST") ?? "localhost",
			port: 5432,
			username: Environment.get("DATABASE_USERNAME") ?? "vapor_username",
			password: Environment.get("DATABASE_PASSWORD") ?? "vapor_password",
			database: Environment.get("DATABASE_NAME") ?? "vapor_database"
		), as: .psql)
	}
}

func configureJobQueue(for app: Application) throws {
	var redisConfig: RedisConfiguration
	
	if let url = Environment.get("REDIS_URL") {
		app.logger.debug("remote redis")
		redisConfig = try RedisConfiguration(url: url)
	} else {
		app.logger.debug("local redis")
		redisConfig = try RedisConfiguration(hostname: "redis")
	}
	
	redisConfig.pool.connectionRetryTimeout = .hours(12)
	app.queues.use(.redis(redisConfig))
	
	let backgroundLiveActivityUpdateJob = BackgroundLiveActivitiesUpdateJob()
	app.queues.add(backgroundLiveActivityUpdateJob)
	try app.queues.startInProcessJobs()
	
}

func configureDecoder() {
	let decoder = JSONDecoder()
	decoder.keyDecodingStrategy = .convertFromSnakeCase
	decoder.dateDecodingStrategy = .iso8601
	let encoder = JSONEncoder()
	encoder.dateEncodingStrategy = .iso8601
	ContentConfiguration.global.use(decoder: decoder, for: .json)
	ContentConfiguration.global.use(encoder: encoder, for: .json)
}
