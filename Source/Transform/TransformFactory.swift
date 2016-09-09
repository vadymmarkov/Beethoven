struct TransformFactory {

  static func create(_ strategy: TransformStrategy) -> Transformer {
    let estimator: Transformer

    switch strategy {
    case .fft:
      estimator = FFTTransformer()
    default:
      estimator = SimpleTransformer()
    }

    return estimator
  }
}
