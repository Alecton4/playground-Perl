#!/usr/bin/env perl
# REF: http://modernperlbooks.com/books/modern_perl_2016/03-perl-language.html#VmFsdWVz

use 5.034;
use warnings;
use autodie;
use feature 'say';

use Test::More;

# New programmers spend a lot of time thinking about what their programs must do.
# Mature programmers spend their time designing a model for the data their programs must understand.

# Variables allow you to manipulate data in the abstract.
# The values held in variables make programs concrete and useful.
# These values are your aunt's name and address,
# the distance between your office and a golf course on the moon,
# or the sum of the masses of all of the cookies you've eaten in the past year.
# Within your program, the rules regarding the format of that data are often strict.

# Effective programs need effective (simple, fast, efficient, easy) ways to represent their data.

# ================================
# Strings
# ================================

# A string is a piece of textual or binary data
# with no particular formatting or contents.
# It could be your name, an image read from disk, or the source code of the program itself.
# A string has meaning in the program only when you give it meaning.

# A literal string appears in your program surrounded by a pair of quoting characters.
# The most common string delimiters are single and double quotes:
{
    my $name    = 'Donner Odinson, Bringer of Despair';
    my $address = "Room 539, Bilskirnir, Valhalla";
}

# Characters in a single-quoted string are exactly and only ever what they appear to be,
# NOTE: with two exceptions.
# To include a single quote inside a single-quoted string,
# you must escape it with a leading backslash:
{
    my $reminder = 'Don\'t forget to escape ' . 'the single quote!';
}

# To include a backslash at the end of a string,
# escape it with another leading backslash.
# Otherwise Perl will think you're trying to escape the closing delimiter:
{
    my $exception = 'This string ends with a ' . 'backslash, not a quote: \\';
}

# Any other backslash will be part of the string as it appears,
# unless you have two adjacent backslashes,
# in which case Perl will believe that you intended to escape the second:
{
    is 'Modern \ Perl', 'Modern \\ Perl', 'single quotes backslash escaping';
}

# A double-quoted string gives you more options,
# such as encoding otherwise invisible whitespace characters in the string:
{
    my $tab       = "\t";
    my $newline   = "\n";
    my $carriage  = "\r";
    my $formfeed  = "\f";
    my $backspace = "\b";
}

# You may have inferred from this that you can represent the same logical string in multiple ways.
# You can include a tab within a string by typing the \t escape sequence
# or by hitting the Tab key on your keyboard.
# Both strings look and behave the same to Perl,
# even though the representation of the string may differ in the source code.

# A string declaration may cross (and include) newlines,
# so these two declarations are equivalent:
{
    my $escaped = "two\nlines";
    my $literal = "two
    lines";
    is $escaped, $literal, 'equivalent \n and newline';
}

# ... but the escape sequences are easier for humans to read.

# Perl strings have variable—not fixed—lengths.
# Perl will change their sizes for you as you modify and manipulate them.
# Use the concatenation operator . to combine multiple strings together:
{
    my $kitten = 'Choco' . ' ' . 'Spidermonkey';
}

# ... though concatenating three literal strings like this
# is ultimate the same to Perl as writing a single string.

# When you interpolate the value of a scalar variable or the values of an array within a double-quoted string,
# the current contents of the variable become part of the string as if you'd concatenated them:
{
    my $name    = 'HaHa';
    my $address = 'HK';

    my $factoid = "$name lives at $address!";

    # equivalent to
    my $factoid_equivalent = $name . ' lives at ' . $address . '!';
}

# Include a literal double-quote inside a double-quoted string
# by escaping it with a leading backslash:
{
    my $quote = "\"Ouch,\", he cried. \"That hurt!\"";
}

sub demo_single_and_double_quotes {
    my @arr = "A" .. "Z";
    my $i   = 4;
    say "$arr[$i]";
    say "${arr[$i]}";
    say "'$arr[$i]'";
    say "'${arr[$i]}'";
    say '$arr[$i]';
    say '${$arr[$i]}';
    say '"$arr[$i]"';
    say '"${$arr[$i]}"';
}

# Repeated backslashing sometimes becomes unwieldy.
# A quoting operator allows you to choose an alternate string delimiter.
# The q operator indicates single quoting (no interpolation),
# while the qq operator provides double quoting behavior (interpolation).
# The character immediately following the operator determines the characters used as delimiters.
# If the character is the opening character of a balanced pair—
# such as opening and closing braces—
# the closing character will be the final delimiter.
# Otherwise, the character itself will be both the starting and ending delimiter.
{
    my $quote     = qq{"Ouch", he said. "That hurt!"};
    my $reminder  = q^Don't escape the single quote!^;
    my $complaint = q{It's too early to be awake.};
}

# Use the heredoc syntax to assign multiple lines to a string:
{
    my $blurb = <<'END_BLURB';

    He looked up. "Change is the constant on which they all
    can agree.  We instead, born out of time, remain perfect
    and perfectly self-aware. We only suffer change as we
    pursue it. It is against our nature. We rebel against
    that change. Shall we consider them greater for it?"
END_BLURB
}

# This syntax has three parts.
# The double angle-brackets introduce the heredoc.
# The quotes determine whether the heredoc follows single- or double-quoted behavior;
# NOTE: double-quoted behavior is the default.
# END_BLURB is an arbitrary identifier,
# chosen by the programmer,
# used as the ending delimiter.

# Regardless of the indentation of the heredoc declaration itself,
# the ending delimiter must start at the beginning of the line:

sub some_function {
    my $ingredients = <<'END_INGREDIENTS';
        Two eggs
        One cup flour
        Two ounces butter
        One-quarter teaspoon salt
        One cup milk
        One drop vanilla
        Season to taste
END_INGREDIENTS
}

# NOTE: If the identifier begins with whitespace,
# that same whitespace must be present before the ending delimiter—
# that is, <<' END_HEREDOC'>> needs a leading space before END_HEREDOC.
# Yet if you indent the identifier,
# Perl will not remove equivalent whitespace from the start of each line of the heredoc.
# Keep that design wart in mind; it'll eventually surprise you.

# Using a string in a non-string context will induce coercion (Coercion).

# ================================
# Unicode and Strings
# ================================

# Unicode is a system used to represent the characters of the world's written languages.
# Most English text uses a character set of only 127 characters
# (which requires seven bits of storage and fits nicely into eight-bit bytes),
# but it's naïve to believe that you won't someday need an umlaut.

# Perl strings can represent either of two separate but related data types:
#
#    Sequences of Unicode characters
#    Each character has a codepoint,
#    a unique number which identifies it in the Unicode character set.
#
#    Sequences of octets
#    Binary data in a sequence of octets—8 bit numbers,
#    each of which can represent a number between 0 and 255.

# Why octet and not byte?
# An octet is unambiguously eight bits.
# A byte can be fewer or more bits, depending on esoteric hardware.
# Assuming that one character fits in one byte will cause you no end of Unicode grief.
# Separate the idea of memory storage from character representation.
# Forget that you ever heard of bytes.

# Unicode strings and binary strings look superficially similar.
# Each has a length().
# Each supports standard string operations
# such as concatenation, splicing, and regular expression processing (Regular Expressions and Matching).
# Any string which is not purely binary data is textual data,
# and thus should be a sequence of Unicode characters.

# However, because of how your operating system represents data on disk
# or from users or over the network—as sequences of octets—
# Perl can't know if the data you read is an image file or a text document or anything else.
# By default, Perl treats all incoming data as sequences of octets.
# It's up to you to give that data meaning.

# ================================
# Unicode and Strings - Character Encodings
# ================================

# A Unicode string is a sequence of octets which represents a sequence of characters.
# A Unicode encoding maps octet sequences to characters.
# Some encodings, such as UTF-8,
# can encode all of the characters in the Unicode character set.
# Other encodings represent only a subset of Unicode characters.
# For example, ASCII encodes plain English text (no accented characters allowed),
# while Latin-1 can represent text in most languages which use the Latin alphabet
# (umlauts, grave and circumflex accents, et cetera).

# Perl 5.16 supports the Unicode 6.1 standard,
# 5.18 the 6.2 standard,
# 5.20 the 6.3 standard,
# and 5.22 the 7.0 standard.
# See http://unicode.org/versions/.

# !!! To avoid most Unicode problems,
# always decode to and from the appropriate encoding
# at the inputs and outputs of your program.
# Read that sentence again. Memorize it. You'll be glad of it later.

# ================================
# Unicode and Strings - Unicode in Your Filehandles
# ================================

# TODO: review
# When you tell Perl that a specific filehandle (Files)
# should interpret data via specific Unicode encoding,
# Perl will use an IO layer to convert between octets and characters.
# The mode operand of the open builtin allows you to request an IO layer by name.
# For example, the :utf8 layer decodes UTF-8 data:
# {
#     open my $fh, '<:utf8', $textfile;
#
#     my $unicode_string = <$fh>;
# }
# Use binmode to apply an IO layer to an existing filehandle:
# {
#     binmode $fh, ':utf8';
#     my $unicode_string = <$fh>;
#
#     binmode STDOUT, ':utf8';
#     say $unicode_string;
# }
# If you want to write Unicode to files,
# you must specify the desired encoding.
# Otherwise, Perl will warn you when you print Unicode characters that don't look like octets;
# this is what Wide character in %s means.

# Use the utf8::all module to add the UTF-8 IO layer to all filehandles throughout your program.
# The module also enables all sorts of other Unicode features.
# It's very handy, but it's a blunt instrument
# and no substitute for understanding what your program needs to do.

# ================================
# Unicode and Strings - Unicode in Your Data
# ================================

# The core module Encode's decode() function converts a sequence of octets
# to Perl's internal Unicode representation.
# The corresponding encode() function converts from Perl's internal encoding
# to the desired encoding:
# {
#     my $from_utf8 = decode('utf8', $data);
#     my $to_latin1 = encode('iso-8859-1', $string);
# }

# To handle Unicode properly,
# you must always decode incoming data via a known encoding
# and encode outgoing data to a known encoding.
# Again, you must know what kind of data you expect to consume and to produce.
# Being specific will help you avoid all kinds of trouble.

# ================================
# Unicode and Strings - Unicode in Your Programs
# ================================

# The easiest way to use Unicode characters in your source code
# us with the utf8 pragma (Pragmas), # ??? us should be is?
# which tells the Perl parser to decode the rest of the file as UTF-8 characters.
# This allows you to use Unicode characters in strings and identifiers:
# {
#     use utf8;
#
#     sub £_to_¥ { ... }
#
#     my $yen = £_to_¥('1000£');
# }
# To write this code,
# your text editor must understand UTF-8
# and you must save the file with the appropriate encoding.
# Again, any two programs which communicate with Unicode data must agree on the encoding of that data.

# Within double-quoted strings,
# you may also use a Unicode escape sequence to represent character encodings.
# The syntax \x{} represents a single character;
# place the hex form of the character's Unicode number http://unicode.org/charts/ within the curly brackets:
{
    my $escaped_thorn = "\x{00FE}";
}

# Some Unicode characters have names,
# which make them easier for other programmers to read.
# Use the charnames pragma to enable named characters via the \N{} escape syntax:
{
    use charnames ':full';
    use Test::More tests => 1;

    my $escaped_thorn = "\x{00FE}";
    my $named_thorn   = "\N{LATIN SMALL LETTER THORN}";

    is $escaped_thorn, $named_thorn, 'Thorn equivalence check';
}

# You may use the \x{} and \N{} forms within regular expressions
# as well as anywhere else you may legitimately use a string or a character.

# ================================
# Unicode and Strings - Canonical Forms and Compatible Forms
# ================================

# REF: Learning Perl, 8th ed. P. 345

# You can decompose and recompose canonical forms,
# but you cannot necessarily recompose compatible forms.
# If you decompose the ligature fi,
# you get the separate graphemes f and i.
# The recomposer has no way to know if those came from a ligature or started separately.
# (This is why we’re ignoring NFC and NFKC.
# Those forms decompose then recompose, but NFKC can’t necessarily recompose to the original form.)
# Again, that’s the difference in canonical and compatible forms:
# the canonical forms look the same either way.

sub demo_canonical_and_compatible_forms {
    use utf8;
    use Unicode::Normalize;

    # U+FB01 - fi ligature
    # U+0065 U+0301 - decomposed é
    # U+00E9 - composed é
    binmode STDOUT, ':utf8';
    my $string = "Can you \x{FB01}nd my r\x{E9}sum\x{E9}?";
    if ( $string =~ /\x{65}\x{301}/ ) {
        print "Oops! Matched a decomposed é\n";
    }
    if ( $string =~ /\x{E9}/ ) {
        print "Yay! Matched a composed é\n";
    }
    my $nfd = NFD($string);
    if ( $nfd =~ /\x{E9}/ ) {
        print "Oops! Matched a composed é\n";
    }
    if ( $nfd =~ /fi/ ) {
        print "Oops! Matched a decomposed fi\n";
    }
    my $nfkd = NFKD($string);
    if ( $string =~ /fi/ ) {
        print "Oops! Matched a decomposed fi\n";
    }
    if ( $nfkd =~ /fi/ ) {
        print "Yay! Matched a decomposed fi\n";
    }
    if ( $nfkd =~ /\x{65}\x{301}/ ) {
        print "Yay! Matched a decomposed é\n";
    }
}

# ================================
# Unicode and Strings - Implicit Conversion
# ================================

# Most Unicode problems in Perl arise from the fact
# that a string could be either a sequence of octets or a sequence of characters.
# Perl allows you to combine these types through the use of implicit conversions.
# When these conversions are wrong,
# they're rarely obviously wrong but they're also often spectacularly wrong
# in ways that are difficult to debug.

# When Perl concatenates a sequence of octets with a sequence of Unicode characters,
# it implicitly decodes the octet sequence using the Latin-1 encoding.
# The resulting string will contain Unicode characters.
# When you print Unicode characters,
# Perl will encode the string using UTF-8,
# because Latin-1 cannot represent the entire set of Unicode characters—
# because Latin-1 is a subset of UTF-8.

# The asymmetry between encodings and octets can lead to Unicode strings encoded as UTF-8 for output
# and decoded as Latin-1 from input.
# Worse yet, when the text contains only English characters with no accents,
# the bug stays hidden,
# because both encodings use the same representation for every character.

# You don't have to understand all of this right now;
# just know that this behavior happens and that it's not what you want.
# {
#     my $hello    = "Hello, ";
#     my $greeting = $hello . $name;
# }
# If $name contains Alice, you will never notice any problem:
# because the Latin-1 representation is the same as the UTF-8 representation.
# If $name contains José, $name can contain several possible values:
#
#     $name contains four Unicode characters.
#     $name contains four Latin-1 octets representing four Unicode characters.
#     $name contains five UTF-8 octets representing four Unicode characters.
#
# The string literal has several possible scenarios:
#
#     It is an ASCII string literal and contains octets:
#         my $hello = "Hello, ";
#     It is a Latin-1 string literal with no explicit encoding and contains octets:
#         my $hello = "¡Hola, ";
#     It is a non-ASCII string literal (the utf8 or encoding pragma is in effect) and contains Unicode characters:
#         my $hello = "Kuirabá, ";

# If both $hello and $name are Unicode strings,
# the concatenation will produce another Unicode string.
# If both strings are octet sequences,
# Perl will concatenate them into a new octet sequence.
# If both values are octets of the same encoding—
# both Latin-1, for example,
# the concatenation will work correctly.
# If the octets do not share an encoding—
# for example, a concatenation appending UTF-8 data to Latin-1 data—
# then the resulting sequence of octets makes sense in neither encoding.
# This could happen if the user entered a name as UTF-8 data
# and the greeting were a Latin-1 string literal,
# but the program decoded neither.

# If only one of the values is a Unicode string,
# Perl will decode the other as Latin-1 data.
# If this is not the correct encoding,
# the resulting Unicode characters will be wrong.
# For example, if the user input were UTF-8 data
# and the string literal were a Unicode string,
# the name would be incorrectly decoded into five Unicode characters
# to form JosÃ© (sic) instead of José
# because the UTF-8 data means something else when decoded as Latin-1 data.

# Again, you don't have to follow all of the details here if you remember this:
# always decode on input and encode on output.

# See perldoc perluniintro for a far more detailed explanation of Unicode, encodings,
# and how to manage incoming and outgoing data in a Unicode world.
# For far more detail about managing Unicode effectively throughout your programs,
# see Tom Christiansen's answer to "Why does Modern Perl avoid UTF-8 by default?"
# http://stackoverflow.com/questions/6162484/why-does-modern-perl-avoid-utf-8-by-default/6163129#6163129
# and his "Perl Unicode Cookbook" series http://www.perl.com/pub/2012/04/perlunicook-standard-preamble.html.

# If you work with Unicode in Perl,
# use at least Perl 5.18 (and ideally the latest version).
# See also the feature pragma for information on the unicode_strings feature.

# ================================
# Numbers
# ================================

# Perl supports numbers as both integers and floating-point values.
# You may represent them with scientific notation as well as in binary, octal, and hexadecimal forms:
{
    my $integer   = 42;
    my $float     = 0.007;
    my $sci_float = 1.02e14;
    my $binary    = 0b101010;
    my $octal     = 052;
    my $hex       = 0x20;

    # only in Perl 5.22
    my $hex_float = 0x1.0p-3;
}

# The numeric prefixes 0b, 0, and 0x specify binary, octal, and hex notation respectively.
# Be aware that a leading zero on an integer always indicates octal mode.

# You may not use commas to separate thousands in numeric literals,
# as the parser will interpret them as the comma operator.
# Instead, use underscores.
# These three examples are equivalent, though the second might be the most readable:
{
    my $billion_1 = 1000000000;
    my $billion_2 = 1_000_000_000;
    my $billion_3 = 10_0_00_00_0_0_0;
}

# Because of coercion (Coercion),
# Perl programmers rarely have to worry about converting incoming data to numbers.
# Perl will treat anything which looks like a number as a number when evaluated in a numeric context.
# In the rare circumstances where you need to know if something looks like a number
# without evaluating it in a numeric context,
# use the looks_like_number function from the core module Scalar::Util.
# This function returns a true value if Perl will consider the given argument numeric.

# The Regexp::Common module from the CPAN provides several well-tested regular expressions
# to identify more specific types of numeric values such as whole numbers, integers, and floating-point values.

# What's the maximum size of a value you can represent in Perl? It depends;
# you're probably using a 64-bit build,
# so the largest integer is (2**31) - 1 and the smallest is -(2**31)—
# though see perldoc perlnumber for more thorough details.
# Use Math::BigInt and Math::BigFloat to handle with larger or smaller or more precise numbers.

# ================================
# Undef
# ================================

# Perl's undef value represents an unassigned, undefined, and unknown value.
# Declared but undefined scalar variables contain undef.

# The defined builtin returns a true value if its operand evaluates to a defined value (anything other than undef):
sub demo_undef {
    my $status = 'suffering from a cold';

    say defined $status;    # 1, which is a true value
    say defined undef;      # empty string; a false value
}

# ===============================
# The Empty List
# ================================

# When used on the right-hand side of an assignment, the () construct represents an empty list.
# In scalar context, this evaluates to undef.
# In list context, it is an empty list.
# When used on the left-hand side of an assignment, the () construct imposes list context.
# Hence this idiom (Idioms) to count the number of elements returned from an expression in list context without using a temporary variable:
# {
#     my $count = () = get_clown_hats();
# }
# Because of the right associativity (Associativity) of the assignment operator,
# Perl first evaluates the second assignment by calling get_clown_hats() in list context. This produces a list.
# Assignment to the empty list throws away all of the values of the list,
# but that assignment takes place in scalar context,
# which evaluates to the number of items on the right hand side of the assignment.
# As a result, $count contains the number of elements in the list returned from get_clown_hats().

# ================================
# Lists
# ================================

# NOTE: Parentheses do not create lists.
# The comma operator creates lists.
# The parentheses in these examples merely group expressions to change their precedence (Precedence).

# Lists and arrays are not interchangeable in Perl.
# Lists are values. Arrays are containers.
# You may store a list in an array and you may coerce an array to a list,
# but they are separate entities.

# For example, indexing into a list always occurs in list context.
# Indexing into an array can occur in scalar context (for a single element) or list context (for a slice):
sub list_vs_array {

    # don't worry about the details right now
    sub context {
        my $context = wantarray();

        say defined $context
          ? $context
              ? 'list'
              : 'scalar'
          : 'void';
        return 0;
    }

    my @list_slice  = ( 1, 2, 3 )[ context() ];
    my @array_slice = @list_slice[ context() ];
    my $array_index = $array_slice[ context() ];

    say context();    # list context
    context();        # void context
}

done_testing();
