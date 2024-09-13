#!/usr/bin/env perl
# REF: http://modernperlbooks.com/books/modern_perl_2016/03-perl-language.html#U2NhbGFycw

use 5.034;
use warnings;
use autodie;
use feature 'say';

use Test::More;

# Perl's fundamental data type is the scalar: a single, discrete value.
# That value may be a string,
# an integer,
# a floating point value,
# a filehandle,
# or a reference—
# but it is always a single value.
# Scalars may be lexical, package, or global (Global Variables) variables.
# You may only declare lexical or package variables.
# The names of scalar variables must conform to standard variable naming guidelines (Names).
# Scalar variables always use the leading dollar-sign ($) sigil (Variable Sigils).

# Scalar values and scalar context have a deep connection;
# assigning to a scalar imposes scalar context.
# Using the scalar sigil with an aggregate variable
# accesses a single element of the hash or array in scalar context.

# ================================
# Scalars and Types
# ================================

# A scalar variable can contain any type of scalar value without special conversions, coercions, or casts.
# The type of value stored in a scalar variable, once assigned, can change arbitrarily:
{
    my $value;
    $value = 123.456;
    $value = 77;
    $value = "I am Chuck's big toe.";
    $value = Store::IceCream->new;
}

# Even though this code is legal, changing the type of data stored in a scalar is confusing.

# This flexibility of type often leads to value coercion (Coercion).
# For example, you may treat the contents of a scalar as a string,
# even if you didn't explicitly assign it a string:
{
    my $zip_code       = 97123;
    my $city_state_zip = 'Hillsboro, Oregon' . ' ' . $zip_code;
}

# You may also use mathematical operations on strings:
{
    my $call_sign = 'KBMIU';

    # update sign in place and return new value
    my $next_sign = ++$call_sign;

    # return old value, then update sign
    my $curr_sign = $call_sign++;

    # but does not work as:
    my $new_sign = $call_sign + 1;
}

# NOTE: This magical string increment behavior has no corresponding magical decrement behavior.
# You can't restore the previous string value by writing $call_sign--.

# This string increment operation turns a into b and z into aa,
# respecting character set and case.
# While ZZ9 becomes AAA0, ZZ09 becomes ZZ10—
# numbers wrap around while there are more significant places to increment,
# as on a vehicle odometer.

# Evaluating a reference (References) in string context produces a string.
# Evaluating a reference in numeric context produces a number.
# Neither operation modifies the reference in place,
# but you cannot recreate the reference from either result:
{
    my $authors     = [qw( Pratchett Vinge Conway )];
    my $stringy_ref = '' . $authors;
    my $numeric_ref = 0 + $authors;
}

# $authors is still useful as a reference,
# but $stringy_ref is a string with no connection to the reference
# and $numeric_ref is a number with no connection to the reference.

# To allow coercion without data loss,
# Perl scalars can contain both numeric and string components.
# The internal data structure which represents a scalar in Perl has a numeric slot and a string slot.
# Accessing a string in a numeric context produces a scalar with both string and numeric values.

# Scalars do not contain a separate slot for boolean values.
# In boolean context, numbers which evaluate to zero (0, 0.0, and 0e0) evaluate to false values.
# All other numbers evaluate to true values.
# In boolean context, the empty strings ('') and '0' evaluate to false values.
# All other strings evaluate to true values.
# Note that the strings '0.0' and '0e0' evaluate to true values.
# This is one place where Perl makes a distinction between what looks like a number and what really is a number.

# undef is always a false value.
