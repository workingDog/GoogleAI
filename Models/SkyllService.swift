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
    
    var isLoading: Bool = false
    var error: Error?

    private init(client: SkyllClient = SkyllClient()) {
        self.client = client
    }

    func searchSkills(query: String, limit: Int = 10) async throws -> [SkillModel] {
        var theSkills: [SkillModel] = []
        isLoading = true
        error = nil
        do {
            let skylls = try await client.searchSkills(
                query: query,
                limit: limit,
                includeContent: true,
                includeReferences: false
            )
            theSkills = skylls.map{ SkillModel(name: $0.title, skill: $0.content ?? "") }
        } catch let error as SkyllError {
            switch error {
                case let .serverError(_, response): print("Skyll API error: \(response.message)")
                default: print(error.localizedDescription)
            }
        } catch {
            print(error.localizedDescription)
            self.error = error
        }
        isLoading = false
        return theSkills
    }
 
}


