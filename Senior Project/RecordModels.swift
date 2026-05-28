//
//  RecordModels.swift
//  Senior Project
//
//  Created by Zoe Kasules on 11/17/25.
//

import Foundation

struct RecordItem: Identifiable, Hashable {
    let id: UUID = UUID()
    let docId: String
    let subcategoryId: String
    let recordCategoryId: String
    let player: String
    let value: String
    let rank: Int
    let years: String?
    let date: String?
    let opponent: String?

    init(
        docId: String,
        subcategoryId: String,
        recordCategoryId: String,
        player: String,
        value: String,
        rank: Int?,
        years: String?,
        date: String? = nil,
        opponent: String? = nil
    ) {
        self.docId = docId
        self.subcategoryId = subcategoryId
        self.recordCategoryId = recordCategoryId
        self.player = player
        self.value = value
        self.rank = rank ?? 99999
        self.years = years
        self.date = date
        self.opponent = opponent
    }
}
