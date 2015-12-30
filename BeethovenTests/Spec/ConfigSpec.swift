@testable import Beethoven
import Quick
import Nimble

class ConfigSpec: QuickSpec {

  override func spec() {
    describe("Config") {
      var config: Config!

      describe("#init") {
        it("sets default values") {
          config = Config()

          expect(config.bufferSize).to(equal(4096))
          expect(config.transformStrategy).to(equal(TransformStrategy.FFT))
          expect(config.estimationStrategy).to(equal(EstimationStrategy.HPS))
          expect(config.audioURL).to(beNil())
        }
      }
    }
  }
}
