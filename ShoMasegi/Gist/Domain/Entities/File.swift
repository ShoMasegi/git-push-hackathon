import Foundation

public struct File: Decodable {
   public let filename: String
   public let type: String
   public let language: String?
   public let rawUrl: URL
   public let size: Int64
}
