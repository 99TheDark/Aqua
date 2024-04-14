import types

const 
  Accessive* = [
    Dot,
    DoubleColon,
    OptionalChain,
  ]
  
  Exponentiative* = [
    Exponentiation,
  ]

  Multiplicative* = [
    Multiplication,
    Division,
    Modulo,
    WrappedMultiplication,
  ]

  Additive* = [
    Addition,
    Subtraction,
    WrappedAddition,
    WrappedSubtraction,
  ]

  Shifting* = [
    RightShift,
    LeftShift,
    ZeroFillRightShift,
    WrappedLeftShift,
  ]

  Logical* = [
    And,
    Or,
    Nand,
    Nor,
    Xand,
    Xor,
    Nullish,
  ]

  Comparative* = [
    Equal,
    NotEqual,
    GreaterThan,
    LessThan,
    GreaterThanOrEqual,
    LessThanOrEqual,
  ]
  
  Prefixing* = [
    Not,
    CountLeadingZeroes,
    CountTrailingZeroes,
  ]