#!/usr/bin/env perl
# REF: http://modernperlbooks.com/books/modern_perl_2016/03-perl-language.html#UmVmZXJlbmNlcw

use 5.034;
use warnings;
use autodie;
use feature 'say';

use Test::More;

# Perl usually does what you expect, even if what you expect is subtle.
# Consider what happens when you pass values to functions:
sub demo_value_passing {

    sub reverse_greeting {
        my $name = reverse shift;
        return "Hello, $name!";
    }

    my $name = 'Chuck';
    say reverse_greeting($name);
    say $name;
}

# Outside of the function, $name contains Chuck,
# even though the value passed into the function gets reversed into kcuhC.
# You probably expected that.
# The value of $name outside the function is separate from the $name inside the function.
# Modifying one has no effect on the other.

# Perl provides a mechanism by which to refer to a value without making a copy.
# Any changes made to that reference will update the value in place,
# such that all references to that value will refer to the modified value.
# A reference is a first-class scalar data type which refers to another first-class data type.

# ================================
# Scalar References
# ================================

# The reference operator is the backslash (\).
# In scalar context, it creates a single reference which refers to another value.
# In list context, it creates a list of references.

# To take a reference to $name:
{
    my $name     = 'Larry';
    my $name_ref = \$name;
}

# You must dereference a reference to evaluate the value to which it refers.
# Dereferencing requires you to add an extra sigil for each level of dereferencing:
sub demo_dereferencing {

    sub reverse_in_place {
        my $name_ref = shift;
        $$name_ref = reverse $$name_ref;
    }

    my $name = 'Blabby';
    reverse_in_place( \$name );
    say $name;
}

# The double scalar sigil ($$) dereferences a scalar reference.

# Parameters in @_ behave as aliases to caller variables (Iteration and Aliasing),
# so you can modify them in place:
sub demo_aliasing {

    sub reverse_value_in_place {
        $_[0] = reverse $_[0];
    }

    my $name = 'allizocohC';
    reverse_value_in_place($name);
    say $name;
}

# You usually don't want to modify values this way—callers rarely expect it, for example.
# Assigning parameters to lexicals within your functions makes copies of the values in @_
# and avoids this aliasing behavior.

# Modifying a value in place or returning a reference to a scalar can save memory.
# Because Perl copies values on assignment,
# you could end up with multiple copies of a large string.
# Passing around references means that Perl will only copy the references—a far cheaper operation.
# Before you modify your code to pass only references, however,
# measure to see if this will make a difference.

# Complex references may require a curly-brace block to disambiguate portions of the expression.
# You may always use this syntax, though sometimes it clarifies and other times it obscures:
{

    sub reverse_in_place_disambiguate {
        my $name_ref = shift;
        ${$name_ref} = reverse ${$name_ref};
    }
}

# If you forget to dereference a scalar reference,
# Perl will likely coerce the reference into a string value of the form SCALAR(0x93339e8)
# or a numeric value such as 0x93339e8.
# This value indicates the type of reference (in this case, SCALAR)
# and the location in memory of the reference
# (because that's an unambiguous design choice, not because you can do anything with the memory location itself).

# Perl does not offer native access to memory locations.
# The address of the reference is a value used as an identifier.
# Unlike pointers in a language such as C,
# you cannot modify the address of a reference or treat it as an address into memory.
# These addresses are mostly unique
# because Perl may reuse storage locations as it reclaims unused memory.

# ================================
# Array References
# ================================

# Array references are useful in several circumstances:
#
#     To pass and return arrays from functions without list flattening
#     To create multi-dimensional data structures
#     To avoid unnecessary array copying
#     To hold anonymous data structures

{
    my @cards = qw( K Q J 10 9 8 7 6 5 4 3 2 A );

    # Use the reference operator to create a reference to a declared array:
    my $cards_ref = \@cards;

# Any modifications made through $cards_ref will modify @cards and vice versa.
# You may access the entire array as a whole with the @ sigil,
# whether to flatten the array into a list (list context) or count its elements (scalar context):
    my $card_count = @$cards_ref;
    my @card_copy  = @$cards_ref;

    # Access individual elements with the dereferencing arrow (->):
    my $first_card = $cards_ref->[0];
    my $last_card  = $cards_ref->[-1];

# The arrow is necessary to distinguish between a scalar named $cards_ref and an array named @cards_ref.
# Note the use of the scalar sigil (Variable Sigils) to access a single element.

    # An alternate syntax prepends another scalar sigil to the array reference.
    # It's shorter but uglier to write my $first_card = $$cards_ref[0];.

# Use the curly-brace dereferencing syntax to slice (Array Slices) an array reference:
    my @high_cards = @{$cards_ref}[ 0 .. 2, -1 ];

 # You may omit the curly braces, but their grouping often improves readability.
}

# To create an anonymous array,
# surround a list-producing expression with square brackets:
{
    my $suits_ref = [qw( Monkeys Robots Dinos Cheese )];
}

# This array reference behaves the same as named array references,
# except that the anonymous array brackets always create a new reference.
# Taking a reference to a named array in its scope always refers to the same array.
# For example:
{
    my @meals      = qw( soup sandwiches pizza );
    my $sunday_ref = \@meals;
    my $monday_ref = \@meals;

    push @meals, 'ice cream sundae';
}

# ... both $sunday_ref and $monday_ref now contain a dessert, while:
{
    my @meals      = qw( soup sandwiches pizza );
    my $sunday_ref = [@meals];
    my $monday_ref = [@meals];

    push @meals, 'berry pie';
}

# ... neither $sunday_ref nor $monday_ref contains a dessert.
# Within the square braces used to create the anonymous array,
# list context flattens the @meals array into a list unconnected to @meals.

# NOTE: Review for fun.
sub fun_1 {
    my $one = 1;
    my $two = 2;
    my @arr = ( \$one, \$two );
    my $ref = [ \$one, \$two ];

    say $ref;
    say @$ref;
    say @$ref + 0;

    say ${ @arr[0] };    # A1
    say ${ $arr[0] };    # A2

    say ${ @$ref[0] };   # B1
    say ${ $$ref[0] };   # B2
}

# NOTE: Review for fun.
sub fun_2 {

    # my $array_ref = \( my @arr = ( 1, 2, 3 ), 89, 64 );
    my $array_ref = [ my @arr = ( 1, 2, 3 ), 89, 64 ];
    push @$array_ref, qw( a b c );

    local $\ = "\n\n";
    print "@arr";
    print "$arr[0]";
    print "$arr[0, 2]";    # ???
    print "@arr[0]";
    print "@arr[0, 2]";
    print "@arr[0..1]";

    # print $$array_ref;
    print "$array_ref";
    print "@$array_ref";
    print "$$array_ref[0]";
    print "$$array_ref[0, 4]";
    print "@$array_ref[0]";
    print "@$array_ref[0, 4]";
    print "@$array_ref[0..3]";
}

# ================================
# Hash References
# ================================

{
    my %colors = (
        blue   => 'azul',
        gold   => 'dorado',
        red    => 'rojo',
        yellow => 'amarillo',
        purple => 'morado',
    );

    # Use the reference operator on a named hash to create a hash reference:
    my $colors_ref = \%colors;

# Access the keys or values of the hash by prepending the reference with the hash sigil %:
    my @english_colors = keys %$colors_ref;
    my @spanish_colors = values %$colors_ref;

# Access individual values of the hash (to store, delete, check the existence of, or retrieve)
# by using the dereferencing arrow or double scalar sigils:
    sub translate_to_spanish {
        my $color = shift;
        return $colors_ref->{$color};

        # or return $$colors_ref{$color};
    }

  # Use the array sigil (@) and disambiguation braces to slice a hash reference:
    my @colors  = qw( red blue green );
    my @colores = @{$colors_ref}{@colors};
}

# Create anonymous hashes in place with curly braces:
{
    my $food_ref = {
        'birthday cake' => 'la torta de cumpleaños',
        candy           => 'dulces',
        cupcake         => 'bizcochito',
        'ice cream'     => 'helado',
    };
}

# As with anonymous arrays, anonymous hashes create a new anonymous hash on every execution.

# !!! The common novice error of assigning an anonymous hash to a standard hash
# produces a warning about an odd number of elements in the hash.
# Use parentheses for a named hash and curly brackets for an anonymous hash.

# ================================
# Function References
# ================================

# Perl supports first-class functions;
# a function is a data type just as is an array or hash.
# In other words, Perl supports function references.
# This enables many advanced features (Closures).

sub demo_function_references {
    sub bake_cake { say 'Baking a wonderful cake!' }

    # Create a function reference by using the reference operator
    # and the function sigil (&) on the name of a function:
    my $cake_ref = \&bake_cake;

    # Without the function sigil (&),
    # you will take a reference to the function's return value or values.

    # Invoke the function reference with the dereferencing arrow:
    $cake_ref->();

    # Create anonymous functions with the bare sub keyword:
    my $pie_ref = sub { say 'Making a delicious pie!' };

  # The use of the sub builtin without a name compiles the function
  # but does not register it with the current namespace.
  # The only way to access this function is via the reference returned from sub.
  # Invoke the function reference with the dereferencing arrow:
    $pie_ref->();
}

# An alternate invocation syntax for function references uses the function sigil (&)
# instead of the dereferencing arrow.
# Avoid this &$cupcake_ref syntax;
# it has subtle implications for parsing and argument passing.

# Think of the empty parentheses as denoting an invocation dereferencing operation
# in the same way that square brackets indicate an indexed (array) lookup
# and curly brackets a keyed (hash) lookup.
# Pass arguments to the function within the parentheses:
# {
#     $bake_something_ref->( 'cupcakes' );
# }

# You may also use function references as methods with objects (Moose).
# This is useful when you've already looked up the method (Reflection):
# {
#     my $clean = $robot_maid->can( 'cleanup' );
#     $robot_maid->$clean( $kitchen );
# }

# ================================
# TODO: review Filehandle References
# ================================

# The lexical filehandle form of open and opendir operate on filehandle references.
# Internally, these filehandles are objects of the class IO::File.
# You can call methods on them directly:
sub demo_lexical_filehandles {
    use autodie 'open';

    open my $out_fh, '>', 'output_file.txt';
    $out_fh->say('Have some text!');
}

# Old code might use IO::Handle;.
# Older code may take references to typeglobs:
# {
#     local *FH;
#     open FH, "> $file" or die "Can't write '$file': $!";
#     my $fh = \*FH;
# }
# This idiom predates the lexical filehandles introduced by Perl 5.6 in March 2000.
# You may still use the reference operator on typeglobs to take references to package-global filehandles
# such as STDIN, STDOUT, STDERR, or DATA—but these are all global names anyhow.

# As lexical filehandles respect explicit scoping,
# they allow you to manage the lifespan of filehandles as a feature of Perl's memory management.

# ================================
# References Counts
# ================================

# Perl uses a memory management technique known as reference counting.
# Every Perl value has a counter attached to it, internally.
# Perl increases this counter every time something takes a reference to the value,
# whether implicitly or explicitly.
# Perl decreases that counter every time a reference goes away.
# When the counter reaches zero, Perl can safely recycle that value.
# Consider the filehandle opened in this inner scope:
sub demo_rc {
    say 'file not open';

    {
        open my $fh, '>', 'inner_scope.txt';
        $fh->say('file open here');
    }

    say 'file closed here';
}

# Within the inner block in the example, there's one $fh.
# (Multiple lines in the source code mention it, but there's only one variable, the one named $fh.)
# $fh is only in scope in the block.
# Its value never leaves the block.
# When execution reaches the end of the block,
# Perl recycles the variable $fh and decreases the reference count of the filehandle referred to by $fh.
# The filehandle's reference count reaches zero,
# so Perl destroys the filehandle to reclaim memory.
# As part of the process, it calls close() on the filehandle implicitly.

# You don't have to understand the details of how all of this works.
# You only need to understand that your actions in taking references and passing them around affect how Perl manages memory (see Circular References).

# ================================
# References and Functions
# ================================

# When you use references as arguments to functions, document your intent carefully.
# Modifying the values of a reference from within a function may surprise the calling code,
# which never expected anything else to modify its data.
# To modify the contents of a reference without affecting the reference itself,
# copy its values to a new variable:
# {
#     my @new_array = @{ $array_ref };
#     my %new_hash  = %{ $hash_ref  };
# }
# This is only necessary in a few cases,
# but explicit cloning helps avoid nasty surprises for the calling code.
# If you use nested data structures or other complex references,
# consider the use of the core module Storable and its dclone (deep cloning) function.

# ================================
# Postfix Dereferencing
# ================================

# TODO: review
# Perl 5.20 introduced and Perl 5.24 stabilized a feature called postfix dereferencing.
# Instead of using prefix or circumfix dereferencing notation,
# you can dereference a complex expression with a syntax that reads from left to right.

# For example, if you have an array reference,
# you can dereference the array with an array splat notation (@*):
sub demo_array_postfix_dereferencing {
    my $recipients = [
        qw(
          Mother
          Father
          Partner
          Nephew
          Niece
          Neighbor
        )
    ];

    for my $recipient ( $recipients->@* ) {
        say "Need to find a gift for $recipient.";
    }
}

# This simple example has little benefit in concision,
# but it's more useful with complex structures:
sub demo_array_postfix_dereferencing_1 {
    my %recipients = (
        mandatory => [
            qw(
              Partner
              Nephew
              Niece
            )
        ],
        optional => [
            qw(
              Mother
              Father
            )
        ],
        mmmmmmaybe => [
            qw(
              Neighbor
            )
        ],
    );

    for my $recipient ( $recipients{optional}->@* ) {
        say "Probably should find a gift for $recipient";
    }
}

# ... or with references returned from function or method calls:
# {
#     say "Have $200 to spend on " . join ', ',
#         get_recipients_for_budget({ usd => 200 })->@*;
# }
# This operation imposes scalar context on the function or method.

# Hashes use a similar notation, with the %* hash sigil and splat:
sub demo_hash_postfix_dereferencing {
    my $holiday_starts = {
        Hannukah  => '2020-12-10',
        Christmas => '2020-12-25',
        Kwanzaa   => '2020-12-26',
    };

    while ( my ( $holiday, $start_date ) = each $holiday_starts->%* ) {
        ...;
    }
}

# Again, you can dereference the return value of a function or method call in the same fashion:
# {
#     while (my ($holiday, $start_date) = each holiday_start_dates_for(2020)->%*) {
#         ...
#     }
# }

# This postfix dereferencing syntax allows both array and hash slices:
# {
#     my @pto_holidays     = $holiday_starts->@{qw( Hannukah Kwanzaa )};
#     my @first_recipients = $recipients->@[0 .. 3];
# }

# Scalars use the notation ->$*:
sub demo_scalar_postfix_dereferencing {
    my $not_a_constant = \"variable";
    say $not_a_constant->$*;
}

# This also works with functions or methods as you expect, but it provides no slice form.

# You may find it consistent to use only prefix, circumfix, or postfix dereferencing in a section of code.

done_testing();
