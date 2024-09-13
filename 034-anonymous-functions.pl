#!/usr/bin/env perl
# REF: http://modernperlbooks.com/books/modern_perl_2016/05-perl-functions.html#QW5vbnltb3VzRnVuY3Rpb25z

use 5.034;
use warnings;
use autodie;
use feature 'say';

use Test::More;

# An anonymous function is a function without a name.
# It behaves exactly like a named function—
# you can invoke it,
# pass it arguments,
# return values from it,
# and take references to it.
# Yet you can only access an anonymous function by reference (Function References), not by name.

# A Perl idiom known as a dispatch table uses hashes to associate input with behavior:
{
    my %dispatch = (
        plus  => \&add_two_numbers,
        minus => \&subtract_two_numbers,
        times => \&multiply_two_numbers,
    );

    sub add_two_numbers      { $_[0] + $_[1] }
    sub subtract_two_numbers { $_[0] - $_[1] }
    sub multiply_two_numbers { $_[0] * $_[1] }

    sub dispatch {
        my ( $left, $op, $right ) = @_;

        return unless exists $dispatch{$op};

        return $dispatch{$op}->( $left, $right );
    }
}

# The dispatch() function takes arguments of the form (2, 'times', 2),
# evaluates the operation, and returns the result.
# A trivial calculator application could use dispatch
# to figure out which calculation to perform based on user input.

# ================================
# Declaring Anonymous Functions
# ================================

# The sub builtin used without a name creates and returns an anonymous function.
# Use this function reference where you'd use a reference to a named function,
# such as to declare the dispatch table's functions in place:
{
    my %dispatch = (
        plus      => sub { $_[0] + $_[1] },
        minus     => sub { $_[0] - $_[1] },
        times     => sub { $_[0] * $_[1] },
        dividedBy => sub { $_[0] / $_[1] },
        raisedTo  => sub { $_[0]**$_[1] },
    );
}

# Only those functions within this dispatch table are available for users to call.
# !!! If your dispatch function used a user-provided string as the literal name of functions,
# a malicious user could call any function anywhere
# by passing a fully-qualified name such as 'Internal::Functions::malicious_function'.

# You may also see anonymous functions passed as function arguments:
sub demo_anonymous_functions_as_arguments {

    sub invoke_anon_function {
        my $func = shift;
        return $func->(@_);
    }

    sub named_func {
        say 'I am a named function!';
    }

    invoke_anon_function( \&named_func );
    invoke_anon_function( sub { say 'Who am I?' } );
}

# ================================
# Anonymous Function Names
# ================================

# Use introspection to determine whether a function is named or anonymous,
# whether through caller() or the CPAN module Sub::Identify's sub_name() function:
{

    package ShowCaller;

    sub show_caller {
        my ( $package, $file, $line, $sub ) = caller(1);
        say "Called from $sub in $package:$file:$line";
    }

    sub main {
        my $anon_sub = sub { show_caller() };
        show_caller();
        $anon_sub->();
    }

    main();
}

# The result may be surprising:
#
#     Called from ShowCaller::main
#              in ShowCaller:anoncaller.pl:20
#     Called from ShowCaller::__ANON__
#              in ShowCaller:anoncaller.pl:17
#
# The __ANON__ in the second line of output demonstrates that
# the anonymous function has no name that Perl can identify.

# The CPAN module Sub::Name's subname() function allows you to attach names to anonymous functions:
{
    use Sub::Name;
    use Sub::Identify 'sub_name';

    my $anon = sub { };
    say sub_name($anon);

    my $named = subname( 'pseudo-anonymous', $anon );
    say sub_name($named);
    say sub_name($anon);

    say sub_name( sub { } );
}

# This program produces:
#
#     __ANON__
#     pseudo-anonymous
#     pseudo-anonymous
#     __ANON__
#
# Be aware that both references refer to the same underlying anonymous function.
# Using subname() on one reference will change that underlying function;
# all other references to that function will see the new name.

# ================================
# Implicit Anonymous Functions
# ================================

# Perl allows you to declare anonymous functions as function arguments
# without using the sub keyword.
# Though this feature exists nominally to enable programmers to write their own syntax
# such as that for map and eval (Prototypes),
# you can use it for other things,
# such as to write delayed functions that don't look like functions.

# Consider the CPAN module Test::Fatal,
# which takes an anonymous function as the first argument to its exception() function:
{
    use Test::More;
    use Test::Fatal;

    my $croaker = exception { die 'I croak!' };
    my $liver   = exception { 1 + 1 };

    like $croaker, qr/I croak/, 'die() should croak';
    is $liver, undef, 'addition should live';
}

# You might rewrite this more verbosely as:
{
    my $croaker = exception( sub { die 'I croak!' } );
    my $liver   = exception( sub { 1 + 1 } );
}

# ... or to pass named functions by reference:
{
    sub croaker { die 'I croak!' }
    sub liver   { 1 + 1 }

    my $croaker = exception \&croaker;
    my $liver   = exception \&liver;

    like $croaker, qr/I croak/, 'die() should die';
    is $liver, undef, 'addition should live';
}

# ... but you may not pass them as scalar references:
# {
#     my $croak_ref = \&croaker;
#     my $live_ref  = \&liver;
#
#     # BUGGY: does not work
#     my $croaker = exception $croak_ref;
#     my $liver   = exception $live_ref;
# }

# ... because the prototype changes the way the Perl parser interprets this code.
# It cannot determine with 100% clarity what $croaker and $liver will contain,
# and so will throw an exception.
#
#     Type of arg 1 to Test::Fatal::exception
#        must be block or sub {} (not private variable)

# A function which takes an anonymous function as the first of multiple arguments
# cannot have a trailing comma after the function block:
{
    use Test::More;
    use Test::Fatal 'dies_ok';

    dies_ok { die 'This is my boomstick!' } 'No movie references here';
}

# This is an occasionally confusing wart on otherwise helpful syntax,
# courtesy of a quirk of the Perl parser.
# The syntactic clarity available by promoting bare blocks to anonymous functions can be helpful,
# but use it sparingly and document the API with care.

done_testing();
