#!/usr/bin/env perl
# REF: http://modernperlbooks.com/books/modern_perl_2016/05-perl-functions.html#RnVuY3Rpb25QYXJhbWV0ZXJz

use 5.034;
use warnings;
use autodie;
use feature 'say';

use Test::More;

# A function receives its parameters in a single array, @_ (The Default Array Variables).
# When you invoke a function,
# Perl flattens all provided arguments into a single list.
# The function must either unpack its parameters into variables or operate on @_ directly:
sub greet_one {
    my ($name) = @_;
    say "Hello, $name!";
}

sub greet_all {
    say "Hello, $_!" for @_;
}

# @_ behaves as a normal array.
# Most Perl functions shift off parameters or use list assignment,
# but you may also access individual elements by index:
sub greet_one_shift {
    my $name = shift;
    say "Hello, $name!";
}

sub greet_two_list_assignment {
    my ( $hero, $sidekick ) = @_;
    say "Well if it isn't $hero and $sidekick. Welcome!";
}

sub greet_one_indexed {
    my $name = $_[0];
    say "Hello, $name!";

    # or, less clear
    say "Hello, $_[0]!";
}

# You may also unshift, push, pop, splice, and use slices of @_.
# Remember that the array builtins use @_ as the default operand within functions,
# so that my $name = shift; works.
# Take advantage of this idiom.

# To access a single scalar parameter from @_,
# use shift,
# an index of @_,
# or lvalue list context parentheses.
# Otherwise, Perl will happily evaluate @_ in scalar context for you
# and assign the number of parameters passed:
sub bad_greet_one {
    my $name = @_;    # buggy
    say "Hello, $name; you look numeric today!";
}

# List assignment of multiple parameters is often clearer than multiple lines of shift. Compare:
{
    my $left_value  = shift;
    my $operation   = shift;
    my $right_value = shift;
}

# ... to:
{
    my ( $left_value, $operation, $right_value ) = @_;
}

# The latter is simpler to read.
# As a side benefit, it has better runtime performance, though you're unlikely to notice.

# Occasionally you may see code which extracts parameters from @_
# and passes the rest to another function:
sub delegated_method {
    my $self = shift;

    say 'Calling delegated_method()'

    # $self->delegate->delegated_method( @_ );
}

# Use shift when your function needs only a single parameter.
# Use list assignment when accessing multiple parameters.

# ================================
# Real Function Signatures
# ================================

# Perl 5.20 added built-in function signatures as an experimental feature.
# "Experimental" means that they may change or even go away in future releases of Perl,
# so you need to enable them to signal that you accept the possibility of rewriting code.
# NOTE: It is enabled automatically by a use v5.36 (or higher) declaration,
#       or more directly by use feature 'signatures', in the current scope.
#       REF: https://perldoc.perl.org/perlsub#Signatures
use experimental 'signatures';

# With that disclaimer in place, you can now write:
sub greet_one_using_signature($name) {
    say "Hello, $name!";
}

# ... which is equivalent to writing:
sub greet_one_explicit {
    die "Too many arguments for subroutine" if @_ < 1;
    die "Too few arguments for subroutine"  if @_ > 1;
    my $name = shift;
    say "Hello, $name!";
}

# You can make $name an optional variable by assigning it a default value:
sub greet_one_with_default( $name = 'Bruce' ) {
    say "Hello, $name!";
}

# ... in which case writing greet_one( 'Bruce' ) and greet_one()
# will both ignore Batman's crime-fighting identity.

# You may use aggregate arguments at the end of a signature:
sub greet_all_using_signature( $leader, @everyone ) {
    say "Hello, $leader!";
    say "Hi also, $_." for @everyone;
}

sub make_nested_hash( $name, %pairs ) {
    return { $name => \%pairs };
}

# ... or indicate that a function expects no arguments:
sub no_gifts_please() {
    say 'I have too much stuff already.';
}

# ... which means that you'll get the Too many arguments for subroutine exception
# by calling that function with arguments.

# These experimental signatures have more features than discussed here.
# As you get beyond basic positional parameters,
# the possibility of incompatible changes in future versions of Perl increases, however.
# See perldoc perlsub's "Signatures" section for more details,
# especially in newer versions of Perl.

# Signatures aren't your only options.
# Several CPAN distributions extend Perl's parameter handling with additional syntax and options.
# Method::Signatures works as far back as Perl 5.8.
# Kavorka works with Perl 5.14 and newer.

# Despite the experimental nature of function signatures—
# or the additional dependencies of the CPAN modules—
# all of these options can make your code a little shorter and a little clearer both to read and to write.
# By all means experiment with these options to find out what works best for you and your team.
# Even sticking with simple positional parameters can improve your work.

# ================================
# Flattening
# ================================

# List flattening into @_ happens on the caller side of a function call.
# Passing a hash as an argument produces a list of key/value pairs:
{
    my %pet_names_and_types = (
        Lucky   => 'dog',
        Rodney  => 'dog',
        Tuxedo  => 'cat',
        Petunia => 'cat',
        Rosie   => 'dog',
    );

    show_pets(%pet_names_and_types);

    sub show_pets {
        my %pets = @_;

        while ( my ( $name, $type ) = each %pets ) {
            say "$name is a $type";
        }
    }
}

# When Perl flattens %pet_names_and_types into a list,
# the order of the key/value pairs from the hash will vary,
# but the list will always contain a key immediately followed by its value.
# Hash assignment inside show_pets() works the same way as the explicit assignment to %pet_names_and_types.

# This flattening is often useful,
# but beware of mixing scalars with flattened aggregates in parameter lists.
# To write a show_pets_of_type() function,
# where one parameter is the type of pet to display,
# pass that type as the first parameter
# (or use pop to remove it from the end of @_, if you like to confuse people):
{

    sub show_pets_by_type {
        my ( $type, %pets ) = @_;

        while ( my ( $name, $species ) = each %pets ) {
            next unless $species eq $type;
            say "$name is a $species";
        }
    }

    my %pet_names_and_types = (
        Lucky   => 'dog',
        Rodney  => 'dog',
        Tuxedo  => 'cat',
        Petunia => 'cat',
        Rosie   => 'dog',
    );

    show_pets_by_type( 'dog',   %pet_names_and_types );
    show_pets_by_type( 'cat',   %pet_names_and_types );
    show_pets_by_type( 'moose', %pet_names_and_types );
}

# With experimental function signatures, you could write:
sub show_pets_by_type_using_signature( $type, %pets ) {
    ...;
}

# ================================
# Slurping
# ================================

# List assignment with an aggregate is always greedy,
# so assigning to %pets slurps all of the remaining values from @_.
# If the $type parameter came at the end of @_,
# Perl would warn about assigning an odd number of elements to the hash.
# You could work around that:
sub show_pets_by_type_demo_slurping {
    my $type = pop;
    my %pets = @_;

    ...;
}

# ... at the expense of clarity.
# The same principle applies when assigning to an array as a parameter.
# Use references (References) to avoid unwanted aggregate flattening.

# ================================
# Aliasing
# ================================

# @_ contains a subtlety; it aliases function arguments.
# In other words, if you access @_ directly,
# you can modify the arguments passed to the function:
{

    sub modify_name {
        $_[0] = reverse $_[0];
    }

    my $name = 'Orange';
    modify_name($name);
    say $name;

    # prints egnarO
}

# Modify an element of @_ directly and you will modify the original argument.
# Be cautious and unpack @_ rigorously—or document the modification carefully.
