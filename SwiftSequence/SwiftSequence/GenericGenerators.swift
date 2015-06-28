public struct BuildGen<T> : GeneratorType {
  private var cur: T
  private let inc: T -> T
  public mutating func next() -> T? {
    defer { cur = inc(cur) }
    return cur
  }
  public init(start: T, inc: T -> T) {
    self.cur = start
    self.inc = inc
  }
}

public struct RollGen<T> : GeneratorType {
  private var cur: T
  private let inc: T -> T
  public mutating func next() -> T? {
    cur = inc(cur)
    return cur
  }
}

public struct RollSeq<T> : LazySequenceType {
  private let start: T
  private let inc  : T -> T
  public func generate() -> RollGen<T> {
    return RollGen(cur: start, inc: inc)
  }
}

public struct IncGenAfter<I : ForwardIndexType> : GeneratorType {
  private var cur: I
  public mutating func next() -> I? {
    return ++cur
  }
}

public struct IncGenAt<I : ForwardIndexType> : GeneratorType {
  private var cur: I
  public mutating func next() -> I? {
    return cur++
  }
}

public struct IncSeqAfter<I : ForwardIndexType> : LazySequenceType {
  private let start: I
  public func generate() -> IncGenAfter<I> {
    return IncGenAfter(cur: start)
  }
}

public struct IncSeqAt<I : ForwardIndexType> : LazySequenceType {
  private let start: I
  public func generate() -> IncGenAt<I> {
    return IncGenAt(cur: start)
  }
}

postfix operator ... {}

public postfix func ... <I : ForwardIndexType>(f: I) -> IncSeqAt   <I> {
  return IncSeqAt(start: f)
}

public postfix func ... <I : BidirectionalIndexType>(f: I) -> IncSeqAfter<I> {
  return IncSeqAfter(start: f.predecessor())
}

public struct StrideForeverGen<T : Strideable> : GeneratorType {
  
  private let strd: T.Stride
  private var cur: T
  
  public mutating func next() -> T? {
    defer { cur = cur.advancedBy(strd) }
    return cur
  }
}

public struct StrideForeverSeq<T : Strideable> : LazySequenceType {
  
  private let strd: T.Stride
  private let strt: T
  
  public func generate() -> StrideForeverGen<T> {
    return StrideForeverGen(strd: strd, cur: strt)
  }
  
}

/// Returns a stride sequence without an end

public func stride<T : Strideable>(from: T, by: T.Stride) -> StrideForeverSeq<T> {
  return StrideForeverSeq(strd: by, strt: from)
}

/// Returns an infinite LazySequenceType generated by repeatedly applying `transform` to
/// `start`
/// ```swift
/// iterate(2) { $0 * 2 }
/// 2, 4, 8, 16, 32, 64...
/// ```
public func iterate<T>(start: T, transform: T->T) -> RollSeq<T> {
  return RollSeq(start: start, inc: transform)
}