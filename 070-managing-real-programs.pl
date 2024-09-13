#!/usr/bin/env perl
# REF: http://modernperlbooks.com/books/modern_perl_2016/09-managing-real-programs.html#TWFuYWdpbmdSZWFsUHJvZ3JhbXM

use 5.034;
use warnings;
use autodie;
use feature 'say';

use Test::More;

# You can learn a lot of syntax from a book
# by writing small programs to solve the example problems.
# Writing good code to solve real problems takes more discipline and understanding.
# You must learn to manage code.
# How do you know that it works?
# How do you organize it?
# What makes it robust in the face of errors?
# What makes code clean? Clear? Maintainable?

# ================================
# Testing: See 071-testing
# ================================

# ================================
# Handling Warnings: See 072-handling-warnings
# ================================

# ================================
# Files: See 073-files
# ================================

# ================================
# Modules: See 074-modules
# ================================

# ================================
# Distributions: See 075-distributions
# ================================

# ================================
# The UNIVERSAL Package
# ================================

# Perl's builtin UNIVERSAL package is the ancestor of all other packages—
# it's the ultimate parent class in the object-oriented sense (Moose).
# UNIVERSAL provides a few methods for its children to use, inherit, or override.

# ================================
# The UNIVERSAL Package - The VERSION() Method
# ================================

# The VERSION() method returns the value of the $VERSION variable of the invoking package or class.
# If you provide a version number as an optional parameter,
# the method will throw an exception
# if the queried $VERSION is not equal to or greater than the parameter.

# Given a HowlerMonkey module of version 1.23, its VERSION() method behaves as:
# {
#     my $hm = HowlerMonkey->new;
#
#     say HowlerMonkey->VERSION;    # prints 1.23
#     say $hm->VERSION;             # prints 1.23
#     say $hm->VERSION( 0.0  );     # prints 1.23
#     say $hm->VERSION( 1.23 );     # prints 1.23
#     say $hm->VERSION( 2.0  );     # exception!
# }

# There's little reason to override VERSION().

# ================================
# The UNIVERSAL Package - The DOES() Method
# ================================

# The DOES() method supports the use of roles (Roles) in programs.
# Pass it an invocant and the name of a role,
# and the method will return true if the appropriate class somehow does that role
# through inheritance, delegation, composition, role application, or any other mechanism.

# The default implementation of DOES() falls back to isa(),
# because inheritance is one mechanism by which a class may do a role.

# Given a Cappuchin, its DOES() method behaves as:
# {
#     say Cappuchin->DOES( 'Monkey'       );  # prints 1
#     say $cappy->DOES(    'Monkey'       );  # prints 1
#     say Cappuchin->DOES( 'Invertebrate' );  # prints 0
# }

# Override DOES() if you manually consume a role
# or otherwise somehow provide allomorphic equivalence.

# ================================
# The UNIVERSAL Package - The can() Method
# ================================

# The can() method takes a string containing the name of a method or function.
# It returns a function reference, if it exists.
# Otherwise, it returns a false value.
# You may call this on a class, an object, or the name of a package.

# Given a class named SpiderMonkey with a method named screech, get a reference to the method with:
# {
#     if (my $meth = SpiderMonkey->can( 'screech' )) {...}
# }

# NOTE: This technique leads to the pattern of checking for a method's existence before dispatching to it:
# {
#     if (my $meth = $sm->can( 'screech' ) {
#         # method; not a function
#         $sm->$meth();
#     }
# }

# Use can() to test if a package implements a specific function or method:
# {
#     use Class::Load;
#
#     die "Couldn't load $module!" unless load_class( $module );
#
#     if (my $register = $module->can( 'register' )) {
#         # function; not a method
#         $register->();
#     }
# }

# The CPAN module Class::Load simplifies the work of loading classes by name.
# Module::Pluggable makes it easier to build and manage plugin systems.
# Get to know both distributions.

# ================================
# The UNIVERSAL Package - The isa() Method
# ================================

# The isa() method takes a string containing the name of a class
# or the name of a core type (SCALAR, ARRAY, HASH, Regexp, IO, and CODE).
# Call it as a class method or an instance method on an object.
# isa() returns a true value if its invocant is or derives from the named class,
# or if the invocant is a blessed reference to the given type.

# Given an object $pepper
# (a hash reference blessed into the Monkey class,
# which inherits from the Mammal class),
# its isa() method behaves as:
# {
#     say $pepper->isa( 'Monkey'  );  # prints 1
#     say $pepper->isa( 'Mammal'  );  # prints 1
#     say $pepper->isa( 'HASH'    );  # prints 1
#     say Monkey->isa(  'Mammal'  );  # prints 1
#
#     say $pepper->isa( 'Dolphin' );  # prints 0
#     say $pepper->isa( 'ARRAY'   );  # prints 0
#     say Monkey->isa(  'HASH'    );  # prints 0
# }

# Any class may override isa().
# This can be useful when working with mock objects
# (Test::MockObject and Test::MockModule, for example)
# or with code that does not use roles (Roles).
# Be aware that any class which does override isa() generally has a good reason for doing so.

# While both UNIVERSAL::isa() and UNIVERSAL::can() are methods (Method-Function Equivalence),
# you may safely use the latter as a function solely to determine whether a class exists in Perl.
# If UNIVERSAL::can( $classname, 'can' ) returns a true value,
# someone somewhere has defined a class of the name $classname.
# That class may not be usable, but it does exist.

# ================================
# The UNIVERSAL Package - Extending UNIVERSAL
# ================================

# It's tempting to store other methods in UNIVERSAL
# to make them available to all other classes and objects in Perl.
# Avoid this temptation; this global behavior can have subtle side effects,
# especially in code you didn't write and don't maintain.

# With that said, occasional abuse of UNIVERSAL for debugging purposes
# and to fix improper default behavior may be excusable.
# For example, Joshua ben Jore's UNIVERSAL::ref distribution
# makes the nearly-useless ref() operator usable.
# The UNIVERSAL::can and UNIVERSAL::isa distributions can help you debug anti-polymorphism bugs (Method-Function Equivalence).
# Perl::Critic can detect those and other problems.

# Outside of very carefully controlled code and very specific,
# very pragmatic situations,
# there's no reason to put code in UNIVERSAL directly,
# especially given the other design alternatives.

# ================================
# Code Generation: See 076-code-generation
# ================================

# ================================
# Overloading
# ================================

# Perl is not a pervasively object oriented language.
# Its core data types (scalars, arrays, and hashes) are not objects with methods,
# but you can control the behavior of your own classes and objects,
# especially when they undergo coercion or contextual evaluation.
# This is overloading.

# Overloading is subtle but powerful.
# Consider how an object behaves in boolean context.
# In boolean context, an object will evaluate to a true value, unless you overload boolification.
# Why would you do this?
# Suppose you're using the Null Object pattern http://www.c2.com/cgi/wiki?NullObject
# to make your own objects appear false in boolean context.

# You can overload an object's behavior for almost every operation or coercion:
# stringification,
# numification,
# boolification,
# iteration,
# invocation,
# array access,
# hash access,
# arithmetic operations,
# comparison operations,
# smart match,
# bitwise operations,
# and even assignment.

# Stringification, numification, and boolification are the most important and most common.

# ================================
# Overloading - Overloading Common Operations
# ================================

# The overload pragma associates functions with overloadable operations.
# Pass the pragma argument pairs,
# where the key is the name of a type of overload
# and the value is a function reference.
# A Null class which overloads boolean evaluation so that it always evaluates to a false value might resemble:
{
    package Null {
        use overload 'bool' => sub { 0 };

        ...
    }
}
# It's easy to add a stringification:
{
    package Null {
        use overload
            'bool' => sub { 0 },
            '""'   => sub { '(null)' };
    }
}
# Overriding numification is more complex,
# because arithmetic operators tend to be binary ops (Arity).
# Given two operands both with overloaded methods for addition,
# which overloading should take precedence?
# The answer needs to be consistent, easy to explain,
# and understandable by people who haven't read the source code of the implementation.

# perldoc overload attempts to explain this
# in the sections labeled Calling Conventions for Binary Operations and MAGIC AUTOGENERATION,
# but the easiest solution is to overload numification (keyed by '0+')
# and tell overload to use the provided overloads as fallbacks:
{
    package Null {
        use overload
            'bool'   => sub { 0 },
            '""'     => sub { '(null)' },
            '0+'     => sub { 0 },
            fallback => 1;
    }
}
# Setting fallback to a true value
# gives Perl the option to use any other defined overloads to perform an operation.
# If that's not possible,
# Perl will act as if there were no overloads in effect.
# This is often what you want.

# Without fallback, Perl will only use the specific overloadings you have provided.
# If someone tries to perform an operation you have not overloaded,
# Perl will throw an exception.

# ================================
# Overloading - Overload and Inheritance
# ================================

# Subclasses inherit overloadings from their ancestors.
# They may override this behavior in one of two ways.

# If the parent class defines overloadings in terms of function references,
# a child class must do the same to override its parent's behavior.

# The alternative is to define overloadings in terms of method name.
# This allows child classes to customize their behavior by overriding those methods:
{
    package Null {
        use overload
            'bool'   => 'get_bool',
            '""'     => 'get_string',
            '0+'     => 'get_num',
            fallback => 1;

        sub get_bool { 0 }
    }
}
# Any child class can do something different for boolification by overriding get_bool():
# {
#     package Null::ButTrue {
#         use parent 'Null';

#         sub get_bool { 1 }
#     }
# }

# ================================
# Overloading - Uses of Overloading
# ================================

# Overloading may seem like a tempting tool to use to produce symbolic shortcuts for new operations.
# The IO::All CPAN distribution pushes this idea to its limit to produce a simple and elegant API.
# Yet for every brilliant API refined through the appropriate use of overloading,
# a dozen more messes congeal.
# Sometimes the best code eschews cleverness in favor of simplicity.

# Overriding addition, multiplication, and even concatenation on a Matrix class makes sense
# because the existing notation for those operations is pervasive.
# A new problem domain without that established notation is a poor candidate for overloading,
# as is a problem domain where you have to squint to make Perl's existing operators match a different notation.

# Damian Conway's Perl Best Practices suggests one other use for overloading:
# to prevent the accidental abuse of objects.
# For example, overloading numification to croak() for objects
# which have no reasonable single numeric representation
# can help you find and fix real bugs.

# ================================
# TODO: review Taint
# ================================

# Some Perl features can help you write secure programs.
# These tools are no substitute for careful thought and planning,
# but they reward caution and understanding
# and can help you avoid subtle mistakes.

# Taint mode (or taint) is a sticky piece of metadata attached to all data
# which comes from outside of your program.
# Any data derived from tainted data is also tainted.
# You may use tainted data within your program,
# but if you use it to affect the outside world—if you use it insecurely—Perl will throw a fatal exception.

# ================================
# Taint - Using Taint Mode
# ================================

# perldoc perlsec explains taint mode in copious detail.

# Launch your program with the -T command-line argument to enable taint mode.
# If you use this argument on the #! line of a program,
# you must run the program directly.
# If you run it as perl mytaintedappl.pl and neglect the -T flag,
# Perl will exit with an exception—
# by the time Perl encounters the flag on the #! line,
# it's missed its opportunity to taint the environment data in %ENV, for example.

# ================================
# Taint - Sources of Taint
# ================================

# Taint can come from two places:
# file input and the program's operating environment.
# The former is anything you read from a file
# or collect from users in the case of web or network programming.
# The latter includes any command-line arguments,
# environment variables,
# and data from system calls.
# Even operations such as reading from a directory handle produce tainted data.

# The tainted() function from the core module Scalar::Util returns true if its argument is tainted:
# {
#     die 'Oh no! Tainted data!' if Scalar::Util::tainted( $sketchy_data );
# }

# ================================
# Taint - Removing Taint from Data
# ================================

# To remove taint, you must extract known-good portions of the data with a regular expression capture.
# That captured data will be untainted.
# For example, if your user input consists of a US telephone number, you can untaint it with:
# {
#     die 'Number still tainted!' unless $number =~ /(\(/d{3}\) \d{3}-\d{4})/;
#
#     my $safe_number = $1;
# }

# The more specific your pattern is about what you allow,
# the more secure your program can be.
# The opposite approach of denying specific items or forms
# runs the risk of overlooking something harmful.
# Far better to disallow something that's safe but unexpected
# than that to allow something harmful which appears safe.
# Even so, nothing prevents you from writing a capture for the entire contents of a variable—
# but in that case, why use taint?

# ================================
# Taint - Removing Taint from the Environment
# ================================

# The superglobal %ENV represents the environment variables of the system where you're running your program.
# This data is tainted because forces outside of the program's control can manipulate values there.
# Any environment variable which modifies how Perl or the shell finds files and directories is an attack vector.
# A taint-sensitive program should delete several keys from %ENV
# and set $ENV{PATH} to a specific and well-secured path:
sub demo_remove_taint{
    delete @ENV{ qw( IFS CDPATH ENV BASH_ENV ) };
    $ENV{PATH} = '/path/to/app/binaries/';
}

# If you do not set $ENV{PATH} appropriately,
# you will receive messages about its insecurity.
# If this environment variable contained the current working directory,
# or if it contained relative directories,
# or if the directories could be modified by anyone else on the system,
# a clever attacker could perpetrate mischief.

# For similar reasons, @INC does not contain the current working directory under taint mode.
# Perl will also ignore the PERL5LIB and PERLLIB environment variables.
# Use the lib pragma or the -I flag to perl to add library directories to the program.

# ================================
# Taint - Taint Gotchas
# ================================

# Taint mode is all or nothing.
# It's either on or off.
# This sometimes leads people to use permissive patterns to untaint data and,
# thus, gives the illusion of security.
# In that case, taint is busywork which provides no real security.
# Review your untainting rules carefully.

# Unfortunately, not all modules handle tainted data appropriately.
# This is a bug which CPAN authors should take more seriously.
# If you have to make legacy code taint-safe,
# consider the use of the -t flag,
# which enables taint mode but reduces taint violations from exceptions to warnings.
# This is not a substitute for full taint mode,
# but it allows you to secure existing programs without the all or nothing approach of -T.

done_testing();
