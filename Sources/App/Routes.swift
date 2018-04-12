import Foundation
import Routing
import Vapor
import MLBAPI

public func routes(_ router: Router) throws {

    router.get("/") { req -> Future<String> in
        let mlbStatsApi = "http://statsapi.mlb.com:80/api/v1/"
        let year = Calendar.current.component(.year, from: Date())
        let endpoint = "standings?leagueId=103,104&season=\(year)"

        return try req.make(Client.self)
            .get(mlbStatsApi + endpoint)
            .flatMap(to: String.self) { res in
                
                return try res.content.decode(StandingsResponse.self)
                    .map(to: String.self) { standingsRes in
                        let teams = standingsRes.divisions.flatMap { $0.teams }
                        let records = teams.map { team in
                            return (team.team.name, team.wins, team.losses)
                        }
                        return records.reduce("") { str, record in
                            return str + "\(record.0): \(record.1) - \(record.2)\n"
                        }
                    }
            }
    }
}
