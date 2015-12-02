import Foundation

extension Array where Element:Comparable {

  var maxIndex : Int? {
    return self.enumerate().maxElement({$1.element > $0.element})?.index
  }
}
