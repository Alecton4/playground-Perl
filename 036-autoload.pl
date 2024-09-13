#!/usr/bin/env perl
# REF: http://modernperlbooks.com/books/modern_perl_2016/05-perl-functions.html#QVVUT0xPQUQ

use 5.034;
use warnings;
use autodie;
use feature 'say';

use Test::More;

# NOTE: Review when needed.
# Perl does not require you to declare every function before you call it.
# Perl will happily attempt to call a function even if it doesn't exist.
# Consider the program:
# {
#     use Modern::Perl;

#     bake_pie( filling => 'apple' );
# }
# When you run it, Perl will throw an exception
# due to the call to the undefined function bake_pie().

# Now add a function called AUTOLOAD():
# {
#     sub AUTOLOAD {}
# }
# When you run the program now, nothing obvious will happen.
# Perl will call a function named AUTOLOAD() in a package—if it exists—whenever normal dispatch fails.
# Change the AUTOLOAD() to emit a message to demonstrate that it gets called:
# {
#     sub AUTOLOAD { say 'In AUTOLOAD()!' }
# }
# The AUTOLOAD() function receives the arguments passed to the undefined function in @_
# and the fully-qualified name of the undefined function in the package global $AUTOLOAD (here, main::bake_pie):
# {
#     sub AUTOLOAD {
#         our $AUTOLOAD;
#
#         # pretty-print the arguments
#         local $" = ', ';
#         say "In AUTOLOAD(@_) for $AUTOLOAD!"
#     }
# }
# Extract the method name with a regular expression (Regular Expressions and Matching):
# {
#     sub AUTOLOAD {
#         my ($name) = our $AUTOLOAD =~ /::(\w+)$/;
#
#         # pretty-print the arguments
#         local $" = ', ';
#         say "In AUTOLOAD(@_) for $name!"
#     }
# }
# Whatever AUTOLOAD() returns, the original call receives:
# {
#     say secret_tangent( -1 );
#
#     sub AUTOLOAD { return 'mu' }
# }
# So far, these examples have merely intercepted calls to undefined functions.
# You have other options.

# ================================
# Redispatching Methods in AUTOLOAD()
# ================================

# A common pattern in OO programming (Moose)
# is to delegate or proxy certain methods from one object to another.
# A logging proxy can help with debugging:
{

    package Proxy::Log;

    # constructor blesses reference to a scalar

    sub AUTOLOAD {
        my ($name) = our $AUTOLOAD =~ /::(\w+)$/;
        Log::method_call( $name, @_ );

        my $self = shift;
        return $$self->$name(@_);
    }
}

# This AUTOLOAD() extracts the name of the undefined method.
# Then it dereferences the proxied object from a blessed scalar reference,
# logs the method call,
# then invokes that method on the proxied object with the provided parameters.

# ================================
# Generating Code in AUTOLOAD()
# ================================

# This double dispatch is easy to write but inefficient.
# Every method call on the proxy must fail normal dispatch to end up in AUTOLOAD().
# Pay that penalty only once by installing new methods into the proxy class as the program needs them:
sub AUTOLOAD {
    my ($name) = our $AUTOLOAD =~ /::(\w+)$/;
    my $method = sub { ... };

    no strict 'refs';
    *{$AUTOLOAD} = $method;
    return $method->(@_);
}

# The body of the previous AUTOLOAD() has become a closure (Closures)
# bound over the name of the undefined method.
# Installing that closure in the appropriate symbol table
# allows all subsequent dispatch to that method to find the created closure (and avoid AUTOLOAD()).
# This code finally invokes the method directly and returns the result.

# Though this approach is cleaner and almost always more transparent than handling the behavior directly in AUTOLOAD(),
# the code called by AUTOLOAD() may see AUTOLOAD() in its caller() list.
# While it may violate encapsulation to care that this occurs,
# leaking the details of how an object provides a method may also violate encapsulation.

# Some code uses a tailcall (Tailcalls)
# to replace the current invocation of AUTOLOAD()
# with a call to the destination method:
# {
#     sub AUTOLOAD {
#         my ($name) = our $AUTOLOAD =~ /::(\w+)$/;
#         my $method = sub { ... }
#
#           no strict 'refs';
#         *{$AUTOLOAD} = $method;
#         goto &$method;
#     }
# }

# This has the same effect as invoking $method directly,
# except that AUTOLOAD() will no longer appear in the list of calls available from caller(),
# so it looks like normal method dispatch occurred.

# ================================
# Drawbacks of AUTOLOAD
# ================================

# AUTOLOAD() can be useful,
# though it is difficult to use properly.
# The naïve approach to generating methods at runtime
# means that the can() method will not report the right information about the capabilities of objects and classes.
# The easiest solution is to predeclare all functions you plan to AUTOLOAD() with the subs pragma:
# {
#     use subs qw( red green blue ochre teal );
# }

# Forward declarations are useful only in the two rare cases of attributes (Attributes) and autoloading (AUTOLOAD).

# That technique documents your intent well,
# but requires you to maintain a static list of functions or methods.
# Overriding can() (The UNIVERSAL Package) sometimes works better:
# {
#     sub can {
#         my ( $self, $method ) = @_;
#
#         # use results of parent can()
#         my $meth_ref = $self->SUPER::can($method);
#         return $meth_ref if $meth_ref;
#
#         # add some filter here
#         return unless $self->should_generate($method);
#
#         $meth_ref = sub { ... };
#         no strict 'refs';
#         return *{$method} = $meth_ref;
#     }
#
#     sub AUTOLOAD {
#         my ($self) = @_;
#         my ($name) = our $AUTOLOAD =~ /::(\w+)$/;>
#
#         return unless my $meth_ref = $self->can($name);
#         goto &$meth_ref;
#     }
# }

# AUTOLOAD() is a big hammer;
# it can catch functions and methods you had no intention of autoloading,
# such as DESTROY(), the destructor of objects.
# If you write a DESTROY() method with no implementation,
# Perl will happily dispatch to it instead of AUTOLOAD():
# {
#     # skip AUTOLOAD()
#     sub DESTROY { }
# }

# The special methods import(), unimport(), and VERSION() never go through AUTOLOAD().

# If you mix functions and methods in a single namespace
# which inherits from another package which provides its own AUTOLOAD(),
# you may see the strange error:
#
#   Use of inherited AUTOLOAD for non-method slam_door() is deprecated
#
# If this happens to you, simplify your code;
# you've called a function which does not exist in a package
# which inherits from a class which contains its own AUTOLOAD().
# The problem compounds in several ways:
# mixing functions and methods in a single namespace is often a design flaw,
# inheritance and AUTOLOAD() get complex very quickly,
# and reasoning about code when you don't know what methods objects provide is difficult.

# AUTOLOAD() is useful for quick and dirty programming,
# but robust code avoids it.

done_testing();
