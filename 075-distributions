#!/usr/bin/env perl
# REF: http://modernperlbooks.com/books/modern_perl_2016/09-managing-real-programs.html#RGlzdHJpYnV0aW9ucw

use 5.034;
use warnings;
use autodie;
use feature 'say';

use Test::More;

# A distribution is a collection of metadata and modules (Modules)
# into a single redistributable, testable, and installable unit.
# The easiest way to configure, build, package, test, and install Perl code is to follow the CPAN's conventions.
# These conventions govern how to package a distribution,
# how to resolve its dependencies,
# where to install the code and documentation,
# how to verify that it works,
# how to display documentation,
# and how to manage a repository.
# These guidelines have arisen from the rough consensus of thousands of contributors
# working on tens of thousands of projects.

# A distribution built to CPAN standards can be tested
# on several versions of Perl
# on several different hardware platforms
# within a few hours of its uploading,
# with errors reported automatically to authors—all without human intervention.
# When people talk about CPAN being Perl's secret weapon, this is what they mean.

# You may choose never to release any of your code as public CPAN distributions,
# but you can use CPAN tools and conventions to manage even private code.
# The Perl community has built amazing infrastructure. Take advantage of it.

# ================================
# Attributes of a Distribution
# ================================

# Besides modules, a distribution includes several files and directories:
#
#     Build.PL or Makefile.PL, a driver program used to configure, build, test, bundle, and install the distribution.
#
#     MANIFEST, a list of all files contained in the distribution. This helps tools verify that a bundle is complete.
#
#     META.yml and/or META.json, a file containing metadata about the distribution and its dependencies.
#
#     README, a description of the distribution, its intent, and its copyright and licensing information.
#
#     lib/, the directory containing Perl modules.
#
#     t/, a directory containing test files.
#
#     Changes, a human-readable log of every significant change to the distribution.
#
# A well-formed distribution must contain a unique name
# and single version number (often taken from its primary module).
# Any distribution you download from the public CPAN should conform to these standards.
# The public CPANTS service http://cpants.perl.org/ evaluates each uploaded distribution
# against packaging guidelines and conventions and recommends improvements.
# Following the CPANTS guidelines doesn't mean the code works,
# but it does mean that CPAN packaging and installation tools should understand the distribution.

# ================================
# CPAN Tools for Managing Distributions
# ================================

# The Perl core includes several tools to manage distributions:
#
#     CPAN.pm is the official CPAN client.
#         While by default this client installs distributions from the public CPAN,
#         you can also use your own repository instead of or in addition to the public repository.
#
#     ExtUtils::MakeMaker is a complex but well-used system of modules
#         used to package, build, test, and install Perl distributions.
#         It works with Makefile.PL files.
#
#     Test::More (Testing) is the basic and most widely used testing module
#         used to write automated tests for Perl software.
#
#     TAP::Harness and prove (Running Tests) run tests and interpret and report their results.

# In addition, several non-core CPAN modules make your life easier as a developer:

#     App::cpanminus is a configuration-free CPAN client.
#         It handles the most common cases, uses little memory, and works quickly.
#
#     App::perlbrew helps you to manage multiple installations of Perl.
#         Install new versions of Perl for testing or production,
#         or to isolate applications and their dependencies.
#
#     CPAN::Mini and the cpanmini command allow you to create your own (private) mirror of the public CPAN.
#         You can inject your own distributions into this repository
#         and manage which versions of the public modules are available in your organization.
#
#     Dist::Zilla automates away common distribution tasks.
#         While it uses either Module::Build or ExtUtils::MakeMaker,
#         it can replace your use of them directly.
#         See http://dzil.org/ for an interactive tutorial.
#
#     Test::Reporter allows you to report the results of running the automated test suites of distributions you install,
#         giving their authors more data on any failures.
#
#     Carton and Pinto are two newer projects which help manage and install code's dependencies.
#         Neither is in widespread use yet, but they're both under active development.
#
#     Module::Build is an alternative to ExtUtils::MakeMaker, written in pure Perl.
#         While it has advantages, it's not as widely used or maintained.

# ================================
# Designing Distributions
# ================================

# The process of designing a distribution could fill a book
# (such as Sam Tregar's Writing Perl Modules for CPAN),
# but a few design principles will help you.
# Start with a utility such as Module::Starter or Dist::Zilla.
# The initial cost of learning the configuration and rules may seem like a steep investment,
# but the benefit of having everything set up the right way
# (and in the case of Dist::Zilla, never going out of date)
# relieves you of tedious busywork.

# A distribution should follow several non-code guidelines:
#
#     Each distribution performs a single, well-defined purpose.
#         That purpose may even include gathering several related distributions into a single installable bundle.
#         Decompose your software into individual distributions
#         to manage their dependencies appropriately
#         and to respect their encapsulation.
#
#     Each distribution contains a single version number.
#         Version numbers must always increase.
#         The semantic version policy http://semver.org/ is sane and compatible with Perl's approach.
#
#     Each distribution provides a well-defined API.
#         A comprehensive automated test suite can verify that you maintain this API across versions.
#         If you use a local CPAN mirror to install your own distributions,
#         you can re-use the CPAN infrastructure for testing distributions and their dependencies.
#         You get easy access to integration testing across reusable components.
#
#     Distribution tests are useful and repeatable.
#         The CPAN infrastructure supports automated test reporting. Use it!
#
#     Interfaces are simple and effective.
#         Avoid the use of global symbols and default exports;
#         allow people to use only what they need.
#         Do not pollute their namespaces.

done_testing();
