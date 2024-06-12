#!/usr/bin/env perl
# REF: http://modernperlbooks.com/books/modern_perl_2016/11-what-to-avoid-in-perl.html#V2hhdHRvQXZvaWQ

use 5.034;
use warnings;
use autodie;
use feature 'say';

use Test::More;

# Perl is a malleable language.
# You can write programs in whichever creative, maintainable, obfuscated, or bizarre fashion you prefer.
# Good programmers write code that they want to maintain,
# but Perl won't decide for you what you consider maintainable.

# Perl isn't perfect.
# Some features are difficult to use correctly.
# Others seem great but don't work all that well.
# Some have strange edge cases.
# Knowing what to avoid in Perl—and when to avoid it—
# will help you write robust code that survives the twin tests of time and real users.

# ================================
# Barewords: See 091-barewords
# ================================

# ================================
# TODO: review Indirect Objects
# ================================

# Perl is not a pure object-oriented language.
# It has no operator (new);
# a constructor is anything which returns an object.
# By convention, constructors are class methods named (new()),
# but you can name these methods anything you want, or even use functions.
# Several old Perl OO tutorials promote the use of C++ and Java-style constructor calls:
# {
#     my $q = new Alces; # DO NOT USE
# }
# ... instead of the obvious method call:
# {
#     my $q = Alces->new;
# }
# These examples produce equivalent behavior, except when they don't.

# ================================
# Indirect Objects - Bareword Indirect Invocations
# ================================

# In the indirect object form (more precisely, the dative case) of the first example,
# the method precedes the invocant.
# This is fine in spoken languages where verbs and nouns are more obvious,
# but it introduces parsing ambiguities in Perl.

# Because the method's name is a bareword (Barewords),
# the parser uses several heuristics to figure out the proper interpretation of this code.
# While these heuristics are well-tested and almost always correct,
# their failure modes are confusing.
# Things get worse when you pass arguments to a constructor:
# {
#     my $obj = new Class( arg => $value ); # DO NOT USE
# }
# In this example, the name of the class looks like a function call.
# Perl can and does often get this right,
# but its heuristics depend on which package names the parser has seen,
# which barewords it has already resolved,
# how it resolved those barewords,
# and the names of functions already declared in the current package.
# For an exhaustive list of these conditions,
# you have to read the source code of Perl's parser—
# not something the average Perl programmer wants to do
# (see intuit_method in toke.c, if you're really curious—but feel free to forget this suggestion ever existed).

# Imagine running afoul of a prototyped function (Prototypes)
# with a name which just happens to conflict somehow with the name of a class or a method called indirectly,
# such as a poorly-named JSON() method in the same file where the JSON module is used,
# to pick an example that actually happened.
# This is rare, but it's very unpleasant to debug.
# Avoid indirect invocations instead.

# ================================
# Indirect Objects - Indirect Notation Scalar Limitations
# ================================

# Another danger of the indirect syntax is that
# the parser expects a single scalar expression as the object.
# Printing to a filehandle stored in an aggregate variable seems obvious, but it is not:
# {
#     # DOES NOT WORK
#     say $config->{output} 'Fun diagnostic message!';
# }
# Perl will attempt to call say on the $config object.

# print, close, and say—all builtins which operate on filehandles—operate in an indirect fashion.
# This was fine when filehandles were package globals,
# but lexical filehandles (Filehandle References) make the indirect object syntax problems obvious.
# To solve this, disambiguate the subexpression which produces the intended invocant:
# {
#     say {$config->{output}} 'Fun diagnostic message!';
# }

# ================================
# Indirect Objects - Alternatives to Indirect Notation
# ================================

# Direct invocation notation does not suffer this ambiguity problem.
# To construct an object, call the constructor method on the class name directly:
# {
#     my $q   = Plack::Request->new;
#     my $obj = Class->new( arg => $value );
# }

# This syntax still has a bareword problem in that
# if you have a function named Request in the Plack namespace,
# Perl will interpret the bareword class name as a call to the function, as:
# {
#     sub Plack::Request;
#
#     # you wrote Plack::Request->new, but Perl saw
#     my $q = Plack::Request()->new;
# }

# Disambiguate this syntax as usual (Bareword package names).

# For the limited case of filehandle operations,
# the dative use is so prevalent that you can use the indirect invocation approach
# if you surround your intended invocant with curly brackets.
# You can use methods on lexical filehandles,
# though almost no one ever does this for print and say.

# The CPAN module Perl::Critic::Policy::Dynamic::NoIndirect (a plugin for Perl::Critic)
# can analyze your code to find indirect invocations.
# The CPAN module (indirect) can identify and prohibit their use in running programs:
# {
#     # warn on indirect use
#     no indirect;

#     # throw exceptions on their use
#     no indirect ':fatal';
# }

# ================================
# Prototypes: See 092-prototypes
# ================================

# ================================
# Method-Function Equivalence
# ================================

# Perl's object system is deliberately minimal (Blessed References).
# A class is a package,
# and Perl does not distinguish between a function and a method stored in a package.
# The same builtin, sub, declares both.
# Perl will happily dispatch to a function called as a method.
# Likewise, you can invoke a method as if it were a function—
# fully-qualified, exported, or as a reference—
# if you pass in your own invocant manually.

# Invoking the wrong thing in the wrong way causes problems.

# ================================
# Method-Function Equivalence - Caller-side
# ================================

# Consider a class with several methods:
package Order {

    use List::Util 'sum';

    sub calculate_price {
        my $self = shift;
        return sum( 0, $self->get_items );
    }

    ...;
}

sub {
    my $o = Order->new;

# Given an (Order) object $o, the following invocations of this method may seem equivalent:
    my $price_1 = $o->calculate_price;

    # broken; do not use
    my $price_2 = Order::calculate_price($o);

    # Though in this simple case,
    # they produce the same output,
    # the latter violates object encapsulation by bypassing method lookup.

# If $o were instead a subclass or allomorph (Roles) of (Order)
# which overrode calculate_price(),
# that example has just called the wrong method.
# Any change to the implementation of calculate_price(),
# such as a modification of inheritance or delegation through AUTOLOAD()—might break calling code.

    # Perl has one circumstance where this behavior may seem necessary.
    # If you force method resolution without dispatch,
    # how do you invoke the resulting method reference?
    my $meth_ref = $o->can('apply_discount');

    # There are two possibilities.
    # The first is to discard the return value of the can() method:
    $o->apply_discount if $o->can('apply_discount');

    # The second is to use the reference itself with method invocation syntax:
    if ( my $meth_ref = $o->can('apply_discount') ) {
        $o->$meth_ref();
    }

    # When $meth_ref contains a function reference,
    # Perl will invoke that reference with $o as the invocant.
    # This works even under strictures,
    # as it does when invoking a method with a scalar containing its name:
    my $name = 'apply_discount';
    $o->$name();
};

# There is one small drawback in invoking a method by reference;
# if the structure of the program changes between storing the reference and invoking the reference,
# the reference may no longer refer to the most appropriate method.
# If the Order class has changed such that Order::apply_discount is no longer the right method to call,
# the reference in $meth_ref will not have updated.

# That's an unlikely circumstance,
# but limit the scope of a method reference when you use this invocation form just in case.

# ================================
# Method-Function Equivalence - Callee-side
# ================================

# Because it's possible (however inadvisable) to invoke a given function as a function or a method,
# it's possible to write a function callable as either.

# The CGI module has these two-faced functions.
# Every one of them must apply several heuristics to determine whether the first argument is an invocant.
# This causes problems.
# It's difficult to predict exactly which invocants are potentially valid for a given method,
# especially when you may have to deal with subclasses.
# Creating an API that users cannot easily misuse is more difficult too,
# as is your documentation burden.
# What happens when one part of the project uses the procedural interface
# and another uses the object interface?

# If you must provide a separate procedural and OO interface to a library,
# create two separate APIs.

# ================================
# Automatic Dereferencing
# ================================

# !!! This is already removed since Perl v5.24.0.
# See https://perldoc.perl.org/perl5240delta#Incompatible-Changes.
# REF: https://www.perlmonks.org/?node_id=1190788

# ================================
# TODO: review Tie
# ================================

# Where overloading (Overloading) allows you to customize the behavior of classes and objects
# for specific types of coercion,
# a mechanism called tying allows you to customize the behavior of primitive variables
# (scalars, arrays, hashes, and filehandles).
# Any operation you might perform on a tied variable translates to a specific method call on an object.

# For example, the (tie) builtin allows
# core Tie::File module to treat files as if they were arrays of records,
# letting you push and pop and shift as you see fit.
# (tie was intended to use file-backed stores for hashes and arrays,
# so that Perl could use data too large to fit in available memory.
# RAM was more expensive 20 years ago.)

# The class to which you tie a variable
# must conform to a defined interface for a specific data type.
# Read perldoc perltie for an overview,
# then see the core modules Tie::StdScalar, Tie::StdArray, and Tie::StdHash for specific details.
# Start by inheriting from one of those classes,
# then override any specific methods you need to modify.

# If tie weren't confusing enough,
# Tie::Scalar, Tie::Array, and Tie::Hash
# define the necessary interfaces to tie scalars, arrays, and hashes,
# but Tie::StdScalar, Tie::StdArray, and Tie::StdHash provide the default implementations.

# ================================
# Tie - Tying Variables
# ================================

# To tie a variable:
# {
#     use Tie::File;
#     tie my @file, 'Tie::File', @args;
# }
# The first operand is the variable to tie.
# The second is the name of the class into which to tie it.
# @args is an optional list of arguments required for the tying function.
# In the case of Tie::File, @args should contain a valid filename.

# Tying functions resemble constructors:
# TIESCALAR, TIEARRAY(), TIEHASH(), or TIEHANDLE()
# for scalars, arrays, hashes, and filehandles respectively.
# Each function returns a new object which represents the tied variable.
# Both (tie) and (tied) return this object,
# though most people use tied in a boolean context.

# ================================
# Tie - Implementing Tied Variables
# ================================

# To implement the class of a tied variable,
# inherit from a core module such as Tie::StdScalar,
# Then override the specific methods for the operations you want to change.
# In the case of a tied scalar,
# these are likely FETCH and STORE,
# possibly TIESCALAR(), and probably not DESTROY().

# Here's a class which logs all reads from and writes to a scalar:
package Tie::Scalar::Logged {
    use Tie::Scalar;
    use parent -norequire => 'Tie::StdScalar';

    sub STORE {
        my ( $self, $value ) = @_;
        Logger->log( "Storing <$value> (was [$$self])", 1 );
        $$self = $value;
    }

    sub FETCH {
        my $self = shift;
        Logger->log( "Retrieving <$$self>", 1 );
        return $$self;
    }
}

# Assume that the Logger class method log() takes a string
# and the number of frames up the call stack of which to report the location.

# Within the STORE() and FETCH() methods,
# $self works as a blessed scalar.
# Assigning to that scalar reference changes the value of the scalar.
# Reading from it returns its value.

# Similarly, the methods of Tie::StdArray and Tie::StdHash
# act on blessed array and hash references, respectively.
# Again, perldoc perltie explains the methods tied variables support,
# such as reading or writing multiple values at once.

# The -norequire option prevents the parent pragma from attempting to load a file for Tie::StdScalar,
# as that module is part of the file Tie/Scalar.pm.
# That's right, there's no .pm file for Tie::StdScalar. Isn't this fun?

# ================================
# Tie - When to use Tied Variables
# ================================

# Tied variables seem like fun opportunities for cleverness,
# but they can produce confusing interfaces.
# Unless you have a very good reason for making objects behave as if they were builtin data types,
# avoid creating your own ties without good reason.
# tied variables are also much slower than builtin data types.

# With that said, tied variables can help you debug tricky code
# (use the logged scalar to help you understand where a value changes)
# or to make certain impossible things possible
# (access large files without running out of memory).
# Tied variables are less useful as the primary interfaces to objects;
# it's often too difficult and constraining to try to fit your whole interface to that supported by tie().

# A final word of warning is a sad indictment of lazy programming:
# a lot of code goes out of its way to prevent use of tied variables, often by accident.
# This is unfortunate, but library code is sometimes fast and lazy with what it expects,
# and you can't always fix it.

done_testing();
