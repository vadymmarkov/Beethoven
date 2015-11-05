import Foundation

public struct Pitch {

  public struct Base {
    public static let frequency: Float = 440
    public static let octave = 4
  }

  public var note: Note
  public var octave: Int

  // MARK: - Initializers

  public init(note: Note, octave: Int) {
    self.note = note
    self.octave = octave
  }

  public init(frequency: Float) {
    let n = Int(round(12 * log2(frequency / Base.frequency)))
    self.note = Note.values[n % 12]
    self.octave = n / 12 + Base.octave
  }
}