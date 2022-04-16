//
//  ParseHelper.swift
//  AudioLearning
//
//  Created by Han Chen on 2019/8/29.
//  Copyright © 2019 cshan. All rights reserved.
//

import SwiftSoup

protocol ParseHelperProtocol {
    func parseHtmlToEpisodeModels(by htmlString: String, urlString: String) -> [EpisodeRealm]
    func parseHtmlToEpisodeDetailModel(by htmlString: String, urlString: String, episode: String) -> EpisodeDetailRealm?
}

enum HtmlQuery: String {
    case smTopItem = "[data-widget-index=\"4\"]"
    case smList = "[data-widget-index=\"5\"] li.course-content-item"
    case smEpisode = "div.details > h3 > b"
    case smTitle = "div.text > h2 > a"
    case smDesc = "div.details > p"
    case smEpisodeAndDate = "div.details > h3"
    case smImg = "img"
    case smSrc = "src"
    case smHref = "href"
    case smScript = "div.6 > div.text"
    case smAudioLink = "a.bbcle-download-extension-mp3"
    case smUl = "ul"
}

final class ParseSixMinutesHelper: ParseHelperProtocol {

    func parseHtmlToEpisodeModels(by htmlString: String, urlString: String) -> [EpisodeRealm] {
        guard let document = try? SwiftSoup.parse(htmlString, urlString) else { return [] }
        var episodeModels = getListToEpisodeModels(from: document)
        if let episodeModel = getTopItemToEpisodeModels(from: document) {
            episodeModels.insert(episodeModel, at: 0)
        }
        return episodeModels
    }

    func parseHtmlToEpisodeDetailModel(
        by htmlString: String,
        urlString: String,
        episode: String
    ) -> EpisodeDetailRealm? {
        guard let document = try? SwiftSoup.parse(htmlString, urlString) else { return nil }
        let model = EpisodeDetailRealm()
        model.episode = episode
        model.path = urlString
        model.scriptHtml = getScriptHtml(by: document)
        model.audioLink = getAudioLink(by: document)
        return model
    }
}

extension ParseSixMinutesHelper {

    // MARK: List

    private func getTopItemToEpisodeModels(from document: Document) -> EpisodeRealm? {
        guard let elements = try? document.select(HtmlQuery.smTopItem.rawValue),
              let element = elements.first() else { return nil }
        let model = EpisodeRealm()
        model.episode = getEpisode(by: element)
        model.title = getTitle(by: element)
        model.desc = getDesc(by: element)
        model.date = getDate(by: element)?.toDate(dateFormat: "dd MMM yyyy")
        model.imagePath = getImagePath(by: element)
        model.path = getPath(by: element)
        return model
    }

    private func getListToEpisodeModels(from document: Document) -> [EpisodeRealm] {
        guard let elements = try? document.select(HtmlQuery.smList.rawValue) else { return [] }
        return elements.map { element -> EpisodeRealm in
            let model = EpisodeRealm()
            model.episode = getEpisode(by: element)
            model.title = getTitle(by: element)
            model.desc = getDesc(by: element)
            model.date = getDate(by: element)?.toDate(dateFormat: "dd MMM yyyy")
            model.imagePath = getImagePath(by: element)
            model.path = getPath(by: element)
            return model
        }
    }

    func getEpisode(by listElement: Element) -> String? {
        guard let episodes = try? listElement.select(HtmlQuery.smEpisode.rawValue),
              let episode = episodes.first(),
              let text = try? episode.text() else { return nil }
        return text.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func getTitle(by listElement: Element) -> String? {
        guard let links = try? listElement.select(HtmlQuery.smTitle.rawValue),
              let link = links.first(),
              let title = try? link.text() else { return nil }
        return title.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func getDesc(by listElement: Element) -> String? {
        guard let details = try? listElement.select(HtmlQuery.smDesc.rawValue),
              let detail = details.first(),
              let desc = try? detail.text() else { return nil }
        return desc.trimmingCharacters(in: .whitespaces)
    }

    func getDate(by listElement: Element) -> String? {
        guard let episodeAndDates = try? listElement.select(HtmlQuery.smEpisodeAndDate.rawValue),
              let episodeAndDate = episodeAndDates.first(),
              let episodes = try? listElement.select(HtmlQuery.smEpisode.rawValue),
              let episode = episodes.first() else { return nil }
        try? episodeAndDate.removeChild(episode)
        guard let date = try? episodeAndDate.text() else { return nil }
        return date.replacingOccurrences(of: "/", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func getImagePath(by listElement: Element) -> String? {
        guard let imgs = try? listElement.select(HtmlQuery.smImg.rawValue),
              let img = imgs.first(),
              let src = try? img.attr(HtmlQuery.smSrc.rawValue) else { return nil }
        return src.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func getPath(by listElement: Element) -> String? {
        guard let links = try? listElement.select(HtmlQuery.smTitle.rawValue),
              let link = links.first(),
              let href = try? link.attr(HtmlQuery.smHref.rawValue) else { return nil }
        return href.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

extension ParseSixMinutesHelper {

    // MARK: Detail

    func getScriptHtml(by document: Document) -> String? {
        guard let scripts = try? document.select(HtmlQuery.smScript.rawValue),
              let script = scripts.first() else { return nil }
        if let ulNodes = try? script.select(HtmlQuery.smUl.rawValue), let ulNode = ulNodes.first() {
            try? script.removeChild(ulNode)
        }
        guard let html = try? script.html() else { return nil }
        return html
    }

    func getAudioLink(by document: Document) -> String? {
        guard let links = try? document.select(HtmlQuery.smAudioLink.rawValue),
              let link = links.first(),
              let href = try? link.attr(HtmlQuery.smHref.rawValue) else { return nil }
        return href.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
