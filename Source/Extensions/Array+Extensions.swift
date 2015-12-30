extension Array where Element:Comparable {

  static func fromUnsafePointer(data: UnsafePointer<Element>, count: Int) -> [Element] {
    let buffer = UnsafeBufferPointer(start: data, count: count);
    return Array(buffer)
  }

  var maxIndex: Int? {
    return self.enumerate().maxElement({$1.element > $0.element})?.index
  }
}
