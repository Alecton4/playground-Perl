#!/usr/bin/env perl
# REF: http://modernperlbooks.com/books/modern_perl_2016/08-perl-style-efficiency.html#RXhjZXB0aW9ucw

use 5.034;
use warnings;
use autodie;
use feature 'say';

use Test::More;

# Good programmers anticipate the unexpected.
# Files that should exist won't.
# A huge disk that should never fill up will.
# The network that never goes down stops responding.
# The unbreakable database crashes and eats a table.
# The unexpected happens.

# Perl handles exceptional conditions through exceptions:
# a dynamically-scoped control flow mechanism designed to raise and handle errors.
# Robust software must handle them.
# If you can recover, great!
# If you can't, log the relevant information and retry.

# ================================
# Throwing Exceptions
# ================================

# Suppose you want to write a log file.
# If you can't open the file, something has gone wrong.
# Use die to throw an exception (or see The autodie Pragma):

sub open_log_file {
    my $name = shift;
    open my $fh, '>>', $name or die "Can't open log to '$name': $!";
    return $fh;
}

# die() sets the global variable $@ to its operand
# and immediately exits the current function without returning anything.
# This is known as throwing an exception.
# A thrown exception will continue up the call stack (Controlled Execution) until something catches it.
# If nothing catches the exception, the program will exit with an error.

# Exception handling uses the same dynamic scope (Dynamic Scope) as local symbols.

# ================================
# Catching Exceptions
# ================================

# Sometimes allowing an exception to end the program is useful.
# A program run from a timed process might throw an exception when the error logs are full,
# causing an SMS to go out to administrators.
# Other exceptions might not be fatal—your program might be able to recover from one.
# Another might give you a chance to save the user's work and exit cleanly.

# Use the block form of the eval operator to catch an exception:
{
    # log file may not open
    my $fh = eval { open_log_file('monkeytown.log') };
}

# If the file open succeeds, $fh will contain the filehandle.
# If it fails, $fh will remain undefined and program flow will continue.

# The block argument to eval introduces a new scope, both lexical and dynamic.
# If open_log_file() called other functions and something eventually threw an exception,
# this eval could catch it.

# An exception handler is a blunt tool.
# It will catch all exceptions thrown in its dynamic scope.
# To check which exception you've caught (or if you've caught an exception at all),
# check the value of $@.
# NOTE: Be sure to localize $@ before you attempt to catch an exception,
# as $@ is a global variable:
{
    local $@;

    # log file may not open
    my $fh = eval { open_log_file('monkeytown.log') };

    # caught exception
    if ( my $exception = $@ ) { ... }
}

# Copy $@ to a lexical variable immediately
# to avoid the possibility of subsequent code clobbering the global variable $@.
# You never know what else has used an eval block elsewhere and reset $@.

# $@ usually contains a string describing the exception.
# Inspect its contents to see whether you can handle the exception:
# {
#     if (my $exception = $@) {
#         die $exception unless $exception =~ /^Can't open logging/;
#         $fh = log_to_syslog();
#     }
# }
# Rethrow an exception by calling die() again.
# Pass the existing exception or a new one as necessary.

# Applying regular expressions to string exceptions can be fragile,
# because error messages may change over time.
# This includes the core exceptions that Perl itself throws.
# Instead of throwing an exception as a string,
# you may use a reference—even a blessed reference—with die.
# This allows you to provide much more information in your exception:
# line numbers, files, and other debugging information.
# Retrieving information from a data structure is much easier than parsing data out of a string.
# Catch these exceptions as you would any other exception.

# The CPAN distribution Exception::Class makes creating and using exception objects easy:
# {
#     package Zoo::Exceptions {
#         use Exception::Class
#             'Zoo::AnimalEscaped',
#             'Zoo::HandlerEscaped';
#     }
#
#     sub cage_open {
#         my $self = shift;
#
#         Zoo::AnimalEscaped->throw unless $self->contains_animal;
#         ...
#     }
#
#     sub breakroom_open {
#         my $self = shift;
#         Zoo::HandlerEscaped->throw unless $self->contains_handler;
#         ...
#     }
# }
# Another fine option is Throwable::Error.

# ================================
# Exception Caveats
# ================================

# Though throwing exceptions is simple, catching them is less so.
# Using $@ correctly requires you to navigate several subtle risks:
#
#     Unlocalized uses in the same or a nested dynamic scope may modify $@
#
#     $@ may contain an object which returns a false value in boolean context
#
#     A signal handler (especially the DIE signal handler) may change $@
#
#     The destruction of an object during scope exit may call eval and change $@

# Modern Perl has fixed some of these issues.
# Though they rarely occur, they're difficult to diagnose.
# The Try::Tiny CPAN distribution improves the safety of exception handling and the syntax:
{
    use Try::Tiny;

    my $fh = try { open_log_file('monkeytown.log') }
    catch { log_exception($_) };
}

# try replaces eval.
# The optional catch block executes only when try catches an exception.
# catch receives the caught exception as the topic variable $_.

# ================================
# Built-in Exceptions
# ================================

# Perl itself throws several exceptional conditions.
# perldoc perldiag lists several "trappable fatal errors".
# Some are syntax errors that Perl produces during failed compilations,
# but you can catch the others during runtime.
# The most interesting are:
#
#     Using a disallowed key in a locked hash (Locking Hashes)
#
#     Blessing a non-reference (Blessed References)
#
#     Calling a method on an invalid invocant (Moose)
#
#     Failing to find a method of the given name on the invocant
#
#     Using a tainted value in an unsafe fashion (Taint)
#
#     Modifying a read-only value
#
#     Performing an invalid operation on a reference (References)
#
# You can also catch exceptions produced by autodie (The autodie Pragma)
# and any lexical warnings promoted to exceptions (Registering Your Own Warnings).

done_testing();
