//
//  SkyllService.swift
//  KwuikAI
//
//  Created by Ringo Wathelet on 2026/05/09.
//
import Foundation
import SwiftSkyllKit


@MainActor
final class SkyllService {
    static let shared = SkyllService()

    private let client: SkyllClient
    
    var error: Error?

    private init(client: SkyllClient = SkyllClient()) {
        self.client = client
    }

    func searchSkills(query: String, limit: Int = 10) async throws -> [SkillModel] {
        var theSkills: [SkillModel] = []
        error = nil
        do {
            let skylls = try await client.searchSkills(
                query: query,
                limit: limit,
                includeContent: true,
                includeReferences: false
            )
            theSkills = skylls.map{
                let markdown = $0.rawContent ?? $0.content ?? ""
                return SkillModel(name: $0.title, skill: markdown)
            }
        } catch let error as SkyllError {
            switch error {
                case let .serverError(_, response): print("Skyll API error: \(response.message)")
                default: print(error.localizedDescription)
            }
        } catch {
            print(error.localizedDescription)
            self.error = error
        }
        return theSkills
    }
 
}


