//
//  RecordModels.swift
//  Senior Project
//
//  Created by Zoe Kasules on 11/17/25.
//
import Foundation

struct RecordItem: Identifiable, Hashable {
    let id = UUID()
    let docId: String
    let categoryId: String
    let subcategoryId: String
    let player: String
    let value: String
    let rank: Int
    let date: String?
    let opponent: String?
    let type: String?
    
    init(
        docId: String,
        categoryId: String,
        subcategoryId: String,
        player: String,
        value: String,
        rank: Int?,
        date: String?,
        opponent: String?,
        type: String?
    ) {
        self.docId = docId
        self.categoryId = categoryId
        self.subcategoryId = subcategoryId
        self.player = player
        self.value = value
        self.rank = rank ?? 99999
        self.date = date
        self.opponent = opponent
        self.type = type
    }
}
