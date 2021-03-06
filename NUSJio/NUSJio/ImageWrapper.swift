//
//  ImageWrapper.swift
//  NUSJio
//
//  Created by Zeling Long on 2020/6/16.
//  Copyright © 2020 Zeling Long. All rights reserved.
//

import Foundation

public struct ImageWrapper: Codable {
public let image: Image

public enum CodingKeys: String, CodingKey {
  case image
}

// Image is a standard UI/NSImage conditional typealias
public init(image: Image) {
  self.image = image
}

public init(from decoder: Decoder) throws {
  let container = try decoder.container(keyedBy: CodingKeys.self)
  let data = try container.decode(Data.self, forKey: CodingKeys.image)
  guard let image = Image(data: data) else {
    throw StorageError.decodingFailed
  }

  self.image = image
}

// cache_toData() wraps UIImagePNG/JPEGRepresentation around some conditional logic with some whipped cream and sprinkles.
public func encode(to encoder: Encoder) throws {
  var container = encoder.container(keyedBy: CodingKeys.self)
  guard let data = image.cache_toData() else {
      throw StorageError.encodingFailed
  }

  try container.encode(data, forKey: CodingKeys.image)
}

