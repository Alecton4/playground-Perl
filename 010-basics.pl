#!/usr/bin/env perl
# REF: http://modernperlbooks.com/books/modern_perl_2016/03-perl-language.html

use 5.034;
use warnings;
use autodie;
use feature 'say';

use Test::More;

# ================================
# Names
# ================================

# Valid Perl names all begin with a letter or an underscore
# and may optionally include any combination of letters, numbers, and underscores.

# Only Perl's parser enforces the rules about identifier names.
# You may also refer to entities with names generated at runtime or provided as input to a program.
# REF: https://perl.plover.com/varvarname.html

# Variable names always have a leading sigil (a symbol)
# which indicates the type of the variable's value. # ??? Should be the type of container instead of type of value?

# Scalar variables (Scalars) use the dollar sign ($).
# Array variables (Arrays) use the at sign (@).
# Hash variables (Hashes) use the percent sign (%)

# It's possible to declare multiple variables of the same name with different types
sub vars_with_same_names {
    my ( $bad_name, @bad_name, %bad_name );
}

# ================================
# Names - Variable Names and Sigils
# ================================

# The sigil of a variable changes depending on its use;
# this change is called variant sigils.
# Given Perl's variant sigils,
# the most reliable way to determine the type of a variable—
# scalar, array, or hash—
# is to observe the operations performed on it.
# Arrays support indexed access through square brackets.
# Hashes support keyed access through curly brackets.
# Scalars have neither.

# ================================
# Names - Namespaces
# ================================

# Perl allows multi-level namespaces, with names joined by double colons (::).
# All namespaces in Perl are globally visible.
# When Perl looks up a symbol in DessertShop::IceCream::Freezer,
# it looks in the main:: symbol table for a symbol representing the DessertShop:: namespace,
# in that namespace for the IceCream:: namespace, and so on.
# Yet Freezer:: is visible from outside of the IceCream:: namespace.
# The nesting of the former within the latter is only a storage mechanism;
# it implies nothing about relationships between parent and child or sibling packages.

# ================================
# Variables
# ================================

# A variable in Perl is a storage location for a value (Values).
# While a trivial program may manipulate values directly,
# most programs work with variables.
# Think of this like algebra: you manipulate symbols to describe formulas.
# It's easier to explain the Pythagorean theorem in terms of the variables a, b, and c
# than by intuiting its principle by producing a long list of valid values.

# ================================
# Variables - Variable Scopes
# ================================

# Most variables in modern Perl programs have a lexical scope (Lexical Scope)
# governed by the syntax of the program as written.
# Most lexical scopes are either the contents of blocks delimited by curly braces ({ and })
# or entire files.

# Files themselves provide their own lexical scopes,
# such that a package declaration on its own does not create a new scope:
package Store::Toy;
my $discount = 0.10;

package Store::Music;
say "Our current discount is $discount!";    # $discount still visible

# You may also provide a block to the package declaration.
# Because this introduces a new block, it also provides a new lexical scope:
{

    package Store::Toy {
        my $discount = 0.10;
    }

    package Store::Music {

        # $discount not visible
    }

    package Store::BoardGame;

    # $discount still not visible
}

# ================================
# Vriables - Variable Sigils
# ================================

# The sigil of the variable in a declaration determines the type of the variable:
# scalar, array, or hash.
# The sigil used when accessing a variable varies depending on what you do to the variable.
# For example, you declare an array as @values.
# Access the first element—a single value—of the array with $values[0].
# Access a list of values from the array with @values[ @indices ].

# The sigil you use determines amount context in an lvalue situation:
# {
#     # imposes lvalue context on some_function()
#     @values[@indexes] = some_function();
# }
# or gets coerced in an rvalue situation:
# {
#     # list evaluated to final element in scalar context
#     my $element = @values[@indices];
# }

# ================================
# Variables - Anonymous Variables
# ================================

# Perl variables do not require names.
# Names exist to help you, the programmer, keep track of an $apple, @barrels, or %cookie_recipes.
# Variables created without literal names in your source code are anonymous.
# The only way to access anonymous variables is by reference (References).

# ================================
# Variables - Variables, Types, and Coercion
# ================================

# A Perl variable represents both a value
# (a dollar cost, available pizza toppings, the names and numbers of guitar stores)
# and the container which stores that value.
# Perl's type system deals with value types and container types.

# While a variable's container type—scalar, array, or hash—cannot change,
# Perl is flexible about a variable's value type.
# You may store a string in a variable in one line,
# append to that variable a number on the next,
# and reassign a reference to a function (Function References) on the third,
# though this is a great way to confuse yourself.

# Performing an operation on a variable
# which imposes a specific value type
# may cause coercion (Coercion) of the variable's existing value type.

# For example, the documented way to determine the number of entries in an array
# is to evaluate that array in scalar context (Context).
# Because a scalar variable can only ever contain a scalar,
# assigning an array (the rvalue) to a scalar (the lvalue) imposes scalar context on the operation,
# and an array evaluated in scalar context produces the number of elements in the array:
# {
#     my $count = @items;
# }

# ================================
# Values: See 011-values
# ================================

# ================================
# Control Flow: See 012-control-flow
# ================================

# ================================
# Scalars: See 013-scalars
# ================================

# ================================
# Arrays: See 014-arrays
# ================================

# ================================
# Hashes: See 015-hashes
# ================================

# ================================
# Coercion
# ================================

# Throughout the lifetime of a Perl variable,
# it may contain values of different types—
# strings, integers, rational numbers, and more.
# Instead of attaching type information to variables,
# Perl relies on the context provided by operators (Numeric, String, and Boolean Context)
# to determine how to handle values.
# By design, Perl attempts to do what you mean—
# you may hear this referred to as DWIM for do what I mean or dwimmery.>—
# though you must be specific about your intentions.
# If you treat a value as a string,
# Perl will do its best to coerce that value into a string.

# ================================
# Coercion - Boolean Coercion
# ================================

# Boolean coercion occurs when you test the truthiness of a value,
# such as in an if or while condition.

# NOTE: Numeric 0, undef, the empty string, and the string '0' all evaluate as false values.
# All other values—
# including strings which may be numerically equal to zero (such as '0.0', '0e', and '0 but true')—
# evaluate as true values.

# When a scalar has both string and numeric components (Dualvars),
# Perl prefers to check the string component for boolean truth.
# '0 but true' evaluates to zero numerically,
# but it is not an empty string,
# so it evaluates to a true value in boolean context.

# ================================
# Coercion - String Coercion
# ================================

# String coercion occurs when using string operators
# such as comparisons (eq and cmp), concatenation, split, substr, and regular expressions,
# as well as when using a value or an expression as a hash key.

# The undefined value stringifies to an empty string but produces a "use of uninitialized value" warning.
# Numbers stringify to strings containing their values; the value 10 stringifies to the string 10.
# You can even split a number into individual digits with:
{
    my @digits = split '', 1234567890;
}

# ================================
# Coercion - Numeric Coercion
# ================================

# Numeric coercion occurs when using numeric comparison operators (such as == and <=>),
# when performing mathematic operations,
# and when using a value or expression as an array or list index.

# The undefined value numifies to zero and produces a "Use of uninitialized value" warning.
# Strings which do not begin with numeric portions numify to zero and produce an "Argument isn't numeric" warning.
# Strings which begin with characters allowed in numeric literals numify to those values and produce no warnings,
# such that (10 leptons leaping) numifies to 10
# and (6.022e23 moles marauding) numifies to 6.022e23.

# The core module Scalar::Util contains a looks_like_number() function
# which uses the same rules as the Perl parser to extract a number from a string.

# The strings (Inf) and (Infinity) represent the infinite value and behave as numbers.
# The string (NaN) represents the concept "not a number".
# The above strings are case-insensitive.
# Numifying them produces no "Argument isn't numeric" warning.
# Beware that Perl's ideas of infinity and not a number may not match your platform's ideas;
# these notions aren't always portable across operating systems.
# Perl is consistent even if the rest of the universe isn't.
sub demo_inf_and_nan {
    my $a = "inf";
    my $b = "infinity";
    my $c = "nan";

    say $a == $b ? "true" : "false";
    say $a eq $b ? "true" : "false";
    say $a >= 0  ? "true" : "false";
    say $a <= 0  ? "true" : "false";
    say $c >= 0  ? "true" : "false";
    say $c <= 0  ? "true" : "false";
    say $a >= $c ? "true" : "false";
    say $a <= $c ? "true" : "false";
}

demo_inf_and_nan();

# ================================
# Coercion - Reference Coercion
# ================================

# TODO: review
# Using a dereferencing operation on a non-reference turns that value into a reference.
# This process of autovivification (Autovivification) is handy
# when manipulating nested data structures (Nested Data Structures):
{
    my %users;

    $users{Brad}{id} = 228;
    $users{Jack}{id} = 229;
}

# Although the hash never contained values for Brad and Jack,
# Perl helpfully created hash references for them,
# then assigned each a key/value pair keyed on id.

# ================================
# Coercion - Cached Coercions
# ================================

# Perl's internal representation of values stores both string and numeric values.
# Stringifying a numeric value does not replace the numeric value.
# Instead, it adds a stringified value to the internal representation,
# which then contains both components.
# Similarly, numifying a string value populates the numeric component
# while leaving the string component untouched.

# Certain Perl operations prefer to use one component of a value over another—
# boolean checks prefer strings, for example.
# If a value has a cached representation in a form you do not expect,
# relying on an implicit conversion may produce surprising results.
# You almost never need to be explicit about what you expect.
# Your author can recall doing so twice in two decades.
# Even so, knowing that this caching occurs may someday help you diagnose an odd situation.

# ================================
# Dualvars
# ================================

# The multi-component nature of Perl values is available to users in the form of dualvars.
# The core module Scalar::Util provides a function dualvar()
# which allows you to bypass Perl coercion
# and manipulate the string and numeric components of a value separately:
sub demo_dualvar {
    use Scalar::Util 'dualvar';
    my $false_name = dualvar 0, 'Sparkles & Blue';

    say 'Boolean true!' if !!$false_name;
    say 'Numeric false!' unless 0 + $false_name;
    say 'String true!' if '' . $false_name;
}

# ================================
# Packages
# ================================

# A Perl namespace associates and encapsulates various named entities.
# It's like your family name or a brand name.
# Unlike a real-world name, a namespace implies no direct relationship between entities.
# Such relationships may exist, but they are not required to.

# A package in Perl is a collection of code in a single namespace.
# The distinction is subtle:
# the package represents the source code
# and the namespace represents the internal data structure Perl uses to collect and group that code.

# The package builtin declares a package and a namespace:
{

    package MyCode;

    our @boxes;

    sub add_box { ... }
}

# All global variables and functions declared or referred to after the package declaration
# refer to symbols within the MyCode namespace.
# You can refer to the @boxes variable from the main namespace only by its fully qualified name of @MyCode::boxes.
# A fully qualified name includes a complete package name,
# so that you can call the add_box() function by MyCode::add_box().

# The scope of a package continues until the next package declaration or the end of the file,
# whichever comes first.
# You may also provide a block with package to delineate the scope of the declaration:
package Pinball::Wizard {
    our $VERSION = 1969;
}

# The default package is the main package.
# Without a package declaration, the current package is main.
# This rule applies to one-liners, standalone programs, and even .pm files.

# NOTE: Review when needed.
# Besides a name, a package has a version
# and three implicit methods, import() (Importing), unimport(), and VERSION().
# VERSION() returns the package's version.
# This is a series of numbers contained in a package global named $VERSION.
# By rough convention, versions are a series of dot-separated integers such as 1.23 or 1.1.10.

# Perl includes a stricter syntax for version numbers,
# as documented in perldoc version::Internals.
# These version numbers must have a leading v character
# and at least three integer components separated by periods:
{

    package MyCode v1.2.1;
}

# Combined with the block form of a package declaration, you can write:
# {
#     package Pinball::Wizard v1969.3.7 { ... }
# }

# You're more likely to see the older version of this code, written as:
{

    package MyCode;

    our $VERSION = 1.21;
}

# Every package inherits a VERSION() method from the UNIVERSAL base class.
# This method returns the value of $VERSION:
{
    my $version = Some::Plugin->VERSION;
}

# If you provide a version number as an argument,
# this method will throw an exception unless the version of the module is equal to or greater than the argument:
# {
#     # require at least 2.1
#     Some::Plugin->VERSION(2.1);
#
#     die "Your plugin $version is too old" unless $version > 2;
# }

# You may override VERSION(), though there are few reasons to do so.

# ================================
# Packages - Packages and Namespaces
# ================================

# Every package declaration creates a new namespace, if necessary.
# After Perl parses that declaration,
# it will store all subsequent package global symbols (global variables and functions) in that namespace.

# Perl has open namespaces.
# You can add functions or variables to a namespace at any point,
# either with a new package declaration:
{

    package Pack {
        sub first_sub { ... }
    }

    # Pack::first_sub();

    package Pack {
        sub second_sub { ... }
    }

    # Pack::second_sub();
}

# ... or by declaring functions with fully qualified names:
{
    # implicit
    package main;

    sub Pack::third_sub { ... }
}

# You can add to a package at any point during compilation or runtime,
# regardless of the current file,
# though building up a package from multiple declarations in multiple files can make code difficult to spelunk.

# Namespaces can have as many levels as your organizational scheme requires,
# though namespaces are not hierarchical.
# The only relationship between separate packages is semantic, not technical.
# Many projects and businesses create their own top-level namespaces.
# This reduces the possibility of global conflicts and helps to organize code on disk.
# For example:
#
#     StrangeMonkey is the project name
#     StrangeMonkey::UI organizes user interface code
#     StrangeMonkey::Persistence organizes data management code
#     StrangeMonkey::Test organizes testing code for the project
#
# ... and so on. This is a convention, but it's a useful one.

# ================================
# References: See 016-references
# ================================

# ================================
# Nested Data Structures: See 017-nested-data-structures
# ================================

done_testing();
