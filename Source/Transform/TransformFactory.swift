struct TransformFactory {

  static func create(strategy: TransformStrategy) -> Transformer {
    let estimator: Transformer

    switch strategy {
    case .FFT:
      estimator = FFTTransformer()
    default:
      estimator = SimpleTransformer()
    }

    return estimator
  }
}
