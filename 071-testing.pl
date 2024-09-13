#!/usr/bin/env perl
# REF: http://modernperlbooks.com/books/modern_perl_2016/09-managing-real-programs.html#VGVzdGluZw

use 5.034;
use warnings;
use autodie;
use feature 'say';

use Test::More;

# Testing is the process of verifying that your software behaves as intended.
# Effective testing automates that process.
# Rather than relying on humans to perform repeated manual checks perfectly,
# let the computer do it.

# Perl's tools help you write the right tests.

# ===============================
# Test::More
# ===============================

# The fundamental unit of testing is a test assertion.
# Every test assertion is a simple question with a yes or no answer:
# does this code behave as I intended?
# Any condition you can test in your program can (eventually) become one or more assertions.
# A complex program may have thousands of individual conditions.
# That's fine. That's testable.
# Isolating specific behaviors into individual assertions
# helps you debug errors of coding and errors of understanding,
# and it makes your code and tests easier to maintain.

# Perl testing begins with the core module Test::More and its ok() function.
# ok() takes two parameters,
# a boolean value
# and a string which describes the test's purpose:
{
    ok 1,   'the number one should be true';
    ok 0,   '... and zero should not';
    ok '',  'the empty string should be false';
    ok '!', '... and a non-empty string should not';
}

# The function done_testing() tells Test::More that
# the program has executed all of the assertions you expected to run.
# If the program exited unexpectedly (from an uncaught exception, a call to exit, or whatever),
# the test framework will notify you that something went wrong.
# Without a mechanism like done_testing(), how would you know?
# While this example code is too simple to fail,
# code that's too simple to fail fails far more often than you want.

# Test::More allows an optional test plan to count the number of individual assertions you plan to run:
{
    use Test::More tests => 4;

    ok 1,   'the number one should be true';
    ok 0,   '... and zero should not';
    ok '',  'the empty string should be false';
    ok '!', '... and a non-empty string should not';
}

# The tests argument to Test::More sets the test plan for the program.
# This is a safety net. If fewer than four tests ran, something went wrong.
# If more than four tests ran, something went wrong.
# done_testing() is easier,
# but sometimes an exact count can be useful
# (when you want to control the number of assertions in a loop, for example).

# ===============================
# Running Tests
# ===============================

# This example test file is a complete Perl program which produces the output:
#
#     ok 1 - the number one should be true
#     not ok 2 - ... and zero should not
#     #   Failed test '... and zero should not'
#     #   at truth_values.t line 4.
#     not ok 3 - the empty string should be false
#     #   Failed test 'the empty string should be false'
#     #   at truth_values.t line 5.
#     ok 4 - ... and a non-empty string should not
#     1..4
#     # Looks like you failed 2 tests of 4.
#
# This output uses a test output format called TAP,
# the Test Anything Protocol http://testanything.org/.
# Failed TAP tests produce diagnostic messages for debugging purposes.

# This is easy enough to read, but it's only four assertions.
# A real program may have thousands of assertions.
# In most cases, you want to know either that everything passed or the specifics of any failures.
# The core module The program prove—built on the core module TAP::Harness—
# runs tests, interprets TAP, and displays only the most pertinent information:
#
#     $ prove truth_values.t
#     truth_values.t .. 1/?
#     #   Failed test '... and zero should not'
#     #   at truth_values.t line 4.
#
#     #   Failed test 'the empty string should be false'
#     #   at truth_values.t line 5.
#     # Looks like you failed 2 tests of 4.
#     truth_values.t .. Dubious, test returned 2 (wstat 512, 0x200)
#     Failed 2/4 subtests
#
#     Test Summary Report
#     -------------------
#     truth_values.t (Wstat: 512 Tests: 4 Failed: 2)
#       Failed tests:  2-3
#
# That's a lot of output to display what is already obvious:
# the second and third tests fail because zero and the empty string evaluate to false.
# Fortunately, it's easy to fix those failing tests (Boolean Coercion):
{
    ok   ! 0, '... and zero should not';
    ok  ! '', 'the empty string should be false';
}
# With those two changes, prove now displays:
#
#     $ prove truth_values.t
#     truth_values.t .. ok
#     All tests successful.
#
# See perldoc prove for other test options,
# such as running tests in parallel (-j),
# automatically adding the relative directory lib/ to Perl's include path (-l),
# recursively running all test files found under t/ (-r t),
# and running slow tests first (--state=slow,save).

# The Bash shell alias proveall combines many of these options:
#
#    alias proveall='prove -j9 --state=slow,save -lr t'

# =================================
# Better Comparisons
# =================================

# Even though the heart of all automated testing is the boolean condition "is this true or false?",
# reducing everything to that boolean condition is tedious and produces awkward diagnostics.
# Test::More provides several other convenient assertion functions.

# The is() function compares two values using Perl's eq operator.
# If the values are equal, the test passes:
{
    is         4, 2 + 2, 'addition should work';
    is 'pancake',   100, 'pancakes are numeric';
}
# The first test passes and the second fails with a diagnostic message:
#
#     t/is_tests.t .. 1/2
#     #   Failed test 'pancakes are numeric'
#     #   at t/is_tests.t line 8.
#     #          got: 'pancake'
#     #     expected: '100'
#     # Looks like you failed 1 test of 2.
#
# Where ok() only provides the line number of the failing test,
# is() displays the expected and received values.

# NOTE: is() applies implicit scalar context to its values (Prototypes).
# This means, for example, that you can check the number of elements in an array
# without explicitly evaluating the array in scalar context,
# and it's why you can omit the parentheses:
{
    my @cousins = qw( Rick Kristen Alex Kaycee Eric Corey );
    is @cousins, 6, 'I should have only six cousins';
}
# ... though some people prefer to write scalar @cousins for the sake of clarity.

# Test::More's corresponding isnt() function compares two values using the ne operator
# and passes if they are not equal.
# It also provides scalar context to its operands.

# Both is() and isnt() apply string comparisons with the eq and ne operators.
# This almost always does the right thing,
# but for strict numeric comparisons
# or complex values
# such as objects with overloading (Overloading) or dual vars (Dualvars),
# use the cmp_ok() function.
# This function takes the first value to compare, a comparison operator, and the second value to compare:
# {
#     cmp_ok     100, '<=', $cur_balance, 'I should have at least $100';
#     cmp_ok $monkey, '==', $ape, 'Simian numifications should agree';
# }
# If you're concerned about string equality with numeric comparisons—a reasonable concern—
# then use cmp_ok() instead of is().

# Classes and objects provide their own interesting ways to interact with tests.
# Test that a class or object extends another class (Inheritance) with isa_ok():
# {
#     my $chimpzilla = RobotMonkey->new;

#     isa_ok $chimpzilla, 'Robot';
#     isa_ok $chimpzilla, 'Monkey';
# }
# isa_ok() provides its own diagnostic message on failure.

# can_ok() verifies that a class or object can perform the requested method (or methods):
# {
#     can_ok $chimpzilla, 'eat_banana';
#     can_ok $chimpzilla, 'transform', 'destroy_tokyo';
# }

# The is_deeply() function compares two references to ensure that their contents are equal:
# {
#     use Clone;
#
#     my $numbers   = [ 4, 8, 15, 16, 23, 42 ];
#     my $clonenums = Clone::clone( $numbers );
#
#     is_deeply $numbers, $clonenums, 'clone() should produce identical items';
# }
# If the comparison fails, Test::More will do its best to provide a reasonable diagnostic
# indicating the position of the first inequality between the structures.
# See the CPAN modules Test::Differences and Test::Deep for more configurable tests.

# Test::More has several other more specialized test functions.

# =================================
# Organizing Tests
# =================================

# CPAN distributions should include a t/ directory containing one or more test files named with the .t suffix.
# When you build a distribution,
# the testing step runs all of the t/*.t files,
# summarizes their output,
# and succeeds or fails based on the results of the test suite as a whole.
# Two organization strategies are popular:
#
#     Each .t file should correspond to a .pm file
#     Each .t file should correspond to a logical feature
#
# A hybrid approach is the most flexible;
# one test can verify that all of your modules compile,
# while other tests demonstrate that each module behaves as intended.
# As your project grows, the second approach is easier to manage.
# Keep your test files small and focused and they'll be easier to maintain.

# Separate test files can also speed up development.
# If you're adding the ability to breathe fire to your RobotMonkey,
# you may want only to run the t/robot_monkey/breathe_fire.t test file.
# When you have the feature working to your satisfaction,
# run the entire test suite to verify that local changes have no unintended global effects.

# =================================
# Other Testing Modules
# =================================

# Test::More relies on a testing backend known as Test::Builder
# which manages the test plan and coordinates the test output into TAP.
# This design allows multiple test modules to share the same Test::Builder backend.
# Consequently, the CPAN has hundreds of test modules available—
# and they can all work together in the same program.
#
#     Test::Fatal helps test that your code throws (and does not throw) exceptions appropriately.
#         You may also encounter Test::Exception.
#
#     Test::MockObject and Test::MockModule allow you to test difficult interfaces by mocking
#         (emulating behavior to produce controlled results).
#
#     Test::WWW::Mechanize helps test web applications,
#         while Plack::Test, Plack::Test::Agent, and the subclass Test::WWW::Mechanize::PSGI
#         can do so without using an external live web server.
#
#     Test::Database provides functions to test the use and abuse of databases.
#         DBICx::TestDatabase helps test schemas built with DBIx::Class.
#
#     Test::Class offers an alternate mechanism for organizing test suites.
#         It allows you to create classes in which specific methods group tests.
#         You can inherit from test classes just as your code classes inherit from each other.
#         This is an excellent way to reduce duplication in test suites.
#         See Curtis Poe's excellent Test::Class series http://www.modernperlbooks.com/mt/2009/03/organizing-test-suites-with-testclass.html.
#         The newer Test::Routine distribution offers similar possibilities through the use of Moose (Moose).
#
#     Test::Differences tests strings and data structures for equality
#         and displays any differences in its diagnostics.
#         Test::LongString adds similar assertions.
#
#     Test::Deep tests the equivalence of nested data structures (Nested Data Structures).
#
#     Devel::Cover analyzes the execution of your test suite
#         to report on the amount of your code your tests actually exercises.
#         In general, the more coverage the better—although 100% coverage is not always possible,
#         95% is far better than 80%.
#
#     Test::Most gathers several useful test modules into one parent module. It saves time and effort.
#
# See the Perl QA project http://qa.perl.org/ for more information about testing in Perl.

done_testing();
