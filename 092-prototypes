#!/usr/bin/env perl
# REF: http://modernperlbooks.com/books/modern_perl_2016/11-what-to-avoid-in-perl.html#UHJvdG90eXBlcw

use 5.034;
use warnings;
use autodie;
use feature 'say';

use Test::More;

# A prototype is a piece of metadata attached to a function or variable.
# A function prototype changes how Perl's parser understands it.

# Prototypes allow you to define your own functions which behave like builtins.
# Consider the builtin push,
# which takes an array and a list.
# While Perl would normally flatten the array and list into a single list passed to push,
# Perl knows to treat the array as a container and does not flatten its values.
# In effect, this is like passing a reference to an array and a list of values to push—
# because Perl's parser understands this is what push needs to do.

# Function prototypes attach to function declarations:
{
    sub foo (&@);
    sub bar ($$) { ... }
    my $baz = sub (&&) { ... };
}

# Any prototype attached to a forward declaration
# must match the prototype attached to the function declaration.
# Perl will give a warning if this is not true.
# Strangely you may omit the prototype from a forward declaration
# and include it for the full declaration—
# but the only reason to do so is to win a trivia contest.

# The builtin prototype takes the name of a function
# and returns a string representing its prototype.

# To see the prototype of a builtin, prepend CORE:: to its name for prototype's operand:
#
#     $ perl -E "say prototype 'CORE::push';"
#     \@@
#     $ perl -E "say prototype 'CORE::keys';"
#     \%
#     $ perl -E "say prototype 'CORE::open';"
#     *;$@

# prototype will return undef for those builtins whose functions you cannot emulate:
{
    # undef; cannot emulate builtin system
    say prototype 'CORE::system' // 'undef';

    # undef; builtin prototype has no prototype
    say prototype 'CORE::prototype' // 'undef';
}

# Remember push?
#
#     $ perl -E "say prototype 'CORE::push';"
#     \@@
#
# The @ character represents a list.
# The backslash forces the use of a reference to the corresponding argument.
# This prototype means that push takes a reference to an array and a list of values.
# You might write mypush as:
sub mypush (\@@) {
    my ( $array, @rest ) = @_;
    push @$array, @rest;
}

# Other prototype characters include
# $ to force a scalar argument,
# % to mark a hash (most often used as a reference),
# and & to identify a code block.
# See perldoc perlsub for more information.

# ================================
# The Problem with Prototypes
# ================================

# Prototypes change how Perl parses your code
# and how Perl coerces arguments passed to your functions.
# While these prototypes may superficially resemble function signatures (Real Function Signatures) in other languages,
# they are very different.
# They do not document the number or types of arguments functions expect,
# nor do they map arguments to named parameters.

# Prototype coercions work in subtle ways,
# such as enforcing scalar context on incoming arguments:
sub demo_prototype_coercions {

    sub numeric_equality($$) {
        my ( $left, $right ) = @_;
        return $left == $right;
    }

    my @nums = 1 .. 10;

    say "They're equal, whatever that means!" if numeric_equality @nums, 10;
}

# ... but only work on simple expressions:
# {
#     sub mypush(\@@);

#     # compilation error: prototype mismatch
#     # (expects array, gets scalar assignment)
#     mypush( my $elems = [], 1 .. 20 );
# }

# To debug this, users of mypush must know both that a prototype exists,
# and the limitations of the array prototype.
# That's a lot of cognitive burden to put on a user—
# and if you think this error message is inscrutable,
# wait until you see the complicated prototype errors.

# ================================
# Good Uses of Prototypes
# ================================

# Prototypes do have a few good uses that outweigh their problems.
# For example, you can use a prototyped function to override one of Perl's builtins.
# First check that you can override the builtin by examining its prototype in a small test program.
# Then use the subs pragma to tell Perl that you plan to override a builtin.
# Finally declare your override with the correct prototype:
sub demo_prototype_overrides {
    use subs 'push';

    sub push (\@@) { ... }
}

# Note that the subs pragma is in effect for the remainder of the file,
# regardless of any lexical scoping.

# You may also usefully use prototypes to define compile-time constants.
# When Perl encounters a function declared with an empty prototype (as opposed to no prototype)
# and this function evaluates to a single constant expression,
# the optimizer will turn all calls to that function into constants instead of function calls:
sub demo_prototype_constants {
    sub PI () { 4 * atan2( 1, 1 ) }
}

# All subsequent code will use the calculated value of pi in place of the bareword (PI) or a call to (PI()),
# with respect to scoping and visibility.

# The core pragma constant handles these details for you.
# The Const::Fast module from the CPAN creates constant scalars which you can interpolate into strings.

# A reasonable use of prototypes is to extend Perl's syntax to operate on anonymous functions as blocks.
# The CPAN module Test::Exception uses this to good effect to provide a nice API with delayed computation.
# Its throws_ok() function takes three arguments:
# a block of code to run,
# a regular expression to match against the string of the exception,
# and an optional description of the test:
# {
#     use Test::More;
#     use Test::Exception;
#
#     throws_ok
#         { my $unobject; $unobject->yoink }
#         qr/Can't call method "yoink" on an undefined/,
#         'Method on undefined invocant should fail';
#
#     done_testing();
# }

# The exported throws_ok() function has a prototype of (&$;$).
# Its first argument is a block,
# which becomes an anonymous function.
# The second argument is a scalar.
# The third argument is optional.

# Careful readers may have spotted the absence of a comma after the block.
# NOTE: This is a quirk of Perl's parser,
# which expects whitespace after a prototyped block,
# not the comma operator.
# This is a drawback of the prototype syntax.
# If that bothers you, use throws_ok() without taking advantage of the prototype:
# {
#     use Test::More;
#     use Test::Exception;
#
#     throws_ok(
#         sub { my $unobject; $unobject->yoink() },
#         qr/Can't call method "yoink" on an undefined/,
#         'Method on undefined invocant should fail' );
#
#     done_testing();
# }

# Test::Fatal allows similar testing and uses a simpler approach to avoid this ambiguity.

# Ben Tilly suggests a final good use of prototypes,
# to define a custom named function to use with sort:
sub demo_prototype_function_for_sort {
    my @unsorted;

    sub length_sort ($$) {
        my ( $left, $right ) = @_;
        return length($left) <=> length($right);
    }

    my @sorted = sort length_sort @unsorted;
}

# The prototype of $$ forces Perl to pass the sort pairs in @_.
# sort's documentation suggests that this is slightly slower than using the package globals $a and $b,
# but using lexical variables often makes up for any speed penalty.

done_testing();
