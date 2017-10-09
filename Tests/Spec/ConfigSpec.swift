@testable import Beethoven
import Quick
import Nimble

final class ConfigSpec: QuickSpec {
  override func spec() {
    describe("Config") {
      var config: Config!

      describe("#init") {
        it("sets default values") {
          config = Config()

          expect(config.bufferSize).to(equal(4096))
          expect(config.estimationStrategy).to(equal(EstimationStrategy.yin))
          expect(config.audioUrl).to(beNil())
        }
      }
    }
  }
}
