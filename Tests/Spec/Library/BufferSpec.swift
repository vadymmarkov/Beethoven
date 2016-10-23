@testable import Beethoven
import Quick
import Nimble

class BufferSpec: QuickSpec {

  override func spec() {
    describe("Buffer") {
      var buffer: Buffer!

      beforeEach {
        buffer = Buffer(elements: [0.1, 0.2, 0.3])
      }

      describe("#count") {
        it("returns the count of elements") {
          expect(buffer.count).to(equal(3))
        }
      }
    }
  }
}
