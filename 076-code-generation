#!/usr/bin/env perl
# REF: http://modernperlbooks.com/books/modern_perl_2016/09-managing-real-programs.html#Q29kZUdlbmVyYXRpb24

use 5.034;
use warnings;
use autodie;
use feature 'say';

use Test::More;

# Novice programmers write more code than they need to write.
# They start with long lists of procedural code,
# then discover functions,
# then parameters,
# then objects,
# and—perhaps—higher-order functions and closures.

# As you improve your skills, you'll write less code to solve the same problems.
# You'll use better abstractions.
# You'll write more general code.
# You can reuse code—
# and when you can add features by deleting code, you'll achieve something great.

# Writing programs to write programs for you—metaprogramming or code generation—
# allows you to build reusable abstractions.
# While you can make a huge mess, you can also build amazing things.
# Metaprogramming techniques make Moose possible, for example (Moose).

# The AUTOLOAD technique (AUTOLOAD) for missing functions and methods demonstrates this technique in a specific form:
# Perl's function and method dispatch system allows you to control what happens when normal lookup fails.

# ================================
# eval
# ================================

# The simplest code generation technique is to build a string containing a snippet of valid Perl
# and compile it with the string eval operator.
# Unlike the exception-catching block eval operator,
# string eval compiles the contents of the string within the current scope,
# including the current package and lexical bindings.

# A common use for this technique is providing a fallback
# if you can't (or don't want to) load an optional dependency:
sub demo_eval {
    eval { require Monkey::Tracer } or eval 'sub Monkey::Tracer::log {}';
}

# If Monkey::Tracer is not available,
# this code defines a log() function which will do nothing.
# This simple example is deceptive; getting eval right takes effort.
# You must handle quoting issues to include variables within your evald code.

# TODO: review
# Add more complexity to interpolate some variables but not others:
sub generate_accessors {
    my ( $methname, $attrname ) = @_;

    eval <<"END_ACCESSOR";
    sub get_$methname {
        my \$self = shift;
        return \$self->{$attrname};
    }

    sub set_$methname {
        my (\$self, \$value) = \@_;
        \$self->{$attrname}  = \$value;
    }
END_ACCESSOR
}

# Woe to those who forget a backslash!
# Good luck convincing your syntax highlighter what's happening!
# Worse yet, each invocation of string eval builds a new data structure representing the entire code,
# and compiling code isn't free.
# Yet even with its limitations, this technique is simple and useful.

# ================================
# Parametric Closures
# ================================

# While building accessors and mutators with eval is straightforward,
# closures (Closures) allow you to add parameters to generated code at compilation time
# without requiring additional evaluation:
sub generate_accessors_using_closures {
    my $attrname = shift;

    my $getter = sub {
        my $self = shift;
        return $self->{$attrname};
    };

    my $setter = sub {
        my ( $self, $value ) = @_;
        $self->{$attrname} = $value;
    };

    return $getter, $setter;
}

# This code avoids unpleasant quoting issues and compiles each closure only once.
# It limits the memory used by sharing the compiled code between all closure instances.
# All that differs is the binding to the $attrname lexical.
# In a long-running process or a class with a lot of accessors,
# this technique can be very useful.

# Installing into symbol tables is reasonably easy, if ugly:
{
    my ( $get, $set ) = generate_accessors('pie');

    no strict 'refs';
    *{'get_pie'} = $get;
    *{'set_pie'} = $set;
}

# Think of the asterisk as a typeglob sigil,
# where a typeglob is Perl jargon for "symbol table".
# Dereferencing a string like this refers to a symbol in the current symbol table,
# which is the section of the current namespace
# which contains globally-accessible symbols such as package globals, functions, and methods.
# Assigning a reference to a symbol table entry installs or replaces that entry.
# To promote an anonymous function to a method,
# store that function's reference in the symbol table.

# Assigning to a symbol table symbol with a string,
# not a literal variable name, is a symbolic reference.
# You must disable strict reference checking for the operation.
# Many programs have a subtle bug in similar code,
# as they assign and generate in a single line:
# {
#     no strict 'refs';
#
#     *{ $methname } = sub {
#         # subtle bug: strict refs disabled here too
#     };
# }
# This example disables strictures for the outer block as well as the body of the function itself.
# Only the assignment violates strict reference checking,
# so disable strictures for that operation alone:
# {
#     {
#         my $sub = sub { ... };
#
#         no strict 'refs';
#         *{ $methname } = $sub;
#     }
# }

# If the name of the method is a string literal in your source code,
# rather than the contents of a variable,
# you can assign to the relevant symbol directly:
{
    no warnings 'once';
    ( *get_pie, *set_pie ) = generate_accessors('pie');
}

# Assigning directly to the glob does not violate strictures,
# but mentioning each glob only once does produce a "used only once" warning you can disable with the warnings pragma.

# Use the CPAN module Package::Stash to modify symbol tables for you.

# ================================
# TODO: review Compile-time Manipulation
# ================================

# Unlike code written explicitly as code,
# code generated through string eval gets compiled while your program is running.
# Where you might expect a normal function to be available throughout the lifetime of your program,
# a generated function might not be available when you expect it.

# Force Perl to run code—to generate other code—during compilation
# by wrapping it in a BEGIN block.
# When the Perl parser encounters a block labeled BEGIN,
# it parses and compiles the entire block,
# then runs it (unless it has syntax errors).
# When the block finishes running,
# parsing will continue as if there had been no interruption.

# The difference between writing:
# {
#     sub get_age    { ... }
#     sub set_age    { ... }
#
#     sub get_name   { ... }
#     sub set_name   { ... }
#
#     sub get_weight { ... }
#     sub set_weight { ... }
# }
# ... and:
# {
#     sub make_accessors { ... }
#
#     BEGIN {
#         for my $accessor (qw( age name weight )) {
#             my ($get, $set) = make_accessors( $accessor );
#
#             no strict 'refs';
#             *{ 'get_' . $accessor } = $get;
#             *{ 'set_' . $accessor } = $set;
#         }
#     }
# }
# ... is primarily one of maintainability. You could argue for and against either form.

# Within a module, any code outside of functions executes when you use the module,
# because of the implicit BEGIN Perl adds around the require and import (Importing).
# Any code outside of a function but inside the module will execute before the import() call occurs.
# If you require the module, there is no implicit BEGIN block.
# After parsing finishes, Perl will run code outside of the functions.

# Beware of the interaction between lexical declaration (the association of a name with a scope)
# and lexical assignment.
# The former happens during compilation,
# while the latter occurs at the point of execution.
# This code has a subtle bug:
# {
#     use UNIVERSAL::require;
#
#     # buggy; do not use
#     my $wanted_package = 'Monkey::Jetpack';
#
#     BEGIN {
#         $wanted_package->require;
#         $wanted_package->import;
#     }
# }
# ... because the BEGIN block will execute
# before the assignment of the string value to $wanted_package occurs.
# The result will be an exception from attempting to invoke the require() method on an undefined value.

# The UNIVERSAL::require CPAN distribution adds a require() method to UNIVERSAL.

# ================================
# TODO: Class::MOP
# ================================

done_testing();
