struct TransformFactory {

  static func create(_ strategy: TransformStrategy) -> Transformer {
    let transformer: Transformer

    switch strategy {
    case .fft:
      transformer = FFTTransformer()
    case .yin:
      transformer = YINTransformer()
    default:
      transformer = SimpleTransformer()
    }

    return transformer
  }
}
