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
    let index = n < 0 ? 12 - abs(n) % 12 : n % 12

    self.note = Note.values[index]
    self.octave = n < 0
      ? Base.octave - (abs(n) + 2) / 12
      : Base.octave + (n + 9) / 12
  }
}
