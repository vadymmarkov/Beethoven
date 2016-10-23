@testable import Beethoven
import Quick
import Nimble

class EstimationFactorySpec: QuickSpec {

  override func spec() {
    describe("EstimationFactory") {
      describe(".create") {
        it("creates QuadradicEstimator") {
          expect(EstimationFactory.create(.quadradic) is QuadradicEstimator).to(beTrue())
        }

        it("creates Barycentric") {
          expect(EstimationFactory.create(.barycentric) is BarycentricEstimator).to(beTrue())
        }

        it("creates QuinnsFirst") {
          expect(EstimationFactory.create(.quinnsFirst) is QuinnsFirstEstimator).to(beTrue())
        }

        it("creates QuinnsSecond") {
          expect(EstimationFactory.create(.quinnsSecond) is QuinnsSecondEstimator).to(beTrue())
        }

        it("creates Jains") {
          expect(EstimationFactory.create(.jains) is JainsEstimator).to(beTrue())
        }

        it("creates HPS") {
          expect(EstimationFactory.create(.hps) is HPSEstimator).to(beTrue())
        }

        it("creates YIN") {
          expect(EstimationFactory.create(.yin) is YINEstimator).to(beTrue())
        }

        it("creates MaxValue") {
          expect(EstimationFactory.create(.maxValue) is MaxValueEstimator).to(beTrue())
        }
      }
    }
  }
}
