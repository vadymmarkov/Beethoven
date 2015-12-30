@testable import Beethoven
import Quick
import Nimble

class EstimationFactorySpec: QuickSpec {

  override func spec() {
    describe("EstimationFactory") {
      describe(".create") {
        it("creates QuadradicEstimator") {
          expect(EstimationFactory.create(.Quadradic) is QuadradicEstimator).to(beTrue())
        }

        it("creates Barycentric") {
          expect(EstimationFactory.create(.Barycentric) is BarycentricEstimator).to(beTrue())
        }

        it("creates QuinnsFirst") {
          expect(EstimationFactory.create(.QuinnsFirst) is QuinnsFirstEstimator).to(beTrue())
        }

        it("creates QuinnsSecond") {
          expect(EstimationFactory.create(.QuinnsSecond) is QuinnsSecondEstimator).to(beTrue())
        }

        it("creates Jains") {
          expect(EstimationFactory.create(.Jains) is JainsEstimator).to(beTrue())
        }

        it("creates HPS") {
          expect(EstimationFactory.create(.HPS) is HPSEstimator).to(beTrue())
        }

        it("creates MaxValue") {
          expect(EstimationFactory.create(.MaxValue) is MaxValueEstimator).to(beTrue())
        }
      }
    }
  }
}
