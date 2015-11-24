import Accelerate

public struct TransformResult {

  public var buffer: [Float]
  public var complexBuffer: DSPSplitComplex?

  // MARK: - Initialization

  public init(buffer: [Float], complexBuffer: DSPSplitComplex? = nil) {
    self.buffer = buffer
    self.complexBuffer = complexBuffer
  }
}
