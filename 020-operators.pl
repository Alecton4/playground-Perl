#!/usr/bin/env perl
# REF: http://modernperlbooks.com/books/modern_perl_2016/04-perl-operators.html

use 5.034;
use warnings;
use autodie;
use feature 'say';

use Test::More;

# ================================
# Operator Characteristics
# ================================

# Every operator possesses several important characteristics which govern its behavior:
# the number of operands on which it operates,
# its relationship to other operators,
# the contexts it enforces,
# and the syntax it provides.

# ================================
# Operator Characteristics - Precedence
# ================================

# perldoc perlop contains a table of precedence.
# Skim it a few times, but don't bother memorizing it (almost no one does).
# Spend your time simplifying your code where you can.
# Then add parentheses where they clarify.

# In cases where two operators have the same precedence,
# other factors such as associativity (Associativity) and fixity (Fixity) break the tie.

# ================================
# Operator Characteristics - Associativity
# ================================

# If you memorize only the precedence and associativity of the common mathematical operators, you'll be fine.
# Simplify your code and you won't have to memorize other associativities.
# If you can't simplify your code
# (or if you're maintaining code and trying to understand it),
# use the core B::Deparse module to see exactly how Perl handles operator precedence and associativity.

# Run perl -MO=Deparse,-p
# on a snippet of code.
# The -p flag adds extra grouping parentheses which often clarify evaluation order.
# Beware that Perl's optimizer will simplify mathematical operations using constant values.
# If you really need to deparse a complex expression,
# use named variables instead of constant values, as in $x ** $y ** $z.

# ================================
# Operator Characteristics - Arity
# ================================

# The arity of an operator is the number of operands on which it operates.
# A nullary operator operates on zero operands.
# A unary operator operates on one operand.
# A binary operator operates on two operands.
# A trinary operator operates on three operands.
# A listary operator operates on a list of zero or more operands.

# ================================
# Operator Characteristics - Fixity
# ================================

# Perl novices often find confusion between the interaction of listary operators—
# especially function calls—
# and nested expressions.
# Where parentheses usually help, # ??? "Where" should be "While"?
# !!! beware of the parsing complexity of:
# {
#     # probably buggy code
#     say ( 1 + 2 + 3 ) * 4;
# }
# ... which prints the value 6 and (probably) evaluates as a whole to 4
# (the return value of say multiplied by 4).
# Perl's parser happily interprets the parentheses as postcircumfix operators denoting the arguments to say,
# not circumfix parentheses grouping an expression to change precedence.
# Run the following code and see what happens:
{
    say "foo" * 2;
    say ("foo") * 2;
}

# An operator's fixity is its position relative to its operands:
#
#     Infix operators appear between their operands.
#         Most mathematical operators are infix operators,
#         such as the multiplication operator in $length * $width.
#
#     Prefix operators precede their operands. Postfix operators follow their operands.
#         These operators tend to be unary,
#         such as mathematic negation (-$x),
#         boolean negation (!$y),
#         and postfix increment ($z++).
#
#     Circumfix operators surround their operands,
#         as with the anonymous hash constructor ({ ... })
#         and quoting operators (qq[ ... ]).
#
#     Postcircumfix operators follow certain operands and surround others,
#         as seen in hash and array element access ($hash{$x} and $array[$y]).

# ================================
# Operator Types
# ================================

# Perl's operators provide value contexts (Numeric, String, and Boolean Context) to their operands.
# To choose the appropriate operator,
# you must know the values of the operands you provide
# as well as the value you expect to receive.

# ================================
# Operator Types - Numeric Operators
# ================================

# Numeric operators impose numeric contexts on their operands.
# These operators are the standard arithmetic operators of
# addition (+),
# subtraction (-),
# multiplication (*),
# division (/),
# exponentiation (**),
# and modulo (%),
# their in-place variants (+=, -=, *=, /=, **=, and %=),
# and both postfix and prefix auto-decrement (--).

# The auto-increment operator has special string behavior (Special Operators).

# Several comparison operators impose numeric contexts upon their operands.
# These are
# numeric equality (==),
# numeric inequality (!=),
# greater than (>),
# less than (<),
# greater than or equal to (>=),
# less than or equal to (<=),
# and the sort comparison operator (<=>).

# ================================
# Operator Types - String Operators
# ================================

# String operators impose string contexts on their operands.
# These operators are
# positive and negative regular expression binding (=~ and !~, respectively),
# and concatenation (.).

# Several comparison operators impose string contexts upon their operands.
# These are
# string equality (eq),
# string inequality (ne),
# greater than (gt),
# less than (lt),
# greater than or equal to (ge),
# less than or equal to (le),
# and the string sort comparison operator (cmp).

# ================================
# Operator Types - Logical Operators
# ================================

# Logical operators impose a boolean context on their operands.
# These operators are
# &&,
# and,
# ||,
# and or.
# These infix operators all exhibit short-circuiting behavior (Short Circuiting).
# The word forms have lower precedence than the punctuation forms.

# The defined-or operator, //, tests the definedness of its operand.
# Unlike || which tests the truth of its operand,
# // evaluates to a true value even if its operand evaluates to a numeric zero or the empty string.
# This is especially useful for setting default parameter values:
sub name_pet {
    my $name = shift // 'Fluffy';
    ...;
}

# The ternary conditional operator (?:) takes three operands.
# It evaluates the first in boolean context
# and evaluates to the second if the first is true
# and the third otherwise:
{
    my $value      = 1;
    my $truthiness = $value ? 'true' : 'false';
}

# The prefix ! and not operators return the logical opposites of the boolean values of their operands.
# not is a lower precedence version of !.

# The xor operator is an infix operator which evaluates to the exclusive-or of its operands.

# ================================
# Operator Types - Bitwise Operators
# =================================

# Bitwise operators treat their operands numerically at the bit level.
# These uncommon operators are
# left shift (<<),
# right shift (>>),
# bitwise and (&),
# bitwise or (|),
# and bitwise xor (^),
# as well as their in-place variants (<<=, >>=, &=, |=, and ^=).

# ================================
# Operator Types - Special Operators
# ================================

# The auto-increment operator has special behavior.
# When used on a value with a numeric component (Cached Coercions),
# the operator increments that numeric component.
# If the value is obviously a string (if it has no numeric component),
# the operator increments the value's string component
# such that a becomes b, zz becomes aaa, and a9 becomes b0.
{
    my $num = 1;
    my $str = 'a';

    $num++;
    $str++;
    is $num, 2,   'numeric autoincrement';
    is $str, 'b', 'string autoincrement';

    no warnings 'numeric';
    $num += $str;
    $str++;

    is $num, 2, 'numeric addition with $str';
    is $str, 1, '... gives $str a numeric part';
}

# The repetition operator (x) is an infix operator with complex behavior.
# When evaluated in list context with a list as its first operand,
# it evaluates to that list repeated the number of times specified by its second operand.
# When evaluated in list context with a scalar as its first operand,
# it produces a string consisting of the string value of its first operand concatenated to itself
# the number of times specified by its second operand.
# In scalar context, the operator repeats and concatenates a string:
{
    my @scheherazade = ('nights') x 1001;
    my $calendar     = 'nights' x 1001;
    my $cal_length   = length $calendar;

    is @scheherazade, 1001,                   'list repeated';
    is $cal_length,   1001 * length 'nights', 'word repeated';

    my @schenolist = 'nights' x 1001;
    my $calscalar  = ('nights') x 1001;

    is @schenolist,       1,                      'no lvalue list';
    is length $calscalar, 1001 * length 'nights', 'word still repeated';
}

# The infix range operator (..) produces a list of items in list context:
{
    # It can only produce simple, incrementing ranges of integers or strings.
    my @cards = ( 2 .. 10, 'J', 'Q', 'K', 'A' );
}

# TODO: review
# In boolean context, the range operator performs a flip-flop operation.
# This operator produces a false value until its left operand is true.
# That value stays true until the right operand is true,
# after which the value is false again until the left operand is true again.
# Imagine parsing the text of a formal letter with:
# {
#     while (/Hello, $user/ .. /Sincerely,/) {
#         say "> $_";
#     }
# }

# The comma operator (,) is an infix operator.
# In scalar context it evaluates its left operand
# then returns the value produced by evaluating its right operand.
# In list context, it evaluates both operands in left-to-right order.

# The fat comma operator (=>) also quotes any bareword used as its left operand (Hashes).

# The triple-dot or whatever operator stands in for a single statement.
# It is nullary and has neither precedence nor associativity.
# It parses, but when executed it throws an exception with the string Unimplemented.
# This makes a great placeholder in example code you don't expect anyone to execute:
sub some_example {

    # implement this yourself
    ...;
}

done_testing();
