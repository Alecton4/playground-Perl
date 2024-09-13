#!/usr/bin/env perl
# REF: http://modernperlbooks.com/books/modern_perl_2016/09-managing-real-programs.html#SGFuZGxpbmdXYXJuaW5ncw

use 5.034;
use warnings;
use autodie;
use feature 'say';

use Test::More;

# While there's more than one way to write a working Perl program,
# some of those ways can be confusing, unclear, and even incorrect.
# Perl's warnings system can help you avoid these situations.

# ================================
# Producing Warnings
# ================================

# Use the warn builtin to emit a warning:
{
    warn 'Something went wrong!';
}

# warn prints a list of values to the STDERR filehandle (Input and Output).
# Perl will append the filename and line number of the warn call
# unless the last element of the list ends in a newline.

# The core Carp module extends Perl's warning mechanisms.
# Its carp() function reports a warning from the perspective of the calling code.
# Given a function like:
{
    use Carp 'carp';

    sub only_two_arguments {
        my ( $lop, $rop ) = @_;
        carp('Too many arguments provided') if @_ > 2;
        ...;
    }
}

# ... the arity (Arity) warning will include the filename and line number of the calling code,
# not only_two_arguments().
# Carp's cluck() is similar,
# but it produces a backtrace of all function calls which led to the current function.

# Carp's verbose mode adds backtraces to all warnings produced by carp() and croak() (Reporting Errors)
# throughout the entire program:
#
#     $ perl -MCarp=verbose my_prog.pl

# Use Carp when writing modules (Modules) instead of warn or die.

# Sometimes you'll have to debug code written without the use of carp() or cluck().
# In that case, use the Carp::Always module to add backtraces to all warn or die calls:
#
#     $ perl -MCarp::Always some_program.pl.

# ================================
# Enabling and Disabling Warnings
# ================================

# The venerable -w command-line flag enables warnings throughout the program,
# even in external modules written and maintained by other people.
# It's all or nothing—though it can help you
# if you have the time and energy to eliminate warnings and potential warnings throughout the entire codebase.
# This was the only way to enable warnings in Perl programs for many years.

# The modern approach is to use the warnings pragma (or an equivalent such as use Modern::Perl;).
# This enables warnings in lexical scopes.
# If you've used warnings in a scope,
# you're indicating that the code should not normally produce warnings.

# The -W flag enables warnings throughout the program unilaterally, regardless of any use of warnings.
# The -X flag disables warnings throughout the program unilaterally.
# Neither is common.

# All of -w, -W, and -X affect the value of the global variable $^W.
# Code written before the warnings pragma came about in spring 2000
# may localize $^W to suppress certain warnings within a given scope.

# ================================
# Disabling Warning Categories
# ================================

# Use no warnings; with an argument list to disable selective warnings within a scope.
# Omitting the argument list disables all warnings within that scope.

# perldoc perllexwarn lists all of the warnings categories your version of Perl understands.
# Most of them represent truly interesting conditions,
# but some may be actively unhelpful in your specific circumstances.
# For example, the recursion warning will occur
# if Perl detects that a function has called itself more than a hundred times.
# If you are confident in your ability to write recursion-ending conditions,
# you may disable this warning within the scope of the recursion—though tail calls may be better (Tail Calls).

# If you're generating code (Code Generation) or locally redefining symbols,
# you may wish to disable the redefine warnings.

# Some experienced Perl hackers disable the uninitialized value warnings in string-processing code
# which concatenates values from many sources.
# If you're careful about initializing your variables,
# you may never need to disable this warning,
# but sometimes the warning gets in the way of writing concise code in your local style.

# ================================
# Making Warnings Fatal
# ================================

# If your project considers warnings as onerous as errors,
# you can make them fatal.
# To promote all warnings into exceptions within a lexical scope:
{
    use warnings FATAL => 'all';
}

# You may also make specific categories of warnings fatal,
# such as the use of deprecated constructs:
{
    use warnings FATAL => 'deprecated';
}

# With proper discipline, this can produce very robust code—but be cautious.
# Many warnings come from conditions that Perl can detect only when your code is running.
# If your test suite fails to identify all of the warnings you might encounter,
# fatalizing these warnings may cause your program to crash.
# Newer versions of Perl often add new warnings.
# Upgrading to a new version without careful testing might cause new exceptional conditions.
# More than that, any custom warnings you or the libraries you use will also be fatal (Registering Your Own Warnings).

# If you enable fatal warnings,
# do so only in code that you control and never in library code you expect other people to use.

# ================================
# Catching Warnings
# ================================

# If you're willing to work for it, you can catch warnings as you would exceptions.
# The %SIG variable (see perldoc perlvar) contains handlers for out-of-band signals
# raised by Perl or your operating system.
# Assign a function reference to $SIG{__WARN__} to catch a warning:
sub demo_catch_warnings {
    my $warning;
    local $SIG{__WARN__} = sub { $warning .= shift };

    # do something risky
    ...;

    say "Caught warning:\n$warning" if $warning;
}

# Within the warning handler, the first argument is the warning's message.
# Admittedly, this technique is less useful than disabling warnings lexically—
# but it can come to good use in test modules such as Test::Warnings from the CPAN,
# where the actual text of the warning is important.

# %SIG is a global variable, so localize it in the smallest possible scope.

# ================================
# Registering Your Own Warnings
# ================================

# The warnings::register pragma allows you to create your own warnings
# which users can enable and disable lexically.
# From a module, use the pragma:
{

    package Scary::Monkey;

    use warnings::register;
}

# This will create a new warnings category named after the package Scary::Monkey.
# Enable these warnings with use warnings 'Scary::Monkey'
# and disable them with no warnings 'Scary::Monkey'.

# Use warnings::enabled() to test if the caller's lexical scope has enabled a warning category.
# Use warnings::warnif() to produce a warning only if warnings are in effect.
# For example, to produce a warning in the deprecated category:
{

    package Scary::Monkey;

    use warnings::register;

    sub import {
        warnings::warnif( 'deprecated',
            'empty imports from ' . __PACKAGE__ . ' are now deprecated' )
          unless @_;
    }
}

# See perldoc perllexwarn for more details.

done_testing();
