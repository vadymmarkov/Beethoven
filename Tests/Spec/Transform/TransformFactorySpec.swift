@testable import Beethoven
import Quick
import Nimble

class TransformFactorySpec: QuickSpec {

  override func spec() {
    describe("TransformFactory") {
      describe(".create") {
        it("creates FFTTransformer") {
          expect(TransformFactory.create(.FFT) is FFTTransformer).to(beTrue())
        }

        it("creates SimpleTransformer") {
          expect(TransformFactory.create(.Simple) is SimpleTransformer).to(beTrue())
        }
      }
    }
  }
}
