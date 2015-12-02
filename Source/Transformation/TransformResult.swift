import Accelerate

public struct Buffer {

  public var elements: [Float]
  public var complexElements: DSPSplitComplex?

  // MARK: - Initialization

  public init(elements: [Float], complexElements: DSPSplitComplex? = nil) {
    self.elements = elements
    self.complexElements = complexElements
  }
}
