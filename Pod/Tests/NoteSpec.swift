import Quick
import Nimble

class NoteSpec: QuickSpec {

  override func spec() {
    describe("Note") {
      describe(".values") {
        
        it("returns an array of 12 notes") {
          let notes = Note.values
          expect(notes.count).to(equal(12))
        }

        it("returns an array of notes in the correct order") {
          let notes = Note.values
          expect(notes[0]).to(equal(Note.A))
          expect(notes[1]).to(equal(Note.ASharp))
          expect(notes[2]).to(equal(Note.B))
          expect(notes[3]).to(equal(Note.C))
          expect(notes[4]).to(equal(Note.CSharp))
          expect(notes[5]).to(equal(Note.D))
          expect(notes[6]).to(equal(Note.DSharp))
          expect(notes[7]).to(equal(Note.E))
          expect(notes[8]).to(equal(Note.F))
          expect(notes[9]).to(equal(Note.FSharp))
          expect(notes[10]).to(equal(Note.G))
          expect(notes[11]).to(equal(Note.GSharp))
        }
      }
    }
  }
}
