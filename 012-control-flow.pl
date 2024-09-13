#!/usr/bin/env perl
# REF: http://modernperlbooks.com/books/modern_perl_2016/03-perl-language.html#Q29udHJvbEZsb3c

use 5.034;
use warnings;
use autodie;
use feature 'say';

use Test::More;

# Perl's basic control flow is straightforward.
# Program execution starts at the beginning
# (the first line of the file executed) and continues to the end:
{
    say 'At start';
    say 'In middle';
    say 'At end';
}

# Perl's control flow directives change the order of what happens next in the program.

# ================================
# Branching Directives
# ================================

# The (if) directive performs the associated action
# only when its conditional expression evaluates to a true value:
{
    my $name = 'Alice';
    say 'Hello, Bob!' if $name eq 'Bob';
}

# This postfix form is useful for simple expressions.
# Its block form groups multiple expressions into a unit which evaluates to a single boolean value:
# {
#     if ($name eq 'Bob') {
#         say 'Hello, Bob!';
#         found_bob();
#     }
# }

# The conditional expression may consist of multiple subexpressions
# which will be coerced to a boolean value:
# {
#     if ($name eq 'Bob' && not greeted_bob()) {
#         say 'Hello, Bob!';
#         found_bob();
#     }
# }

# The block form requires parentheses around its condition,
# but the postfix form does not.
# In the postfix form, adding parentheses can clarify the intent of the code
# at the expense of visual cleanliness:
# {
#     greet_bob() if ($name eq 'Bob' && not greeted_bob());
# }

# The (unless) directive is the negated form of (if).
# Perl will perform the action
# when the conditional expression evaluates to a false value:
{
    my $name = 'Alice';
    say "You're not Bob!" unless $name eq 'Bob';
}

# Like (if), (unless) also has a block form,
# though many programmers avoid it due to its potential for confusion:
# {
#     unless (is_leap_year() and is_full_moon()) {
#         frolic();
#         gambol();
#     }
# }

# (unless) works very well for postfix conditionals,
# NOTE: especially parameter validation in functions (Postfix Parameter Validation):
sub frolic {

    # do nothing without parameters
    return unless @_;

    for my $chant (@_) { ... }
}

# The block forms of (if) and (unless) both support the (else) directive,
# which provides a block to execute
# when the conditional expression does not evaluate to the appropriate value:
sub demo_if_else {
    my $name = 'Alice';
    if ( $name eq 'Bob' ) {
        say 'Hi, Bob!';
        greet_user();
    }
    else {
        say "I don't know you.";
        shun_user();
    }
}

# (else) blocks allow you to rewrite (if) and (unless) conditionals in terms of each other:
sub demo_unless_else {
    my $name = 'Alice';
    unless ( $name eq 'Bob' ) {
        say "I don't know you.";
        shun_user();
    }
    else {
        say 'Hi, Bob!';
        greet_user();
    }
}

# However, the implied double negative of using unless with an else block can be confusing.
# This example may be the only place you ever see it.

# Just as Perl provides both (if) and (unless)
# to allow you to phrase your conditionals in the most readable way,
# Perl has both positive and negative conditional operators:
sub demo_ne {
    my $name = 'Alice';
    if ( $name ne 'Bob' ) {
        say "I don't know you.";
        shun_user();
    }
    else {
        say 'Hi, Bob!';
        greet_user();
    }
}

# ... though the double negative implied by the presence of the (else) block may be difficult to read.

# Use one or more (elsif) directives to check multiple and mutually exclusive conditions:
sub demo_elsif {
    my $name = 'Alice';
    if ( $name eq 'Robert' ) {
        say 'Hi, Bob!';
        greet_user();
    }
    elsif ( $name eq 'James' ) {
        say 'Hi, Jim!';
        greet_user();
    }
    elsif ( $name eq 'Armando' ) {
        say 'Hi, Mando!';
        greet_user();
    }
    else {
        say "You're not my uncle.";
        shun_user();
    }
}

# An unless chain may also use an (elsif) block, but good luck deciphering that.

# Perl supports neither (elseunless) nor (else if).
# Larry prefers (elsif) for aesthetic reasons,
# as well the prior art of the Ada programming language:
# {
#     if ($name eq 'Rick') {
#         say 'Hi, cousin!';
#     }
#
#     # warning; syntax error
#     else if ($name eq 'Kristen') {
#         say 'Hi, cousin-in-law!';
#     }
# }

# ================================
# The Ternary Conditional Operator
# ================================

# An interesting, though obscure, idiom uses the ternary conditional to select between alternative variables,
# not only values:
# {
#     push @{ rand() > 0.5 ? \@red_team : \@blue_team }, Player->new;
# }

# Besides allowing you to avoid potentially expensive computations,
# short circuiting can help you to avoid errors and warnings,
# as in the case where using an undefined value might raise a warning:
sub demo_short_circuiting {
    my $bbq;
    if ( defined $bbq and $bbq eq 'brisket' ) { ... }
}

# ================================
# Context for Conditional Directives
# ================================

# Perl has neither a single true value nor a single false value. Any number which evaluates to 0 is false.
# The empty string ('') and '0' evaluate to a false value, but the strings '0.0', '0e0', and so on do not.
# The idiom '0 but true' evaluates to 0 in numeric context—
# but true in boolean context due to its string contents.

# Both the empty list and undef evaluate to a false value.
# Empty arrays and hashes return the number 0 in scalar context,
# so they evaluate to a false value in boolean context.
# An array which contains a single element—even undef—
# evaluates to true in boolean context.
# A hash which contains any elements—even a key and a value of undef—
# evaluates to a true value in boolean context.

# ================================
# Looping Directives
# ================================

# This example uses the range operator to produce a list of integers from one to ten inclusive.
# The foreach directive loops over them,
# setting the topic variable $_ (The Default Scalar Variable) to each in turn.
# Perl executes the block for each integer and, as a result, prints the squares of the integers.
sub demo_for_looping {

    # Square the first ten positive integers.
    foreach ( 1 .. 10 ) {
        say "$_ * $_ = ", $_ * $_;
    }

    # Like if and unless, this loop has a postfix form:
    say "$_ * $_ = ", $_ * $_ for 1 .. 10;

    # A for loop may use a named variable instead of the topic:
    for my $i ( 1 .. 10 ) {
        say "$i * $i = ", $i * $i;
    }
}

# Many Perl programmers refer to iteration as foreach loops,
# but Perl treats the names foreach and for interchangeably.
# The parenthesized expression determines the type and behavior of the loop;
# the keyword does not.
# REF: https://stackoverflow.com/questions/2279471/whats-the-difference-between-for-and-foreach-in-perl/2279497#2279497

# When a for loop uses an iterator variable,
# the variable is scoped to the block within the loop.
# Perl will set this lexical to the value of each item in the iteration.
# Perl will not modify the topic variable ($_).
# If you have declared a lexical $i in an outer scope, its value will persist outside the loop:
sub demo_for_looping_scope_1 {
    my $i = 'cow';

    for my $i ( 1 .. 10 ) {
        say "$i * $i = ", $i * $i;
    }

    is $i, 'cow', 'Value preserved in outer scope';
}

# This localization occurs even if you do not redeclare the iteration variable as a lexical,
# but keep the habit of declaring iteration values as lexicals:
sub demo_for_looping_scope_2 {
    my $i = 'horse';

    for $i ( 1 .. 10 ) {
        say "$i * $i = ", $i * $i;
    }

    is $i, 'horse', 'Value preserved in outer scope';
}

# ================================
# Iteration and Aliasing
# ================================

# The for loop aliases the iterator variable to the values in the iteration
# such that any modifications to the value of the iterator modifies the value in place:
sub demo_for_looping_iterator_value_1 {
    my @nums = 1 .. 10;

    $_**= 2 for @nums;

    is $nums[0], 1, '1 * 1 is 1';
    is $nums[1], 4, '2 * 2 is 4';

    # ...

    is $nums[9], 100, '10 * 10 is 100';
}

# This aliasing also works with the block style for loop:
sub demo_for_looping_iterator_value_2 {
    my @nums = 1 .. 10;

    for my $num (@nums) {
        $num**= 2;
    }
}

# ... as well as iteration with the topic variable:
sub demo_for_looping_iterator_value_3 {
    my @nums = 1 .. 10;

    for (@nums) {
        $_**= 2;
    }
}

# You cannot use aliasing to modify constant values, however.
# Perl will produce an exception about modification of read-only values.
# {
#     $_++ and say for qw( Huex Dewex Louid );
# }

# You may occasionally see the use of for with a single scalar variable:
# {
#     for ($user_input) {
#         s/\A\s+//;      # trim leading whitespace
#         s/\s+\z//;      # trim trailing whitespace
#
#         $_ = quotemeta; # escape non-word characters
#     }
# }
# This idiom (Idioms) uses the iteration operator for its side effect of aliasing $_,
# though it's clearer to operate on the named variable itself.

# ================================
# Iteration and Scoping
# ================================

# The topic variable's iterator scoping has a subtle gotcha.
# Consider a function topic_mangler() which modifies $_ on purpose.
# If code iterating over a list called topic_mangler() without protecting $_,
# you'd have to spend some time debugging the effects:
# {
#     for (@values) {
#         topic_mangler();
#     }
#
#     sub topic_mangler {
#         s/foo/bar/;
#     }
# }

# The substitution in topic_mangler() will modify elements of @values in place.
# If you must use $_ rather than a named variable,
# use the topic aliasing behavior of for:
sub topic_mangler {

    # was $_ = shift;
    for (shift) {
        s/foo/bar/;
        s/baz/quux/;
        return $_;
    }
}

# Alternately, use a named iteration variable in the for loop.
# That's almost always the right advice.

# ================================
# The C-Style For Loop
# ================================

# All three subexpressions are optional.
sub demo_c_style_for_looping {
    for (
        # loop initialization subexpression
        say 'Initializing', my $i = 0 ;

        # conditional comparison subexpression
        say "Iteration: $i" and $i < 10 ;

        # iteration ending subexpression
        say 'Incrementing ' . $i++
      )
    {
        say "$i * $i = ", $i * $i;
    }
}

# You must explicitly assign to an iteration variable in the looping construct,
# as this loop performs neither aliasing nor assignment to the topic variable.

# While any variable declared in the loop construct is scoped to the lexical block of the loop,
# Perl will not limit the lexical scope of a variable declared outside of the loop construct:
sub demo_c_style_for_looping_scope {
    my $i = 'pig';

    for ( $i = 0 ; $i <= 10 ; $i += 2 ) {
        say "$i * $i = ", $i * $i;
    }

    isnt $i, 'pig', '$i overwritten with a number';
}

# Note the lack of a semicolon after the final subexpression
# as well as the use of the comma operator and low-precedence and;
# this syntax is surprisingly finicky.
# When possible, prefer the foreach-style loop to the for loop.

# ================================
# While and Until
# ================================

# Unlike the iteration foreach-style loop,
# the while loop's condition has no side effects.
# If @values has one or more elements,
# this code is also an infinite loop,
# because every iteration will evaluate @values in scalar context to a non-zero value
# and iteration will continue:
sub demo_infinite_while_looping {

    # my @values = qw( one two three );
    my @values = qw();

    while (@values) {
        say $values[0];
    }
}

# To prevent such an infinite while loop,
# use a destructive update of the @values array by modifying the array within each iteration:
sub demo_destructive_update {
    my @values = qw( 1 0 2 4 );

    while (@values) {
        my $value = shift @values;
        say $value;
    }
}

# NOTE: Modifying @values inside of the while condition check also works,
# but it has some subtleties related to the truthiness of each value.
# This loop will exit
# as soon as the assignment expression used as the conditional expression evaluates to a false value.
# If that's what you intend, add a comment to the code.
sub demo_subtleties {
    my @values = qw( 1 0 2 4 );

    while ( my $value = shift @values ) {
        say $value;
    }
}

# The canonical use of the while loop is to iterate over input from a filehandle:
# {
#     while (<$fh>) {
#         # remove newlines
#         chomp;
#         ...
#     }
# }

# Perl interprets this while loop as if you had written:
# {
#     while (defined($_ = <$fh>)) {
#         # remove newlines
#         chomp;
#         ...
#     }
# }
# NOTE: Without the implicit defined,
# any line read from the filehandle which evaluated to a false value in a scalar context—
# a blank line or a line which contained only the character 0—would end the loop.
# The readline (<>) operator returns an undefined value only when it has reached the end of the file.

# Use a do block to group several expressions into a single unit:
sub greet_people {
    do {
        say 'What is your name?';
        my $name = <>;
        chomp $name;
        say "Hello, $name!" if $name;
    } until (eof);
}

# A do block parses as a single expression which may contain several expressions.
# Unlike the while loop's block form,
# the do block with a postfix while or until will execute its body at least once.
# This construct is less common than the other loop forms, but very powerful.

# ================================
# Loops within Loops
# ================================

# Novices commonly exhaust filehandles accidentally while nesting foreach and while loops:
sub demo_buggy_filehandle {
    use autodie 'open';

    open my $fh, '<', '';
    my @prefixes = qw(John Paul Ringo);

    for my $prefix (@prefixes) {

        # DO NOT USE; buggy code
        while (<$fh>) {
            say $prefix, $_;
        }
    }
}

# !!! Opening the filehandle outside of the for loop
# leaves the file position unchanged between each iteration of the for loop.
# On its second iteration,
# the while loop will have nothing to read (the (readline) will return a false value).
# You can solve this problem in many ways;
# re-open the file inside the for loop (wasteful but simple),
# slurp the entire file into memory (works best with small files),
# or (seek) the filehandle back to the beginning of the file for each iteration:
sub demo_seek {
    open my $fh, '<', '';
    my @prefixes = qw(John Paul Ringo);

    for my $prefix (@prefixes) {
        while (<$fh>) {
            say $prefix, $_;
        }

        seek $fh, 0, 0;
    }
}

# ================================
# Loop Control
# ================================

# The (next) statement restarts the loop at its next iteration.
# Use it when you've done everything you need to in the current iteration.

# To loop over lines in a file and skip everything that starts with the comment character #:
sub demo_next {
    open my $fh, '<', '';

    while (<$fh>) {
        next if /\A#/;
        ...;
    }
}

# The (last) statement ends the loop immediately.
# To finish processing a file once you've seen the ending token, write:
sub demo_last {
    open my $fh, '<', '';

    while (<$fh>) {
        next if /\A#/;
        last if /\A__END__/;
        ...;
    }
}

# The (redo) statement restarts the current iteration without evaluating the conditional again.
# This can be useful in those few cases where you want to modify the line you've read in place,
# then start processing over from the beginning without clobbering it with another line.
# To implement a silly file parser that joins lines which end with a backslash:
sub demo_redo {
    open my $fh, '<', '';

    while ( my $line = <$fh> ) {
        chomp $line;

        # match backslash at the end of a line
        if ( $line =~ s{\\$}{} ) {  # BUG: There's a bug in syntax highlighting.
            $line .= <$fh>;
            redo;
        }

        ...;
    }
}

# Nested loops can be confusing, especially with loop control statements.
# If you cannot extract inner loops into named functions,
# use loop labels to clarify your intent:
sub demo_loop_label {
    open my $fh, '<', '';
    my @prefixes = qw(John Paul Ringo);

  LINE:
    while (<$fh>) {
        chomp;

      PREFIX:
        for my $prefix (@prefixes) {
            next LINE unless $prefix;
            say "$prefix: $_";

            # next PREFIX is implicit here
        }
    }
}

# ================================
# Continue
# ================================

# The continue construct behaves like the third subexpression of a for loop;
# Perl executes any continue block before subsequent iterations of a loop,
# whether due to normal loop repetition or premature re-iteration from next.
# You may use it with a while, until, when, or for loop.

# Examples of continue are rare,
# but it's useful any time you want to guarantee that something occurs with every iteration of the loop,
# regardless of how that iteration ends:
# {
#     while ($i < 10 ) {
#         next unless $i % 2;
#         say $i;
#     }
#     continue {
#         say 'Continuing...';
#         $i++;
#     }
# }

# Note that a continue block does not execute when control flow leaves a loop due to last or redo.

# ================================
# Switch Statements
# ================================

# Perl 5.10 introduced a new construct named given as a Perlish switch statement.
# It didn't quite work out; given is still experimental, if less buggy in newer releases.
# Avoid it unless you know exactly what you're doing.
# If you need a switch statement, use (for) to alias the topic variable ($_)
# and (when) to match it against simple expressions
# with smart match (Smart Matching) semantics.

# To write the Rock, Paper, Scissors game:
sub rock_paper_scissors {
    my @options  = ( \&rock, \&paper, \&scissors );
    my $confused = "I don't understand your move.";

    do {
        say "Rock, Paper, Scissors!  Pick one: ";
        chomp( my $user = <STDIN> );
        my $computer_match = $options[ rand @options ];
        $computer_match->( lc($user) );
    } until (eof);

    sub rock {
        print "I chose rock.  ";

        for (shift) {
            when (/paper/)    { say 'You win!' }
            when (/rock/)     { say 'We tie!' }
            when (/scissors/) { say 'I win!' }
            default           { say $confused }
        }
    }

    sub paper {
        print "I chose paper.  ";

        for (shift) {
            when (/paper/)    { say 'We tie!' }
            when (/rock/)     { say 'I win!' }
            when (/scissors/) { say 'You win!' }
            default           { say $confused }
        }
    }

    sub scissors {
        print "I chose scissors.  ";

        for (shift) {
            when (/paper/)    { say 'I win!' }
            when (/rock/)     { say 'You win!' }
            when (/scissors/) { say 'We tie!' }
            default           { say $confused }
        }
    }
}

# ================================
# Tailcalls
# ================================

# A tailcall occurs when the last expression within a function is a call to another function.
# The outer function's return value becomes the inner function's return value:
sub log_and_greet_person {
    my $name = shift;
    log("Greeting $name");

    return greet_person($name);
}

# Returning from greet_person() directly to the caller of log_and_greet_person()
# is more efficient than
# returning to log_and_greet_person() and then from log_and_greet_person().
# Returning directly from greet_person() to the caller of log_and_greet_person() is a tailcall optimization.

# Heavily recursive code (Recursion)—especially mutually recursive code—can consume a lot of memory.
# Tailcalls reduce the memory needed for internal bookkeeping of control flow
# and can make expensive algorithms cheaper.
# Unfortunately, Perl does not automatically perform this optimization,
# so you have to do it yourself when it's necessary.

# The builtin (goto) operator has a form
# which calls a function as if the current function were never called,
# essentially erasing the bookkeeping for the new function call.
# The ugly syntax confuses people who've heard "Never use (goto)", but it works:
sub log_and_greet_person_using_goto {
    my ($name) = @_;
    log("Greeting $name");

    goto &greet_person;
}

# NOTE: This example has two important characteristics.
# First, (goto &function_name) or (goto &$function_reference) requires the use of the function sigil (&)
# so that the parser knows to perform a tailcall instead of jumping to a label.
# Second, this form of function call passes the contents of @_ implicitly to the called function.
# You may modify @_ to change the passed arguments if you desire.

# This technique is most useful when you want to hijack control flow
# to get out of the way of other functions inspecting caller
# (such as when you're implementing special logging or some sort of debugging feature),
# or when using an algorithm which requires a lot of recursion.
# Remember it if you need it, but feel free not to use it.

done_testing();
