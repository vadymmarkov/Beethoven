struct TransformFactory {

  static func create(strategy: TransformStrategy) -> TransformAware {
    let estimator: TransformAware

    switch strategy {
    case .FFT:
      estimator = FFTTransformer()
    default:
      estimator = SimpleTransformer()
    }

    return estimator
  }
}
