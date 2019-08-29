//
//  ParseHelper.swift
//  AudioLearning
//
//  Created by Han Chen on 2019/8/29.
//  Copyright © 2019 cshan. All rights reserved.
//

import SwiftSoup

protocol ParseHelperProtocol {
    func parseHtmlToEpisodeModels(by htmlString: String, urlString: String) -> [EpisodeModel]
}

class ParseSixMinutesHelper: ParseHelperProtocol {
    
    func parseHtmlToEpisodeModels(by htmlString: String, urlString: String) -> [EpisodeModel] {
        guard let document = try? SwiftSoup.parse(htmlString, urlString) else { return [] }
        var episodeModels = getCourseContentItemToEpisodeModels(from: document)
        if let episodeModel = getTopCourseContentItemToEpisodeModels(from: document) {
            episodeModels.insert(episodeModel, at: 0)
        }
        return episodeModels
    }
    
    private func getTopCourseContentItemToEpisodeModels(from document: Document) -> EpisodeModel? {
        guard let elements = try? document.select("[data-widget-index=\"4\"]"),
            let element = elements.first() else { return nil }
        let episode = getEpisode(by: element)
        let title = getTitle(by: element)
        let desc = getDesc(by: element)
        let date = getDate(by: element)
        let imagePath = getImagePath(by: element)
        let link = getLink(by: element)
        return EpisodeModel(episode: episode,
                            title: title,
                            desc: desc,
                            date: date?.toDate(dateFormat: "dd MMM yyyy"),
                            imagePath: imagePath,
                            link: link)
    }
    
    private func getCourseContentItemToEpisodeModels(from document: Document) -> [EpisodeModel] {
        guard let elements = try? document.select("[data-widget-index=\"5\"] li.course-content-item") else { return [] }
        return elements.map({ (element) -> EpisodeModel in
            let episode = getEpisode(by: element)
            let title = getTitle(by: element)
            let desc = getDesc(by: element)
            let date = getDate(by: element)
            let imagePath = getImagePath(by: element)
            let link = getLink(by: element)
            return EpisodeModel(episode: episode,
                                title: title,
                                desc: desc,
                                date: date?.toDate(dateFormat: "dd MMM yyyy"),
                                imagePath: imagePath,
                                link: link)
        })
    }
    
    func getEpisode(by listElement: Element) -> String? {
        guard let episodes = try? listElement.select("div.details > h3 > b"),
            let episode = episodes.first(),
            let text = try? episode.text() else { return nil }
        return text.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func getTitle(by listElement: Element) -> String? {
        guard let links = try? listElement.select("div.text > h2 > a"),
            let link = links.first(),
            let title = try? link.text() else { return nil }
        return title.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func getDesc(by listElement: Element) -> String? {
        guard let details = try? listElement.select("div.details > p"),
            let detail = details.first(),
            let desc = try? detail.text() else { return nil }
        return desc.trimmingCharacters(in: .whitespaces)
    }
    
    func getDate(by listElement: Element) -> String? {
        guard let episodeAndDates = try? listElement.select("div.details > h3"),
            let episodeAndDate = episodeAndDates.first(),
            let episodes = try? listElement.select("div.details > h3 > b"),
            let episode = episodes.first() else {
                return nil
        }
        try? episodeAndDate.removeChild(episode)
        guard let date = try? episodeAndDate.text() else { return nil }
        return date.replacingOccurrences(of: "/", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func getImagePath(by listElement: Element) -> String? {
        guard let imgs = try? listElement.select("img"),
            let img = imgs.first(),
            let src = try? img.attr("src") else { return nil }
        return src.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func getLink(by listElement: Element) -> String? {
        guard let links = try? listElement.select("div.text > h2 > a"),
            let link = links.first(),
            let href = try? link.attr("href") else { return nil }
        return href.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
