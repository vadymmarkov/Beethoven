public enum Note: String {
  case C = "C"
  case CSharp = "C#"
  case D = "D"
  case DSharp = "D#"
  case E = "E"
  case F = "F"
  case FSharp = "F#"
  case G = "G"
  case GSharp = "G#"
  case A = "A"
  case ASharp = "A#"
  case B = "B"

  public static var values = [
    A, ASharp, B, C, CSharp, D,
    DSharp, E, F, FSharp, G, GSharp
  ]
}