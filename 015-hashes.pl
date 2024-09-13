#!/usr/bin/env perl
# REF: http://modernperlbooks.com/books/modern_perl_2016/03-perl-language.html#SGFzaGVz

use 5.034;
use warnings;
use autodie;
use feature 'say';

use Test::More;

# A hash is an aggregate data structure which associates string keys with scalar values.
# Just as the name of a variable corresponds to something which holds a value,
# so a hash key refers to something which contains a value.
# Other languages call hashes tables, associative arrays, dictionaries, and maps.

# Hashes have two important properties:
# they store one scalar per unique key
# and they provide no specific ordering of keys.
# Keep that latter property in mind.
# Though it has always been true in Perl, it's very, very true in modern Perl.

# ================================
# Declaring Hashes
# ================================

# Hashes use the % sigil.
# Declare a lexical hash with:
# {
#     my %favorite_flavors;
# }
# A hash starts out empty. You could write my %favorite_flavors = ();, but that's redundant.

# Hashes use the scalar sigil $ when accessing individual elements and curly braces { } for keyed access:
{
    my %favorite_flavors;
    $favorite_flavors{Gabi}    = 'Dark chocolate raspberry';
    $favorite_flavors{Annette} = 'French vanilla';
}

# Assign a list of keys and values to a hash in a single expression:
{
    my %favorite_flavors =
      ( 'Gabi', 'Dark chocolate raspberry', 'Annette', 'French vanilla', );
}

# Hashes store pairs of keys and values.
# Perl will warn you if you assign an odd number of elements to a hash.
# Idiomatic Perl often uses the fat comma operator (=>) to associate values with keys,
# as it makes the pairing more visible:
{
    my %favorite_flavors = (
        Gabi    => 'Dark chocolate raspberry',
        Annette => 'French vanilla',
    );
}

# The fat comma operator acts like the regular comma
# and also automatically quotes the previous bareword (Barewords).
# The strict pragma will not warn about such a bareword.
# If you have a function with the same name as a hash key,
# the fat comma will not call the function:
# {
#     sub name { 'Leonardo' }

#     my %address = (
#         name => '1123 Fib Place'
#     );
# }
# The key of this hash will be name and not Leonardo.
# To call the function, make the function call explicit:
# {
#     my %address = (
#         name() => '1123 Fib Place'
#     );
# }

# You may occasionally see undef %hash, but that's a little ugly.
# Assign an empty list to empty a hash:
# {
#     %favorite_flavors = ();
# }

# ================================
# Hash Indexing
# ================================

# You may also use string literals as hash keys.
# Perl quotes barewords automatically according to the same rules as fat commas:
# {
#     # auto-quoted
#     my $address = $addresses{Victor};
#
#     # needs quoting; not a valid bareword
#     my $address = $addresses{'Sue-Linn'};
#
#     # function call needs disambiguation
#     my $address = $addresses{get_name()};
# }
# Novices often always quote string literal hash keys,
# but experienced developers elide the quotes whenever possible.
# If you code this way,
# you can use the rare presence of quotes to indicate that you're doing something special on purpose.

# TODO: review
# Even Perl builtins get the autoquoting treatment:
# {
#     my %addresses = (
#         Leonardo => '1123 Fib Place',
#         Utako    => 'Cantor Hotel, Room 1',
#     );
#
#     sub get_address_from_name {
#         return $addresses{+shift};
#     }
# }
# The unary plus (Unary Coercions) turns what would be a bareword (shift) subject
# to autoquoting rules into an expression.
# As this implies,
# you can use an arbitrary expression—not only a function call—as the key of a hash:
# {
#     # don't actually do this though
#     my $address = $addresses{reverse 'odranoeL'};
#
#     # interpolation is fine
#     my $address = $addresses{"$first_name $last_name"};
#
#     # so are method calls
#     my $address = $addresses{ $user->name };
# }

# TODO: review
# Hash keys can only be strings.
# Anything that evaluates to a string is an acceptable hash key.
# Perl will go so far as to coerce (Coercion) an expression into a string.
# For example, if you use an object as a hash key,
# you'll get the stringified version of that object instead of the object itself:
# {
#     for my $isbn (@isbns) {
#         my $book = Book->fetch_by_isbn( $isbn );
#
#         # unlikely to do what you want
#         $books{$book} = $book->price;
#     }
# }
# That stringified hash will look something like Book=HASH(0x222d148).
# Book refers to the class name.
# HASH identifies the object as a blessed reference.
# 0x22d148 is a number used to identify the object
# (more precisely: it's the location of the data structure representing the hash in memory,
# so it's neither quite random nor unique).

# ================================
# Hash Key Existence
# ================================

# The exists operator returns a boolean value to indicate whether a hash contains the given key:
sub demo_bash_key_existence {
    my %addresses = (
        Leonardo => '1123 Fib Place',
        Utako    => 'Cantor Hotel, Room 1',
    );

    say "Have Leonardo's address" if exists $addresses{Leonardo};
    say "Have Warnie's address"   if exists $addresses{Warnie};
}

# TODO: review
# Using exists instead of accessing the hash key directly avoids two problems.
# First, it does not check the boolean nature of the hash value;
# a hash key may exist with a value even if that value evaluates to a boolean false (including undef):
# {
#     my %false_key_value = ( 0 => '' );
#     ok %false_key_value,
#       'hash containing false key & value should evaluate to a true value';
# }
# Second, exists avoids autovivification (Autovivification) within nested data structures (Nested Data Structures).
# If a hash key exists, its value may be undef. Check that with defined:
# {
#     $addresses{Leibniz} = undef;
#
#     say "Gottfried lives at $addresses{Leibniz}"
#         if exists  $addresses{Leibniz}
#         && defined $addresses{Leibniz};
# }

# ================================
# Accessing Hash Keys and Values
# ================================

# Hashes are aggregate variables,
# but their pairwise nature is unique.
# Perl allows you to iterate over a hash's keys, its values, or pairs of its keys and values.
# The keys operator produces a list of hash keys:
# {
#     for my $addressee (keys %addresses) {
#         say "Found an address for $addressee!";
#     }
# }

# The values operator produces a list of hash values:
# {
#     for my $address (values %addresses) {
#         say "Someone lives at $address";
#     }
# }

# The each operator produces a list of two-element key/value lists:
# {
#     while (my ($addressee, $address) = each %addresses) {
#         say "$addressee lives at $address";
#     }
# }

# Unlike arrays, hash elements have no obvious ordering.
# The ordering depends on the internal implementation of the hash,
# the particular version of Perl you are using,
# the size of the hash,
# and a random factor.
# Even so, the order of hash items is consistent between keys, values, and each.
# Modifying the hash may change the order,
# but you can rely on that order if the hash remains the same.

# However, even if two hashes have the same keys and values,
# you cannot rely on the iteration order between those hashes being the same.
# They may have been constructed differently or have had elements removed.
# Since Perl 5.18,
# even if you build two hashes in the same way,
# you cannot depend on the same iteration order between them.

# Each hash has only a single iterator for the each operator.
# You cannot reliably iterate over a hash with each more than once;
# if you begin a new iteration while another is in progress,
# the former will end prematurely
# and the latter will begin partway through the iteration.
# !!! Beware not to call any function which may itself try to iterate over the hash with each.
# This is rarely a problem, but it's not fun to debug.

# Reset a hash's iterator with keys or values in void context:
# {
#     # reset hash iterator
#     keys %addresses;
#
#     while (my ($addressee, $address) = each %addresses) {
#         ...
#     }
# }

# ================================
# Hash Slices
# ================================

# TODO: review
# A hash slice is a list of keys or values of a hash indexed in a single operation.
# To initialize multiple elements of a hash at once:
{
    my %cats;
    @cats{qw( Jack Brad Mars Grumpy )} = (1) x 4;
}

# This is equivalent to the initialization:
{
    my %cats = map { $_ => 1 } qw( Jack Brad Mars Grumpy );
}

# Note however that the hash slice assignment can also add to the existing contents of the hash.

#  Hash slices also allow you to retrieve multiple values from a hash in a single operation.
# As with array slices, the sigil of the hash changes to @ to indicate list context.
# The use of the curly braces indicates keyed access
# and makes the fact that you're working with a hash unambiguous:
# {
#     my @buyer_addresses = @addresses{ @buyers };
# }

# Hash slices make it easy to merge two hashes:
# {
#     my %addresses        = ( ... );
#     my %canada_addresses = ( ... );
#
#     @addresses{ keys %canada_addresses } = values %canada_addresses;
# }
# This is equivalent to looping over the contents of %canada_addresses manually,
# but is much shorter.
# Note that this relies on the iteration order of the hash remaining consistent between keys and values.
# Perl guarantees this,
# but only because these operations occur on the same hash with no modifications to that hash between the keys and values operations.

# What if the same key occurs in both hashes?
# The hash slice approach always overwrites existing key/value pairs in %addresses.
# If you want other behavior, looping is more appropriate.

# ================================
# The Empty Hash
# ================================

# An empty hash contains no keys or values.
# It evaluates to a false value in a boolean context.
# A hash which contains at least one key/value pair evaluates to a true value in boolean context
# even if all of the keys or all of the values or both would themselves evaluate to boolean false values.
sub demo_empty_hash {
    my %empty;
    ok !%empty, 'empty hash should evaluate false';

    my %false_key = ( 0 => 'true value' );
    ok %false_key, 'hash containing false key should evaluate to true';

    my %false_value = ( 'true key' => 0 );
    ok %false_value, 'hash containing false value should evaluate to true';
}

# TODO: review
# In scalar context, a hash evaluates to a string
# which represents the ratio of full buckets in the hash—
# internal details about the hash implementation that you can safely ignore.
# In a boolean scalar context, this ratio evaluates to a false value,
# so remember that instead of the ratio details.
# In list context, a hash evaluates to a list of key/value pairs
# similar to the list produced by the each operator.
# However, you cannot iterate over this list the same way you can iterate over the list produced by each.
# This loop will never terminate:
# {
#     # infinite loop for non-empty hashes
#     while (my ($key, $value) = %hash) {
#         ...
#     }
# }

# You can loop over the list of keys and values with a for loop,
# but the iterator variable will get a key on one iteration and its value on the next,
# because Perl will flatten the hash into a single list of interleaved keys and values.

# ================================
# Hash Idioms
# ================================

# Because each key exists only once in a hash,
# assigning the same key to a hash multiple times
# stores only the most recent value associated with that key.
# This behavior has advantages!
# For example, to find unique elements of a list:
sub demo_unique_elements {
    my @items;
    my %uniq;

    undef @uniq{@items};
    my @uniques = keys %uniq;
}

# NOTE: Using undef with a hash slice sets the values of the hash to undef.
# This idiom is the cheapest way to perform set operations with a hash.

# Hashes are useful for counting elements,
# such as IP addresses in a log file:
sub demo_counting_elements {
    open my $logfile, '<', '';
    my %ip_addresses;

    while ( my $line = <$logfile> ) {
        chomp $line;
        my ( $ip, $resource ) = analyze_line($line);
        $ip_addresses{$ip}++;
        ...;
    }
}

# The initial value of a hash value is undef.
# The postincrement operator (++) treats that as zero.
# This in-place modification of the value increments an existing value for that key.
# If no value exists for that key,
# Perl creates a value (undef) and immediately increments it to one,
# as the numification of undef produces the value 0.

# This strategy provides a useful caching mechanism
# to store the result of an expensive operation with little overhead:
{
    my %user_cache;

    sub fetch_user {
        my $id = shift;
        $user_cache{$id} //= create_user($id);
        return $user_cache{$id};
    }
}

# This orcish maneuver (or-cache) returns the value from the hash, if it exists.
# Otherwise, it calculates, caches, and returns the value.
# The defined-or assignment operator (//=) evaluates its left operand.
# If that operand is not defined,
# the operator assigns to the lvalue the value of its right operand.
# In other words, if there's no value in the hash for the given key,
# this function will call create_user() with the key and update the hash.
# You may see older code which uses the boolean-or assignment operator (||=) for this purpose.
# Remember though that some valid values evaluate as false in a boolean context.
# The defined-or operator usually makes more sense,
# as it tests for definedness instead of truthiness.

# If your function takes several arguments,
# use a slurpy hash (Slurping) to gather key/value pairs into a single hash
# as named function arguments:
sub demo_slurpy_hash {

    sub make_sundae {
        my %parameters = @_;
        ...;
    }

    make_sundae(
        flavor  => 'Lemon Burst',
        topping => 'cookie bits'
    );
}

# This approach allows you to set default values:
sub make_sundae_with_defaults_1 {
    my %parameters = @_;
    $parameters{flavor}    //= 'Vanilla';
    $parameters{topping}   //= 'fudge';
    $parameters{sprinkles} //= 100;
    ...;
}

# ... or include them in the hash initialization,
# as latter assignments take precedence over earlier assignments:
sub make_sundae_with_defaults_2 {
    my %parameters = (
        flavor    => 'Vanilla',
        topping   => 'fudge',
        sprinkles => 100,
        @_,
    );
    ...;
}

# ================================
# Locking Hashes
# ================================

# As hash keys are barewords, they offer little typo protection
# compared to the function and variable name protection offered by the strict pragma.
# The little-used core module Hash::Util can make hashes safer.

# To prevent someone from accidentally adding a hash key you did not intend
# (whether as a typo or from untrusted user input),
# use the lock_keys() function to restrict the hash to its current set of keys.
# Any attempt to add a new key to the hash will raise an exception.
# Similarly you can lock or unlock the existing value for a given key in the hash
# (lock_value() and unlock_value())
# and make or unmake the entire hash read-only with lock_hash() and unlock_hash().

# This is lax security;
# anyone can use the appropriate unlocking functions to work around the locking.
# Yet it does protect against typos and other unintended accidents.

done_testing();
