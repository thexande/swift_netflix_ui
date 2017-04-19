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

struct TVEpisodeIntermediate {
    let episode_number: Int
    let imdb_id: String
}

struct TVSeasonIntermediate {
    let season_number: Int
    let episode_intermediates: [TVEpisodeIntermediate]
}

struct TVSeriesIntermediate {
    let series_id: String
    let season_intermediates: [TVSeriesIntermediate]
}

struct TVSeries {
    let title: String
    let seasons: [Int:[TVEpisode]]
}

class RequestHelper {
    
    
//    static func fetchTVSeries(for imdb_id: String) -> Promise<TVSeries> {
//        return Promise { fulfill, reject in
//            
//        }
//    }
    
    static func fetchTVSeasonEpisodeIntermediates(for imdb_show_id: String, with season_number: Int) -> Promise<TVSeasonIntermediate> {
        return Promise { fulfill, reject in
            var intermediateTVSeasonEpisodes = [TVEpisodeIntermediate]()
            Alamofire.request(URL(string: "https://www.omdbapi.com/?i=\(imdb_show_id)&Season=\(season_number)")!)
                .responseSwiftyJSON(completionHandler: { response in
                    print(response.result.value?.dictionary)
                    if let seasonEpisodes = response.result.value?.dictionary?["Episodes"]?.arrayValue {
                        
                        for episode in seasonEpisodes {
                            let episode_value = episode
                            let intermediate = TVEpisodeIntermediate(episode_number: episode_value["Episode"].intValue, imdb_id: episode_value["imdbID"].stringValue)
                            intermediateTVSeasonEpisodes.append(intermediate)
                        }
                        fulfill(TVSeasonIntermediate(season_number: season_number, episode_intermediates: intermediateTVSeasonEpisodes))
                    }
                })
        }
    }
    
    static func fetchAllTVSeasonIntermediates(for imdb_show_id: String, with season_total: Int) -> [Promise<TVSeasonIntermediate>] {
        return Promise { fulfill, reject in
            var seasonIntermediates = [Promise<TVSeasonIntermediate>]()
            for season_index in 1...season_total {
                seasonIntermediates.append(self.fetchTVSeasonEpisodeIntermediates(for: imdb_show_id, with: season_index))
            }
            fulfill(seasonIntermediates)
        }
    }
    
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
        var tvID = "tt0944947"
        _ = firstly {
//                RequestHelper.fetchTVEpisode(for: "tt1829964")
                RequestHelper.fetchTVSeasonTotal(for: tvID)
            }.then { seasonTotal -> Promise<[TVSeasonEpisodeIntermediate]> in
                return RequestHelper.fetchTVSeasonIds(for: tvID, with: seasonTotal)
            }.then { intermediates in
                print(intermediates)
            }
    }
}
