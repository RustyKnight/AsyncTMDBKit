//
//  TMDBRequestBuilder.swift
//  
//
//  Created by Shane Whitehead on 22/6/2022.
//

import Foundation
import AsyncAlamofireHttpEngineKit
import AsyncHttpEngineKit

class TMDBRequestBuilder: AlamofireHttpRequestBuilder {
    enum AppendToResponse: String {
        case images
        case externalIds = "external_ids"
    }
    
    private var appendToResponse = [AppendToResponse]()
    
    internal func with(queryNamed: String, value: Int) -> Self {
        return with(queryNamed: queryNamed, value: "\(value)")
    }
    
    internal func withOptional(queryNamed: String, value: String?) -> Self {
        if let value = value {
            with(queryNamed: queryNamed, value: value)
        }
        return self
    }
    
    internal func withOptional(queryNamed: String, value: Int?) -> Self {
        if let value = value {
            with(queryNamed: queryNamed, value: "\(value)")
        }
        return self
    }
    
    internal func appendingResponse(_ appendToResponse: AppendToResponse) -> Self {
        self.appendToResponse.append(appendToResponse)
        return self
    }
    
    override func build() throws -> AsyncHttpEngine {
        if !appendToResponse.isEmpty {
            let responses = appendToResponse
                .map { $0.rawValue }
                .joined(separator: ",")
            with(queryNamed: "append_to_response", value: responses)
        }
        return try super.build()
    }
}
