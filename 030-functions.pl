#!/usr/bin/env perl
# REF: http://modernperlbooks.com/books/modern_perl_2016/05-perl-functions.html
# REF: [Perl builtin functions - Perldoc Browser](https://perldoc.perl.org/functions)
# REF: [perlfunc - Perl builtin functions - Perldoc Browser](https://perldoc.perl.org/perlfunc)

use 5.034;
use warnings;
use autodie;
use feature 'say';

use Test::More;

# A function (or subroutine) in Perl is a discrete, encapsulated unit of behavior.
# Functions are a prime mechanism for organizing code into similar groups,
# identifying individual pieces by name,
# and providing reusable units of behavior.

# ================================
# Declaring Functions
# ================================

# Use the sub builtin to declare a function:
sub greet_me { ... }

# Now you can invoke greet_me() from anywhere within your program.

# Just as you may declare a lexical variable but leave its value undefined,
# you may declare a function without defining it.
# A forward declaration tells Perl to record that a named function exists.
# You may define it later:
sub greet_sun;

# NOTE: Review for fun.
sub demo_implicit_return {

    sub function {
        my ( $x, $y ) = @_;

        if ( $x < $y ) {
            my $total = $x + $y;
        }
    }

    {
        my $res = function( 2, 3 );
        say defined $res ? "defined"      : "undef";
        say $res == 0    ? "zero"         : "NOT zero";
        say $res eq ""   ? "empty string" : "NOT the empty string";
        say $res;
        say "-------------------";
    }
    {
        my $res = function( 3, 2 );
        say defined $res ? "defined"      : "undef";
        say $res == 0    ? "zero"         : "NOT zero";
        say $res eq ""   ? "empty string" : "NOT the empty string";
        say $res;
        say "-------------------";
    }
}

# ================================
# Invoking Functions
# ================================

# Use postfix (Fixity) parentheses to invoke a named function.
# Any arguments to the function may go within the parentheses:
# {
#     greet_me( 'Jack', 'Tuxie', 'Brad' );
#     greet_me( 'Snowy' );
#     greet_me();
# }
# While these parentheses are not strictly necessary for these examples—
# even with strict enabled—
# they provide clarity to human readers as well as Perl's parser.
# When in doubt, use them.

# Function arguments can be arbitrary expressions—
# including variables and function calls:
# {
#     greet_me( $name );
#     greet_me( @authors );
#     greet_me( %editors );
#     greet_me( get_readers() );
# }
# ... though Perl's default parameter handling sometimes surprises novices.

# ================================
# Function Parameters: See 031-function-parameters
# ================================

# ================================
# Functions and Namespaces
# ================================

# Every function has a containing namespace (Packages).
# Functions in an undeclared namespace—
# functions not declared within the scope of an explicit package statement—
# exist in the main namespace.
# You may also declare a function within another namespace by prefixing its name:
sub Extensions::Math::add { ... }

# This will create the namespace as necessary and then declare the function within it.
# Note that Perl packages are open for modification at any point—
# even while your program is running.
# Perl will issue a warning if you declare multiple functions with the same name in a single namespace.

# Refer to other functions within the same namespace with their short names.
# Use a fully-qualified name to invoke a function in another namespace:
# {
#     package main;
#
#     Extensions::Math::add( $scalar, $vector );
# }

# Remember, functions are visible outside of their own namespaces through their fully-qualified names.
# Alternately, you may import names from other namespaces.

# Perl 5.18 added an experimental feature to declare functions lexically.
# They're visible only within lexical scopes after declaration.
# See the "Lexical Subroutines" section of perldoc perlsub for more details.

# When loading a module with the use builtin (Modules),
# Perl automatically calls a method named import().
# Modules can provide their own import() method
# which makes some or all defined symbols available to the calling package.
# Any arguments after the name of the module in the use statement
# get passed to the module's import() method.
# Thus:
# {
#     use strict;
# }
# ... loads the strict.pm module
# and calls strict->import() with no arguments,
# while:
# {
#     use strict 'refs';
#     use strict qw( subs vars );
# }
# ... loads the strict.pm module,
# calls strict->import( 'refs' ),
# then calls strict->import( 'subs', vars' ).

# (use) has special behavior with regard to import(),
# but you may call import() directly.
# The use example is equivalent to:
# {
#     BEGIN {
#         require strict;
#         strict->import( 'refs' );
#         strict->import( qw( subs vars ) );
#     }
# }
# The use builtin adds an implicit BEGIN block around these statements
# so that the import() call happens immediately after the parser has compiled the entire use statement.
# This ensures that the parser knows about any symbols imported by strict
# before it compiles the rest of the program.
# Otherwise, any functions imported from other modules but not declared in the current file
# would look like barewords, and would violate strict, for example.

# Of course, strict is a pragma (Pragmas), so it has other effects.

# ================================
# Reporting Errors
# ================================

# Use the caller builtin to inspect a function's calling context.
# When passed no arguments,
# caller returns a list containing the name of the calling package,
# the name of the file containing the call,
# and the line number of the file on which the call occurred:
{

    package main;

    main();

    sub main {
        show_call_information();
    }

    sub show_call_information {
        my ( $package, $file, $line ) = caller();
        say "Called from $package in $file:$line";
    }
}

# The full call chain is available for inspection.
# Pass a single integer argument n to caller()
# to inspect the caller of the caller of the caller n times back.
# Within show_call_information(),
# caller(0) returns information about the call from main().
# caller(1) returns information about the call from the start of the program.

# This optional argument also tells caller to provide additional return values,
# including the name of the function and the context of the call:
sub show_call_information_1 {
    my ( $package, $file, $line, $func ) = caller(0);
    say "Called $func from $package in $file:$line";
}

# The standard Carp module uses caller to enhance error and warning messages.
# When used in place of die in library code,
# croak() throws an exception from the point of view of its caller.
# carp() reports a warning from the file and line number of its caller (Producing Warnings).

# Use caller (or Carp) when validating parameters or preconditions of a function
# to indicate that whatever called the function did so erroneously.

# While Perl does its best to do what you mean,
# it offers few native ways to test the validity of arguments provided to a function.
# Evaluate @_ in scalar context to check that the number of parameters passed to a function is correct:
{
    use Carp 'croak';

    sub add_numbers {
        croak 'Expected two numbers, received: ' . @_
          unless @_ == 2;

        ...;
    }
}

# This validation reports any parameter count error from the point of view of its caller,
# thanks to the use of croak.

# Type checking is more difficult,
# because of Perl's operator-oriented type conversions (Context).
# If you want additional safety of function parameters,
# see CPAN modules such as Params::Validate.

# ================================
# Advanced Functions: See 032-advanced-functions
# ================================

# ================================
# Pitfalls and Misfeatures
# ================================

# Perl still supports old-style invocations of functions,
# carried over from ancient versions of Perl.
# Previous versions of Perl required you to invoke functions with a leading ampersand (&) character:
# {
#     # outdated style; avoid
#     my $result = &calculate_result( 52 );
#
#     # very outdated; truly avoid
#     my $result = do &calculate_result( 42 );
# }
# While the vestigial syntax is visual clutter,
# the leading ampersand form has other surprising behaviors.
# First, it disables any prototype checking.
# Second, it implicitly passes the contents of @_ unmodified,
# unless you've explicitly passed arguments yourself.
# That unfortunate behavior can be confusing invisible action at a distance.

# TODO: review
# A final pitfall comes from leaving the parentheses off of function calls.
# The Perl parser uses several heuristics to resolve ambiguous barewords
# and the number of parameters passed to a function.
# Heuristics can be wrong:
# {
#     # warning; contains a subtle bug
#     ok elem_exists 1, @elements, 'found first element';
# }
# The call to elem_exists() will gobble up the test description intended as the second argument to ok().
# Because elem_exists() uses a slurpy second parameter,
# this may go unnoticed until Perl produces warnings about comparing a non-number
# (the test description, which it cannot convert into a number)
# with the element in the array.

# While extraneous parentheses can hamper readability,
# thoughtful use of parentheses can clarify code to readers and to Perl itself.

# ================================
# Scope: See 033-scope
# ================================

# ================================
# Anonymous Functions: See 034-anonymous-functions
# ================================

# ===============================
# Closures: See 035-closures
# ================================

# ================================
# State versus Closures
# ================================

# Closures (Closures) use lexical scope (Scope) to control access to lexical variables—
# even with named functions:
{
    my $safety = 0;

    sub enable_safety  { $safety = 1 }
    sub disable_safety { $safety = 0 }

    sub do_something_awesome {
        return if $safety;
        ...;
    }
}

# All three functions encapsulate that shared state
# without exposing the lexical variable outside of their shared scope.
# This idiom works well for cases where multiple functions access that lexical,
# but it's clunky when only one function does.
# Suppose every hundredth ice cream parlor customer gets free sprinkles:
{
    my $cust_count = 0;

    sub serve_customer {
        $cust_count++;
        my $order = shift;

        add_sprinkles($order) if $cust_count % 100 == 0;
        ...;
    }
}

# This approach works,
# but creating a new outer lexical scope for a single function is a little bit noisy.
# The state builtin allows you to declare a lexically scoped variable
# with a value that persists between invocations:
sub serve_customer_using_state {
    state $cust_count = 0;
    $cust_count++;

    my $order = shift;
    add_sprinkles($order) if ( $cust_count % 100 == 0 );

    ...;
}

# state also works within anonymous functions:
sub make_counter {
    return sub {
        state $count = 0;
        return $count++;
    }
}

# ... though there are few obvious benefits to this approach.

# ================================
# State versus Pseudo-State
# ================================

# In old versions of Perl,
# a named function could close over its previous lexical scope
# by abusing a quirk of implementation.
# Using a postfix conditional which evaluates to false
# with a my declaration
# avoided reinitializing a lexical variable to undef or its initialized value.

# Now any use of a postfix conditional expression modifying a lexical variable declaration
# produces a deprecation warning.
# It's too easy to write inadvertently buggy code with this technique;
# use state instead where available,
# or a true closure otherwise.
# Rewrite this idiom when you encounter it:
sub inadvertent_state {

    # my $counter  = 1 if 0; # DEPRECATED; don't use
    state $counter = 1;    # prefer

    ...;
}

# You may only initialize a state variable with a scalar value.
# If you need to keep track of an aggregate,
# use a hash or array reference (References).

# ================================
# Attributes
# ================================

# NOTE: Review when needed.
# Named entities in Perl—variables and functions—
# can have additional metadata attached in the form of attributes.
# These attributes are arbitrary names and values used with certain types of metaprogramming (Code Generation).

# Attribute declaration syntax is awkward,
# and using attributes effectively is more art than science.
# Most programs never use them,
# but when used well they offer clarity and maintenance benefits.

# A simple attribute is a colon-preceded identifier attached to a declaration:
# {
#     my $fortress      :hidden;
#
#     sub erupt_volcano :ScienceProject { ... }
# }
# When Perl parses these declarations,
# it invokes attribute handlers named hidden and ScienceProject,
# if they exist for the appropriate types (scalars and functions, respectively).
# These handlers can do anything.
# If the appropriate handlers do not exist,
# Perl will throw a compile-time exception.

# Attributes may include a list of parameters.
# Perl treats these parameters as lists of constant strings.
# The Test::Class module from the CPAN uses such parametric arguments to good effect:
# {
#     sub setup_tests          :Test(setup)    { ... }
#     sub test_monkey_creation :Test(10)       { ... }
#     sub shutdown_tests       :Test(teardown) { ... }
# }
# The Test attribute identifies methods
# which include test assertions
# and optionally identifies the number of assertions the method intends to run.
# While introspection (Reflection) of these classes could discover the appropriate test methods,
# given well-designed solid heuristics,
# the :Test attribute is unambiguous.
# Test::Class provides attribute handlers which keep track of these methods.
# When the class has finished parsing,
# Test::Class can loop through the list of test methods and run them.

# The setup and teardown parameters allow test classes to define their own support methods
# without worrying about conflicts with other such methods in other classes.
# This separates the idea of what this class must do from how other classes do their work.
# Otherwise a test class might have only one method named setup and one named teardown
# and would have to do everything there,
# then call the parent methods, and so on.

# ================================
# Attributes - Drawbacks of Attributes
# ================================

# Attributes have their drawbacks.
# The canonical pragma for working with attributes (the attributes pragma)
# has listed its interface as experimental for many years, and for good reason.
# Damian Conway's core module Attribute::Handlers is much easier to use,
# and Andrew Main's Attribute::Lexical is a newer approach.
# Prefer either to attributes whenever possible.

# The worst feature of attributes is that they make it easy to warp the syntax of Perl in unpredictable ways.
# You may not be able to predict what code with attributes will do.
# Good documentation helps,
# but if an innocent-looking declaration on a lexical variable stores a reference to that variable somewhere,
# your expectations of its lifespan may be wrong.
# Likewise, a handler may wrap a function in another function
# and replace it in the symbol table without your knowledge—
# consider a :memoize attribute which automatically invokes the core Memoize module.

# Attributes can help you to solve difficult problems
# or to make an API much easier to use.
# When used properly, they're powerful—but most programs never need them.

# ================================
# AUTOLOAD: See 036-autoload
# ================================

done_testing();
