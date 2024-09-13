#!/usr/bin/env perl
# REF: http://modernperlbooks.com/books/modern_perl_2016/03-perl-language.html#TmVzdGVkRGF0YVN0cnVjdHVyZXM

use 5.034;
use warnings;
use autodie;
use feature 'say';

use Test::More;

{
    my @counts = qw( eenie miney moe      );
    my @ducks  = qw( huey  dewey louie    );
    my @game   = qw( duck  duck  grayduck );

# Perl's aggregate data types—arrays and hashes—store scalars indexed by integer or string keys.
# Note the word scalar. If you try to store an array in an array,
# Perl's automatic list flattening will make everything into a single array:
    {
        my @famous_triplets = ( @counts, @ducks, @game );
    }

# Perl's solution to this is references (References),
# which are special scalars that can refer to other variables (scalars, arrays, and hashes).
# You Nested data structures in Perl,
# such as an array of arrays or a hash of hashes,
# are possible through the use of references.
# Unfortunately, the reference syntax can be a little bit ugly.

    # Use the reference operator, \,
    # to produce a reference to a named variable:
    {
        my @famous_triplets = ( \@counts, \@ducks, \@game );
    }

# ... or the anonymous reference declaration syntax to avoid the use of named variables:
    my @famous_triplets = (
        [qw( eenie miney moe   )], [qw( huey  dewey louie )],
        [qw( duck  duck  goose )],
    );

    my %meals = (
        breakfast => {
            entree => 'eggs',
            side   => 'hash browns'
        },
        lunch => {
            entree => 'panini',
            side   => 'apple'
        },
        dinner => {
            entree => 'steak',
            side   => 'avocado salad'
        },
    );

    # Perl allows an optional trailing comma after the last element of a list.
    # This makes it easy to add more elements in the future.

# Use Perl's reference syntax to access elements in nested data structures.
# The sigil denotes the amount of data to retrieve.
# The dereferencing arrow indicates that the value of one portion of the data structure is a reference:
    {
        my $last_nephew = $famous_triplets[1]->[2];
        my $meal_side   = $meals{breakfast}->{side};
    }

# The only way to access elements in a nested data structure is through references,
# so the arrow in the previous examples is superfluous.
# You may omit it for clarity, except for invoking function references:
    {
        my $nephew = $famous_triplets[1][2];
        my $meal   = $meals{breakfast}{side};

        # $actions{generous}{buy_food}->( $nephew, $meal );
    }

    # Use disambiguation blocks to access components of nested data structures
    # as if they were first-class arrays or hashes:
    {
        my $nephew_count   = @{ $famous_triplets[1] };
        my $dinner_courses = keys %{ $meals{dinner} };
    }

    # ... or to slice a nested data structure:
    {
        my ( $entree, $side ) = @{ $meals{breakfast} }{qw( entree side )};
    }

# Whitespace helps, but does not entirely eliminate the noise of this construct.
# Sometimes a temporary variable provides more clarity:
    {
        my $meal_ref = $meals{breakfast};
        my ( $entree, $side ) = @$meal_ref{qw( entree side )};
    }

   # ... or use for's implicit aliasing
   # to avoid the use of an intermediate reference (though note the lack of my):
   # {
   # ($entree, $side) = @{ $_ }{qw( entree side )} for $meals{breakfast};
   # }
   # perldoc perldsc, the data structures cookbook,
   # gives copious examples of how to use Perl's various data structures.
}

# ================================
# Autovivification
# ================================

# When you attempt to write to a component of a nested data structure,
# Perl will create the path through the data structure to the destination as necessary:
{
    my @aoaoaoa;
    $aoaoaoa[0][0][0][0] = 'nested deeply';
}

# After the second line of code,
# this array of arrays of arrays of arrays contains
# an array reference in an array reference in an array reference in an array reference.
# Each array reference contains one element.

# Similarly, when you ask Perl to treat an undefined value as if it were a hash reference,
# Perl will turn that undefined value into a hash reference:
{
    my %hohoh;
    $hohoh{Robot}{Santa} = 'mostly harmful';
}

# This behavior is autovivification.
# While it reduces the initialization code of nested data structures,
# it cannot distinguish between the honest intent to create missing elements in nested data structures or a typo.

# You may wonder at the contradiction between taking advantage of autovivification while enabling strictures.
# Is it more convenient to catch errors which change the behavior of your program
# at the expense of disabling error checks for a few well-encapsulated symbolic references?
# Is it more convenient to allow data structures to grow
# or safer to require a fixed size and an allowed set of keys?

# The answers depend on your project.
# During early development, allow yourself the freedom to experiment.
# While testing and deploying, consider an increase of strictness to prevent unwanted side effects.
# The autovivification pragma (Pragmas) from the CPAN lets you disable autovivification
# in a lexical scope for specific types of operations.
# Combined with the strict pragma, you can enable these behaviors where and as necessary.

# You can verify your expectations before dereferencing each level of a complex data structure,
# but the resulting code is often lengthy and tedious.
# It's better to avoid deeply nested data structures
# by revising your data model to provide better encapsulation.

# ================================
# Debugging Nested Data Structures
# ================================

# The complexity of Perl's dereferencing syntax
# combined with the potential for confusion with multiple levels of references
# can make debugging nested data structures difficult.
# The core module Data::Dumper converts values of arbitrary complexity into strings of Perl code,
# which helps visualize what you have:
# {
#     use Data::Dumper;
#
#     my $complex_structure = {
#         numbers => [ 1 .. 3 ]; # ??? Should be comma instead of semicolon?
#         letters => [ 'a' .. 'c' ],
#         objects => {
#             breakfast => $continental,
#             lunch     => $late_tea,
#             dinner    => $banquet,
#         },
#     };
#
#     print Dumper($my_complex_structure);
# }
# ... which might produce something like:
# {
#     $VAR1 = {
#         'numbers' => [
#                       1,
#                       2,
#                       3
#                      ],
#         'letters' => [
#                       'a',
#                       'b',
#                       'c'
#                      ],
#         'meals' => {
#             'dinner' => bless({...}, 'Dinner'),
#             'lunch' => bless({...}, 'Lunch'),
#             'breakfast' => bless({...}, 'Breakfast'),
#         },
#     };
# }
# Use this when you need to figure out what a data structure contains,
# what you should access,
# and what you accessed instead .
# As the elided example alludes,
# Data::Dumper can dump objects as well as function references
# (if you set $Data::Dumper::Deparse to a true value).

# While Data::Dumper is a core module and prints Perl code, its output is verbose.
# Some developers prefer the use of the YAML::XS or JSON modules for debugging.
# They do not produce Perl code, but their outputs can be much clearer to read and to understand.

# ================================
# Circular References
# ================================

# Perl's memory management system of reference counting (Reference Counts) has one drawback.
# Two references which point to each other,
# whether directly or indirectly,
# form a circular reference that Perl cannot destroy on its own.
# Consider a biological model,
# where each entity has two parents and zero or more children:
{
    my $alice  = { mother => '', father => '' };
    my $robin  = { mother => '', father => '' };
    my $cianne = { mother => $alice, father => $robin };

    push @{ $alice->{children} }, $cianne;
    push @{ $robin->{children} }, $cianne;
}

# Both $alice and $robin contain an array reference which contains $cianne.
# Because $cianne is a hash reference which contains $alice and $robin,
# Perl will never decrease the reference count of any of these three people to zero.
# It doesn't recognize that these circular references exist,
# and it can't manage the lifespan of these entities.

# Either break the reference count manually yourself
# (by clearing the children of $alice and $robin or the parents of $cianne),
# or use weak references.
# A weak reference does not increase the reference count of its referent.
# Use the core module Scalar::Util's weaken() function to weaken a reference:
{
    use Scalar::Util 'weaken';

    my $alice  = { mother => '', father => '' };
    my $robin  = { mother => '', father => '' };
    my $cianne = { mother => $alice, father => $robin };

    push @{ $alice->{children} }, $cianne;
    push @{ $robin->{children} }, $cianne;

    weaken( $cianne->{mother} );
    weaken( $cianne->{father} );
}

# $cianne will retain usable references to $alice and $robin,
# but those weak references do not count toward the number of remaining references to the parents.
# If the reference count of $alice reaches zero,
# Perl's garbage collector will reclaim her record,
# even though $cianne has a weak reference to $alice.
# When $alice gets reclaimed,
# $cianne's reference to $alice will be set to undef.

# Most data structures do not need weak references,
# but when they're necessary, they're invaluable.

# ================================
# Alternatives to Nested Data Structures
# ================================

# While Perl is content to process data structures nested as deeply as you can imagine,
# the human cost of understanding these data structures and their relationships—to say nothing of the complex syntax—is high.
# Beyond two or three levels of nesting,
# consider whether modeling various components of your system with classes and objects (Moose)
# will allow for clearer code.

done_testing();
