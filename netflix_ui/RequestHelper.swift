//
//  RequestHelper.swift
//  netflix_ui
//
//  Created by Alex Murphy on 4/18/17.
//  Copyright © 2017 Alex Murphy. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireSwiftyJSON
import PromiseKit
import SwiftyJSON

struct TVEpisode {
    let title: String
    let year: String
    let season: Int
    let episode: Int
    let runtime: String
    let genre: [String]
    let poster_url: String
    let imdb_rating: Double
    let imdb_id: String
}

struct TVSeries {
    let title: String
    let seasons: [Int:[TVEpisode]]
}

class RequestHelper {
    
//    
//    static func fetchTVSeries(for imdb_id: String) -> Promise<TVSeries> {
//        return Promise { fulfill, reject in
//            var tvEpisodes = [Promise<TVEpisode>]()
//            
//        }
//    }
//    
//    static func fetchTVSeason(for imdb_id: String, with season_total: Int) -> Promise<[String]> {
//        
//    }
    
    static func fetchTVSeasonTotal(for imdb_id: String) -> Promise<Int> {
        return Promise { fulfill, reject in
            Alamofire.request(URL(string: "https://www.omdbapi.com/?i=\(imdb_id)&Season=1")!).responseSwiftyJSON(completionHandler: { response in
                if let season_count = response.result.value?.dictionary?["totalSeasons"]?.intValue {
                    fulfill(season_count)
                }
            })
        }
    }
    
    static func fetchTVEpisode(for imdb_id: String) -> Promise<TVEpisode> {
        return Promise { fulfill, reject in
            let url = URL(string: "https://www.omdbapi.com/?i=\(imdb_id)")!
            Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil)
                .responseSwiftyJSON(completionHandler: { response in
                    if let json = response.result.value?.dictionary {
                        let tvEpisode = TVEpisode(title: json["Title"]?.stringValue ?? "",
                                                  year: json["Year"]?.stringValue ?? "",
                                                  season: json["Season"]?.intValue ?? 0,
                                                  episode: json["Episode"]?.intValue ?? 0,
                                                  runtime: json["Runtime"]?.stringValue ?? "",
                                                  genre: json["Genre"]?.stringValue.components(separatedBy: ", ") ?? [],
                                                  poster_url: json["Poster"]?.stringValue ?? "",
                                                  imdb_rating: json["imdbRating"]?.doubleValue ?? 0,
                                                  imdb_id: json["imdbID"]?.stringValue ?? "")
                        
                        fulfill(tvEpisode)
                    }
                })
        }
    }
}

class TelevisionEpisodeHelper {
    static func getTVEpisodes() {
        _ = firstly {
//                RequestHelper.fetchTVEpisode(for: "tt1829964")
                RequestHelper.fetchTVSeasonTotal(for: "tt0944947")
            }.then { seasonTotal -> Void in
                print(seasonTotal)
        }
    }
}
