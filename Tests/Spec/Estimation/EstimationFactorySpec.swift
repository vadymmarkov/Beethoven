@testable import Beethoven
import Quick
import Nimble

final class EstimationFactorySpec: QuickSpec {
  override func spec() {
    describe("EstimationFactory") {
      let factory = EstimationFactory()

      describe(".create") {
        it("creates QuadradicEstimator") {
          expect(factory.create(.quadradic) is QuadradicEstimator).to(beTrue())
        }

        it("creates Barycentric") {
          expect(factory.create(.barycentric) is BarycentricEstimator).to(beTrue())
        }

        it("creates QuinnsFirst") {
          expect(factory.create(.quinnsFirst) is QuinnsFirstEstimator).to(beTrue())
        }

        it("creates QuinnsSecond") {
          expect(factory.create(.quinnsSecond) is QuinnsSecondEstimator).to(beTrue())
        }

        it("creates Jains") {
          expect(factory.create(.jains) is JainsEstimator).to(beTrue())
        }

        it("creates HPS") {
          expect(factory.create(.hps) is HPSEstimator).to(beTrue())
        }

        it("creates YIN") {
          expect(factory.create(.yin) is YINEstimator).to(beTrue())
        }

        it("creates MaxValue") {
          expect(factory.create(.maxValue) is MaxValueEstimator).to(beTrue())
        }
      }
    }
  }
}
