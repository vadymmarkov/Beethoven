@testable import Beethoven
import Quick
import Nimble
import Accelerate

final class FFTTransformerSpec: QuickSpec {
  override func spec() {
    describe("FFTTransformer") {
      var transformer: FFTTransformer!

      beforeEach {
        transformer = FFTTransformer()
      }

      describe("#sqrtq") {
        it("returns the array's square") {
          let array: [Float] = [0.1, 0.2, 0.3]
          var expected = [Float](repeating: 0.0, count: array.count)
          vvsqrtf(&expected, array, [Int32(array.count)])

          expect(transformer.sqrtq(array)).to(equal(expected))
        }
      }
    }
  }
}
