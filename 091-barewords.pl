#!/usr/bin/env perl
# REF: http://modernperlbooks.com/books/modern_perl_2016/11-what-to-avoid-in-perl.html#QmFyZXdvcmRz

use 5.034;
use warnings;
use autodie;
use feature 'say';

use Test::More;

# Perl's parser understands Perl's builtins and operators.
# It uses sigils to identify variables and other punctuation to recognize function and method calls.
# Yet sometimes the parser has to guess what you mean,
# especially when you use a bareword—
# an identifier without a sigil or other syntactically significant punctuation.

# ================================
# Good Uses of Barewords
# ================================

# Though the strict pragma (Pragmas) rightly forbids ambiguous barewords,
# some barewords are acceptable.

# ================================
# Good Uses of Barewords - Bareword hash keys
# ================================

# Hash keys in Perl are usually not ambiguous
# because the parser can identify them as string keys;
# pinball in $games{pinball} is obviously a string.

# Occasionally this interpretation is not what you want,
# especially when you intend to evaluate a builtin or a function to produce the hash key.
# To make these cases clear,
# pass arguments to the function,
# use parentheses,
# or prepend a unary plus to force the evaluation of the builtin:
sub demo_hash_keys_barewords {
    my %items;

    # the literal 'shift' is the key
    my $value_1 = $items{shift};

    # the value produced by shift is the key
    my $value_2 = $items{ shift @_ };

    # the function returns the key
    my $value_3 = $items{ myshift(@_) };

    # unary plus indicates the builtin shift
    my $value_4 = $items{ +shift };
}

# ================================
# Good Uses of Barewords - Bareword package names
# ================================

# Package names are also barewords.
# If your naming conventions rule that package names have initial capitals and functions do not,
# you'll rarely encounter naming collisions.
# Even still, Perl must determine how to parse Package->method.
# Does it mean "call a function named Package() and call method() on its return value?"
# or "Call a method named method() in the Package namespace?"
# The answer depends on the code Perl has already compiled when it encounters that method call.

# Force the parser to treat Package as a package name by appending the package separator (::)
# or make it a literal string:
sub demo_package_barewords {

    # probably a class method
    Package->method;

    # definitely a class method
    Package::->method;

    # a slightly less ugly class method
    'Package'->method;

    # package separator
    my $q = Plack::Request::->new;

    # unambiguously a string literal
    my $q = 'Plack::Request'->new;
}

# Almost no real code does this, but it's unambiguous, so be able to read it.

# ================================
# TODO: review Good Uses of Barewords - Bareword named code blocks
# ================================

# The special named code blocks
# AUTOLOAD, BEGIN, CHECK, DESTROY, END, INIT, and UNITCHECK
# are barewords which declare functions without the sub builtin.
# You've seen this before (Code Generation):
# {
#     package Monkey::Butler;
#
#     BEGIN { initialize_simians( __PACKAGE__ ) }
#
#     sub AUTOLOAD { ... }
# }
# While you can declare AUTOLOAD() without using sub, few people do.

# ================================
# Good Uses of Barewords - Bareword constants
# ================================

# Constants declared with the constant pragma are usable as barewords:
{
    my $name = '';
    my $pass = '';

    use constant NAME     => 'Bucky';
    use constant PASSWORD => '|38fish!head74|';

    return unless $name eq NAME && $pass eq PASSWORD;
}

# These constants do not interpolate in double-quoted strings.

# Constants are a special case of prototyped functions (Prototypes).
# When you predeclare a function with a prototype,
# the parser will treat all subsequent uses of that bareword specially—
# and will warn about ambiguous parsing errors.
# All other drawbacks of prototypes still apply.

# ================================
# Ill-Advised Uses of Barewords
# ================================

# No matter how cautiously you code,
# barewords still produce ambiguous code.
# You can avoid the worst abuses,
# but you will encounter several types of barewords in legacy code.

# ================================
# Ill-Advised Uses of Barewords - Bareword hash values
# ================================

# Some old code may not take pains to quote the values of hash pairs:
{
    no strict 'subs';

    # poor style; do not use
    my %parents = (
        mother => Annette,
        father => Floyd,
    );
}

# When neither the Floyd() nor Annette() functions exist,
# Perl will interpret these barewords as strings.
# strict 'subs' will produce an error in this situation.

# ================================
# Ill-Advised Uses of Barewords - Bareword function calls
# ================================

# Code written without (strict 'subs') may use bareword function names.
# Adding parentheses will make the code pass strictures.
# Use `perl -MO=Deparse,-p` (see perldoc B::Deparse) to discover how Perl parses them,
# then parenthesize accordingly.

# ================================
# Ill-Advised Uses of Barewords - Bareword filehandles
# ================================

# Prior to lexical filehandles (Filehandle References),
# all file and directory handles used barewords.
# You can almost always safely rewrite this code to use lexical filehandles.
# Perl's parser recognizes the special exceptions of STDIN, STDOUT, and STDERR.

# ================================
# Ill-Advised Uses of Barewords - Bareword sort functions
# ================================

# The second operand of the (sort) builtin can be the name of a function to use for sorting.
# While this is rarely ambiguous to the parser,
# it can confuse human readers.
# The alternative of providing a function reference in a scalar is little better:
{
    my @unsorted;

    # bareword style
    my @sorted_1 = sort compare_lengths @unsorted;

    # function reference in scalar
    my $comparison = \&compare_lengths;
    my @sorted_2   = sort $comparison @unsorted;
}

# The second option avoids the use of a bareword, but the result is longer.
# Unfortunately, Perl's parser does not understand the single-line version due to the special parsing of sort;
# you cannot use an arbitrary expression (such as taking a reference to a named function)
# where a block or a scalar might otherwise go.
# {
#     # does not work
#     my @sorted = sort \&compare_lengths @unsorted;
# }

# In both cases, the way sort invokes the function and provides arguments can be confusing
# (see perldoc -f sort for the details).
# Where possible, consider using the block form of sort instead.
# If you must use either function form,
# add a comment about what you're doing and why.

done_testing();
