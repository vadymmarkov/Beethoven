struct EstimationFactory {

  static func create(strategy: EstimationStrategy) -> Estimator {
    let estimator: Estimator

    switch strategy {
    case .Quadradic:
      estimator = QuadradicEstimator()
    case .Barycentric:
      estimator = BarycentricEstimator()
    case .QuinnsFirst:
      estimator = QuinnsFirstEstimator()
    case .QuinnsSecond:
      estimator = QuinnsSecondEstimator()
    case .Jains:
      estimator = JainsEstimator()
    case .HPS:
      estimator = HPSEstimator()
    default:
      estimator = MaxValueEstimator()
    }

    return estimator
  }
}
