#!/usr/bin/env perl
# REF: http://modernperlbooks.com/books/modern_perl_2016/05-perl-functions.html#U2NvcGU

use 5.034;
use warnings;
use autodie;
use feature 'say';

use Test::More;

# Everything with a name in Perl
# (a variable, a function, a filehandle, a class)
# has a scope.
# This scope governs the lifespan and visibility of these entities.
# Scoping helps to enforce encapsulation—
# keeping related concepts together and preventing their details from leaking.

# ================================
# Lexical Scope
# ================================

# Lexical scope is the scope apparent to the readers of a program.
# Any block delimited by curly braces creates a new scope:
# a bare block,
# the block of a loop construct,
# the block of a sub declaration,
# an eval block,
# a package block,
# or any other non-quoting block.
# The Perl compiler resolves this scope during compilation.

# Lexical scope describes the visibility of variables declared with my—lexical variables.
# A lexical variable declared in one scope is visible in that scope
# and any scopes nested within it,
# but is invisible to sibling or outer scopes:

# outer lexical scope
{

    package Robot::Butler;    # NOTE: Missing semicolon in the original book.

    # inner lexical scope
    my $battery_level;

    sub tidy_room {

        # further inner lexical scope
        my $timer;

        do {
            # innermost lexical scope
            my $dustpan;
            ...;
        } while (@_);

        # sibling inner lexical scope
        for (@_) {

            # separate innermost scope
            my $polish_cloth;
            ...;
        }
    }
}

# ... $battery_level is visible in all four scopes.
# $timer is visible in the method, the do block, and the for loop.
# $dustpan is visible only in the do block
# and $polish_cloth within the for loop.

# Declaring a lexical in an inner scope with the same name as a lexical in an outer scope
# hides, or shadows, the outer lexical within the inner scope.
# Shadowing a lexical is a feature of encapsulation.
# Declaring multiple variables with the same name and type in the same lexical scope
# produces a warning message.

# In real code with larger scopes,
# this shadowing behavior is often desirable—
# it's easier to understand code when a lexical is in scope only for a couple of dozen lines.
# Lexical shadowing can happen by accident, though.
# Limit the scope of variables and the nesting of scopes to lessen your risk.

# Some lexical declarations have subtleties,
# such as a lexical variable used as the iterator variable of a for loop.
# Its declaration occurs outside of the block,
# but its scope is that within the loop block:
sub demo_lexical_subtleties {
    my $cat = 'Brad';

    for my $cat (qw( Jack Daisy Petunia Tuxedo Choco )) {
        say "Inner cat is $cat";
    }

    say "Outer cat is $cat";
}

# Functions—named and anonymous—provide lexical scoping to their bodies.
# This enables closures (Closures).

# ================================
# Our Scope
# ================================

# Within a scope you may declare an alias to a package variable with the (our) builtin.
# Like (my), (our) enforces lexical scoping of the alias.
# The fully-qualified name is available everywhere,
# but the lexical alias is visible only within its scope.

# (our) is most useful with package global variables such as $VERSION and $AUTOLOAD.
# You get a little bit of typo detection
# (declaring a package global with our satisfies the (strict) pragma's (vars) rule),
# but you still have to deal with a global variable.

# TODO: review https://perldoc.perl.org/functions/our

# ===============================
# Dynamic Scope
# ===============================

# Dynamic scope resembles lexical scope in its visibility rules,
# but instead of looking outward in compile-time scopes,
# lookup traverses backwards through all of the function calls you've made to reach the current code.
# Dynamic scope applies only to global and package global variables
# (as lexicals aren't visible outside their scopes).
# While a package global variable may be visible within all scopes,
# its value may change depending on (local)ization and assignment:
our $scope;

sub inner {
    say $scope;
}

sub middle {
    say $scope;
    inner();
}

sub main {
    say $scope;
    local $scope = 'main() scope';
    middle();
}

$scope = 'outer scope';
main();
say $scope;

# The program begins by declaring an our variable, $scope, as well as three functions.
# It ends by assigning to $scope and calling main().
# Within main(), the program prints $scope's current value, outer scope,
# then localizes the variable.
# This changes the visibility of the symbol within the current lexical scope
# NOTE: as well as in any functions called from the current lexical scope;
# that as well as condition is what dynamic scoping does.
# Thus, $scope contains main() scope within the body of both middle() and inner().
# After main() returns,
# when control flow reaches the end of its block,
# Perl restores the original value of the localized $scope.
# The final say prints outer scope once again.

# Perl also uses different storage mechanisms for package variables and lexical variables.
# Every scope which contains lexical variables uses a data structure
# called a lexical pad or lexpad
# to store the values for its enclosed lexical variables.
# Every time control flow enters one of these scopes,
# Perl creates another lexpad
# to contain the values of the lexical variables for that particular call.
# This makes functions work correctly,
# especially recursive functions (Recursion).

# Each package has a single symbol table which holds package variables and well as named functions.
# Importing (Importing) works by inspecting and manipulating this symbol table.
# So does (local).
# This is why you may only (local)ize global and package global variables—never lexical variables.

# (local) is most often useful with magic variables.
# For example,
# $/, the input record separator,
# governs how much data a readline operation will read from a filehandle.
# $!, the system error variable,
# contains error details for the most recent system call.
# $@, the Perl (eval) error variable,
# contains any error from the most recent (eval) operation.
# $|, the autoflush variable,
# governs whether Perl will flush the currently (select)ed filehandle after every write operation.

# (local)izing these in the narrowest possible scope limits the effect of your changes.
# This can prevent strange behavior in other parts of your code.

# ================================
# State Scope
# ================================

# Perl's (state) keyword allows you to declare a lexical
# which has a one-time initialization as well as value persistence:
{

    sub counter_1 {
        state $count = 1;
        return $count++;
    }

    say counter_1();
    say counter_1();
    say counter_1();
}

# On the first call to counter,
# Perl initializes $count.
# On subsequent calls, $count retains its previous value.
# This program prints 1, 2, and 3.
# Change state to my and the program will print 1, 1, and 1.

# You may use an expression to set a state variable's initial value:
{

    sub counter_2 {
        state $count = shift;
        return $count++;
    }

    say counter_2(2);
    say counter_2(4);
    say counter_2(6);
}

# Even though a simple reading of the code may suggest that the output should be 2, 4, and 6,
# the output is actually 2, 3, and 4.
# The first call to the sub counter sets the $count variable.
# Subsequent calls will not change its value.

# (state) can be useful for establishing a default value or preparing a cache,
# but be sure to understand its initialization behavior if you use it:
{

    sub counter_3 {
        state $count = shift;
        say 'Second arg is: ', shift;
        return $count++;
    }

    say counter_3( 2, 'two' );
    say counter_3( 4, 'four' );
    say counter_3( 6, 'six' );
}

# The counter for this program prints 2, 3, and 4 as expected,
# NOTE: but the values of the intended second arguments to the counter() calls are two, 4, and 6—
# because the (shift) of the first argument only happens in the first call to counter().
# Either change the API to prevent this mistake,
# or guard against it with:
{

    sub counter_4 {
        my ( $initial_value, $text ) = @_;

        state $count = $initial_value;
        say "Second arg is: $text";
        return $count++;
    }

    say counter_4( 2, 'two' );
    say counter_4( 4, 'four' );
    say counter_4( 6, 'six' );
}

done_testing();
