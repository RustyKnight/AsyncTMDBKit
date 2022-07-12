//
//  ImageRequestBuilder.swift
//  
//
//  Created by Shane Whitehead on 22/6/2022.
//

import Foundation
import AsyncAlamofireHttpEngineKit
import CoreLib

class ImageRequestBuilder: TMDBRequestBuilder {
    enum Error: Swift.Error {
        case invalidBaseURL(String)
    }
    
    init(
			_ configuration: Configuration,
			path: String,
			size: String = "original",
			progress: NormalizedProgress? = nil
		) throws {
        guard let baseUrl = URL(string: configuration.images.secureBaseUrl) else { throw Error.invalidBaseURL(configuration.images.secureBaseUrl) }
        let targetURL = baseUrl
            .appendingPathComponent(size)
            .appendingPathComponent(path)
        super.init(
					to: targetURL
				)
			
			with { progressValue in
				progress?.value = progressValue
			}
    }
}

