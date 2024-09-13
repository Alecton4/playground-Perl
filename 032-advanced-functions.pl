#!/usr/bin/env perl
# REF: http://modernperlbooks.com/books/modern_perl_2016/05-perl-functions.html#QWR2YW5jZWRGdW5jdGlvbnM

use 5.034;
use warnings;
use autodie;
use feature 'say';

use Test::More;

# ================================
# Context Awareness
# ================================

# Perl's builtins know whether you've invoked them in void, scalar, or list context.
# So too can your functions.
# The wantarray builtin returns undef to signify void context,
# a false value to signify scalar context,
# and a true value to signify list context.
# Yes, it's misnamed; see perldoc -f wantarray for proof.
{

    sub context_sensitive {
        my $context = wantarray();

        return qw( List context ) if $context;
        say 'Void context'      unless defined $context;
        return 'Scalar context' unless $context;
    }

    context_sensitive();
    say my $scalar = context_sensitive();
    say context_sensitive();
}

# This can be useful for functions which might produce expensive return values to avoid doing so in void context.
# Some idiomatic functions return a list in list context
# and the first element of the list or an array reference in scalar context.
# However, there exists no single best recommendation for the use of wantarray.
# Sometimes it's clearer to write separate and unambiguous functions,
# such as get_all_toppings() and get_next_topping().

# Robin Houston's Want and Damian Conway's Contextual::Return distributions from the CPAN
# offer many possibilities for writing powerful context-aware interfaces.

# ================================
# Recursion
# ================================

# Suppose you want to find an element in a sorted array.
# You could iterate through every element of the array individually,
# looking for the target,
# but on average, you'll have to examine half of the elements of the array.
# Another approach is to halve the array,
# pick the element at the midpoint, compare,
# then repeat with either the lower or upper half.
# Divide and conquer.
# When you run out of elements to inspect or find the element, stop.

# An automated test for this technique could be:
{
    use Test::More;

    my @elements = ( 1, 5, 6, 19, 48, 77, 997, 1025, 7777, 8192, 9999 );

    ok elem_exists( 1,      @elements ), 'found first element in array';
    ok elem_exists( 9999,   @elements ), 'found last element in array';
    ok !elem_exists( 998,   @elements ), 'did not find element not in array';
    ok !elem_exists( -1,    @elements ), 'did not find element not in array';
    ok !elem_exists( 10000, @elements ), 'did not find element not in array';

    ok elem_exists( 77,  @elements ), 'found midpoint element';
    ok elem_exists( 48,  @elements ), 'found end of lower half element';
    ok elem_exists( 997, @elements ), 'found start of upper half element';
}

# Recursion is a deceptively simple concept.
# Every call to a function in Perl creates a new call frame,
# an data structure internal to Perl itself
# which represents the fact that you've called a function.
# This call frame includes the lexical environment of the function's current invocation—
# the values of all lexical variables within the function as invoked.
# Because the storage of the values of the lexical variables is separate from the function itself,
# you can have multiple calls to a function active at the same time.
# A function can even call itself, or recur.

# To make the previous test pass, write the recursive function elem_exists():
sub elem_exists {
    my ( $item, @array ) = @_;

    # break recursion with no elements to search
    return unless @array;

    # bias down with odd number of elements
    my $midpoint = int( ( @array / 2 ) - 0.5 );
    my $miditem  = $array[$midpoint];

    # return true if found
    return 1 if $item == $miditem;

    # return false with only one element
    return if @array == 1;

    # split the array down and recurse
    return elem_exists( $item, @array[ 0 .. $midpoint ] ) if $item < $miditem;

    # split the array and recurse
    return elem_exists( $item, @array[ $midpoint + 1 .. $#array ] );
}

# Keep in mind that the arguments to the function will be different for every call,
# otherwise the function would always behave the same way
# (it would continue recursing until the program crashes).
# That's why the termination condition is so important.

# Every recursive program can be written without recursion,
# but this divide-and-conquer approach is an effective way to manage many similar types of problems.
# For more information about recursion, iteration, and advanced function use in Perl
# the free book Higher Order Perl http://hop.perl.plover.com/ is an excellent reference.

# ================================
# Lexicals
# ================================

# Every invocation of a function creates its own instance of a lexical scope
# represented internally by a call frame.
# Even though the declaration of elem_exists() creates a single scope for the lexicals
# $item, @array, $midpoint, and $miditem,
# every call to elem_exists()—even recursively—stores the values of those lexicals separately.

# Not only can elem_exists() call itself,
# but the lexical variables of each invocation are safe and separate:
{
    use Carp 'cluck';

    sub elem_exists_examine {
        my ($item, @array) = @_;

        cluck "[$item] (@array)";
        ...
    }
}

# ================================
# Tail Calls
# ================================

# One drawback of recursion is that
# it's easy to write a function which calls itself infinitely.
# elem_exists() function has several return statements for this reason.
# Perl offers a helpful Deep recursion on subroutine warning
# when it suspects runaway recursion.
# The limit of 100 recursive calls is arbitrary, but often useful.
# Disable this warning with no warnings 'recursion'.

# Because each call to a function requires a new call frame and lexical storage space,
# highly-recursive code can use more memory than iterative code.
# Tail call elimination can help.

# A tail call is a call to a function which directly returns that function's results.
# These recursive calls to elem_exists():
# {
#     # split the array down and recurse
#     return elem_exists(
#         $item, @array[0 .. $midpoint]
#     ) if $item < $miditem;
#
#     # split the array and recurse
#     return elem_exists(
#          $item, @array[ $midpoint + 1 .. $#array ]
#     );
# }
# ... are candidates for tail call elimination.
# This optimization would avoid returning to the current call
# and then returning to the parent call.
# Instead, it returns to the parent call directly.

# TODO: review
# Perl does not eliminate tail calls automatically,
# but you can get the same effect by using a special form of the goto builtin.
# Unlike the form which often produces spaghetti code,
# the goto function form replaces the current function call with a call to another function.
# You may use a function by name or by reference.
# Manipulate @_ to modify the arguments passed to the replacement function:
# {
#     # split the array down and recurse
#     if ($item < $miditem) {
#         @_ = ($item, @array[0 .. $midpoint]);
#         goto &elem_exists;
#     }
#
#     # split the array up and recurse
#     else {
#         @_ = ($item, @array[$midpoint + 1 .. $#array] );
#         goto &elem_exists;
#     }
# }
# Sometimes optimizations are ugly,
# but if the alternative is highly recursive code which runs out of memory,
# embrace the ugly and rejoice in the practical.

done_testing();
