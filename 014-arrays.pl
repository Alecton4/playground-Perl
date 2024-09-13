#!/usr/bin/env perl
# REF: http://modernperlbooks.com/books/modern_perl_2016/03-perl-language.html#QXJyYXlz

use 5.034;
use warnings;
use autodie;
use feature 'say';

use Test::More;

# Perl's array data type is a language-supported aggregate which can store zero or more scalars.
# You can access individual members of the array by integer indexes,
# and you can add or remove elements at will.
# NOTE: Arrays grow or shrink as you manipulate them.

# The @ sigil denotes an array. To declare an array:
{
    my @items;
}

# ================================
# Array Elements
# ================================

# Use the scalar sigil to access an individual element of an array.
# $cats[0] refers unambiguously to the @cats array,
# because postfix (Fixity) square brackets ([]) always mean indexed access to an array.

# The last index of an array depends on the number of elements in the array.
# An array in scalar context (due to scalar assignment, string concatenation, addition, or boolean context)
# evaluates to the number of elements in the array:
{
    my @cats = qw/Tabby Tommy Cali/;
    my @dogs = qw/Chow Mutt/;
    my @fish = qw/Snapper Nemo/;

    # scalar assignment
    my $num_cats = @cats;

    # NOTE: string concatenation
    say 'I have ' . @cats . ' cats!';

    # addition
    my $num_animals = @cats + @dogs + @fish;

    # boolean context
    say 'Yep, a cat owner!' if @cats;
}

# To get the index of the final element of an array,
# subtract one from the number of elements of the array (because array indexes start at 0)
# NOTE: or use the unwieldy $#cats syntax:
# {
#     my $first_index = 0;
#     my $last_index  = @cats - 1;
#     # or
#     # my $last_index = $#cats;
# }

# Most of the time you care more about the relative position of an array element.
# Use a negative array index to refer to elements from the end.
# The last element of an array is available at the index -1.
# {
#     my $last_cat           = $cats[-1];
#     my $second_to_last_cat = $cats[-2];
# }

# NOTE: Review when needed.
# $# has another use: resize an array in place by assigning to $#array.
# Remember that Perl arrays are mutable.
# They expand or contract as necessary.
# When you shrink an array, Perl will discard values which do not fit in the resized array.
# When you expand an array, Perl will fill the expanded positions with undef.

# ================================
# Array Assignment
# ================================

# Assign to individual positions in an array directly by index:
{
    my @cats;
    $cats[3] = 'Jack';
    $cats[2] = 'Tuxedo';
    $cats[0] = 'Daisy';
    $cats[1] = 'Petunia';
    $cats[4] = 'Brad';
    $cats[5] = 'Choco';
}

# If you assign to an index beyond the array's current bounds,
# Perl will extend the array for you.
# As you might expect, all intermediary positions with then contain undef.
# After the first assignment, the array will contain undef at positions 0, 1, and 2 and Jack at position 3.

# As an assignment shortcut, initialize an array from a list:
{
    my @cats = ( 'Daisy', 'Petunia', 'Tuxedo', 'Jack', 'Brad', 'Choco' );
}

# ... but remember that these parentheses do not create a list.
# Without parentheses, this would assign Daisy as the first and only element of the array,
# due to operator precedence (Precedence).
# Petunia, Tuxedo, and all of the other cats would be evaluated in void context and Perl would complain.
# (So would all the other cats, especially Petunia.)

# Assigning to a scalar element of an array imposes scalar context,
# while assigning to the array as a whole imposes list context.

# To clear an array, assign an empty list:
{
    my @dates = ( 1969, 2001, 2010, 2051, 1787 );
    @dates = ();
}

# This is one of the only cases where parentheses do indicate a list;
# without something to mark a list, Perl and readers of the code would get confused.

# my @items = (); is a longer and noisier version of my @items.
# Freshly-declared arrays start out empty.
# Not "full of undef" empty. Really empty.

# ================================
# Array Operations
# ================================

# The push and pop operators add and remove elements from the tail of an array, respectively:
# {
#     my @meals;
#
#     # what is there to eat?
#     push @meals, qw( hamburgers pizza lasagna turnip );
#
#     # ... but your nephew hates vegetables
#     pop @meals;
# }
# You may push a list of values onto an array,
# but you may only pop one at a time.
# push returns the new number of elements in the array.
# pop returns the removed element.

# Similarly, unshift and shift add elements to and remove an element from the start of an array, respectively:
# {
#     # expand our culinary horizons
#     unshift @meals, qw( tofu spanakopita taquitos );
#
#     # rethink that whole soy idea
#     shift @meals;
# }
# unshift prepends a list of elements to the start of the array
# and returns the new number of elements in the array.
# shift removes and returns the first element of the array.
# Almost no one uses these return values.

# The splice operator removes and replaces elements from an array given an offset,
# a length of a list slice, and replacement elements.
# Both replacing and removing are optional; you may omit either.
# The perlfunc description of splice demonstrates its equivalences with push, pop, shift, and unshift.
# One effective use is removal of two elements from an array:
# {
#     my ($winner, $runnerup) = splice @finalists, 0, 2;
#
#     # or
#     my $winner              = shift @finalists;
#     my $runnerup            = shift @finalists;
# }

# The each operator allows you to iterate over an array by index and value:
# {
#     while (my ($position, $title) = each @bookshelf) {
#         say "#$position: $title";
#     }
# }

# ================================
# Array Slices
# ================================

# An array slice allows you to access elements of an array in list context.
# Unlike scalar access of an array element,
# this indexing operation takes a list of zero or more indices and uses the array sigil (@):
# {
#     my @youngest_cats = @cats[-1, -2];
#     my @oldest_cats   = @cats[0 .. 2];
#     my @selected_cats = @cats[ @indexes ];
# }

# Array slices are useful for assignment:
# {
#     @users[ @replace_indices ] = @replace_users;
# }

# ================================
# Arrays and Context
# ================================

# In list context, arrays flatten into lists.
# If you pass multiple arrays to a normal function, they will flatten into a single list:
{
    my @cats = qw( Daisy Petunia Tuxedo Brad Jack Choco );
    my @dogs = qw( Rodney Lucky Rosie );

    take_pets_to_vet( @cats, @dogs );

    sub take_pets_to_vet {

        # BUGGY: do not use!
        my ( @cats, @dogs ) = @_;
    }
}

# Within the function, @_ will contain nine elements, not two, because list assignment to arrays is greedy.
# An array will consume as many elements from the list as possible.
# After the assignment,
# @cats will contain every argument passed to the function.
# @dogs will be empty, and woe to anyone who treats Rodney as a cat.

# This flattening behavior sometimes confuses people who attempt to create nested arrays:
{
    # creates a single array, not an array of arrays
    my @numbers = ( 1 .. 10, ( 11 .. 20, ( 21 .. 30 ) ) );
}

# ... but this code is effectively the same as either:
{
    # parentheses do not create lists
    my @numbers = ( 1 .. 10, 11 .. 20, 21 .. 30 );
}
{
    # creates a single array, not an array of arrays
    my @numbers = 1 .. 30;
}

# ... because, again, parentheses merely group expressions.
# They do not create lists.
# To avoid this flattening behavior, use array references (Array References).

# ================================
# Array Interpolation
# ================================

# TODO: review
# Arrays interpolate in strings as lists of the stringification of each item separated by the current value of the magic global $".
# The default value of this variable is a single space.
# Its English.pm mnemonic is $LIST_SEPARATOR. Thus:
sub demo_array_interpolation {
    my @alphabet = 'a' .. 'z';
    say "[@alphabet]";

    # [a b c d e f g h i j k l m n o p q r s t u v w x y z]
}

# Per Mark Jason Dominus, localize $" with a delimiter to improve your debugging:
# {
#     # what's in this array again?
#     local $" = ')(';
#     say "(@sweet_treats)";
#     (pie)(cake)(doughnuts)(cookies)(cinnamon roll)
# }

done_testing();
