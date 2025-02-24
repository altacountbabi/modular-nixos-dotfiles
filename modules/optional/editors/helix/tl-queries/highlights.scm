; Keywords
(keyword) @keyword

; Functions
(function_call name: (identifier) @function)

; Identifiers
(function_declaration argument: (identifier) @variable.parameter)
(self) @variable.builtin

; Literals
(comment) @comment
(boolean) @constant.builtin.boolean
(integer) @constant.builtin.numeric.integer
(float) @constant.builtin.numeric.float
(string) @string
(escape_sequence) @constant.character.escape
(interpolation) @punctuation.special

; Operators
(binary_operator) @operator
(comparison_operator) @operator
(logical_operator) @operator
(unary_operator) @operator
(assignment_operator) @operator

; Symbols
(delimiter) @punctuation.delimiter
(parenthesis) @punctuation.bracket
(bracket) @punctuation.bracket
(brace) @punctuation.bracket

