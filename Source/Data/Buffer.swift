public struct Buffer {

  public var elements: [Float]
  public var realElements: [Float]?
  public var imagElements: [Float]?

  public var count: Int {
    return elements.count
  }

  // MARK: - Initialization

  public init(elements: [Float], realElements: [Float]? = nil, imagElements: [Float]? = nil) {
    self.elements = elements
    self.realElements = realElements
    self.imagElements = imagElements
  }
}
