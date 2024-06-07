#!/usr/bin/env perl
# REF: http://modernperlbooks.com/books/modern_perl_2016/09-managing-real-programs.html#TW9kdWxlcw

use 5.034;
use warnings;
use autodie;
use feature 'say';

use Test::More;

# You've seen functions, classes, and data structure used to organize code.
# Perl's next mechanism for organization and extension is the module.
# A module is a package contained in its own file and loadable with (use) or (require).
# A module must be valid Perl code.
# NOTE: It must end with an expression which evaluates to a true value
# so that the Perl parser knows it has loaded and compiled the module successfully.

# There are no other requirements—only strong conventions.

# When you load a module,
# Perl splits the package name on double-colons (::)
# and turns the components of the package name into a file path.
# This means that (use StrangeMonkey;) causes Perl to search for a file named StrangeMonkey.pm
# in every directory in (@INC) in order,
# until it finds one or exhausts the list.

# Similarly, (use StrangeMonkey::Persistence;) causes Perl to search for a file named Persistence.pm
# in every directory named StrangeMonkey/ present in every directory in @INC, and so on.
# (use StrangeMonkey::UI::Mobile;) causes Perl to search for a relative file path of StrangeMonkey/UI/Mobile.pm
# in every directory in @INC.

# The resulting file may or may not contain a package declaration matching its filename—
# there is no such technical requirement—
# but you'll cause confusion without that match.

# perldoc -l Module::Name will print the full path to the relevant .pm file,
# if that file contains documentation in POD form.
# perldoc -lm Module::Name will print the full path to the .pm file.
# perldoc -m Module::Name will display the contents of the .pm file.

# ================================
# Organizing Code with Modules
# ================================

# Perl does not require you to use modules, packages, or namespaces.
# You may put all of your code in a single .pl file,
# or in multiple .pl files you require as necessary.
# You have the flexibility to manage your code in the most appropriate way,
# given your development style,
# the formality and risk and reward of the project,
# your experience,
# and your comfort with deploying code.

# Even so, a project with more than a couple of hundred lines of code benefits from module organization:
#
#     Modules help to enforce a logical separation between distinct entities in the system.
#
#     Modules provide an API boundary, whether procedural or OO.
#
#     Modules suggest a natural organization of source code.
#
#     The Perl ecosystem has many tools devoted to creating, maintaining, organizing, and deploying modules and distributions.
#
#     Modules provide a mechanism of code reuse.
#
# Even if you do not use an object-oriented approach,
# modeling every distinct entity or responsibility in your system with its own module
# keeps related code together and separate code separate.

# ================================
# Using and Importing
# ================================

# When you load a module with (use), Perl loads it from disk,
# then calls its import() method with any arguments you provided.
# That import() method takes a list of names
# and exports functions and other symbols into the calling namespace.
# This is merely convention;
# a module may decline to provide an import(),
# or its import() may perform other behaviors.
# Pragmas (Pragmas) such as strict use arguments to change the behavior of the calling lexical scope
# instead of exporting symbols:
{
    use strict;

    # ... calls strict->import()

    use File::Spec::Functions 'tmpdir';

    # ... calls File::Spec::Functions->import( 'tmpdir' )

    use feature qw( say unicode_strings );

    # ... calls feature->import( qw( say unicode_strings ) )
}

# The no builtin calls a module's unimport() method, if it exists, passing any arguments.
# This is most common with pragmas which introduce or modify behavior through import():
{
    use strict;

    # no symbolic references or barewords
    # variable declaration required

    {
        no strict 'refs';

        # symbolic references allowed
        # strict 'subs' and 'vars' still in effect
    }
}

# Both use and no take effect during compilation, such that:
# {
#     use Module::Name qw( list of arguments );
# }
# ... is the same as:
# {
#     BEGIN {
#         require 'Module/Name.pm';
#         Module::Name->import( qw( list of arguments ) );
#     }
# }

# Similarly:
# {
#     no Module::Name qw( list of arguments );
# }
# ... is the same as:
# {
#     BEGIN {
#         require 'Module/Name.pm';
#         Module::Name->unimport(qw( list of arguments ));
#     }
# }
# ... including the require of the module.

# If import() or unimport() does not exist in the module, Perl will produce no error.
# These methods are truly optional.

# You may call import() and unimport() directly,
# though outside of a BEGIN block it makes little sense to do so;
# after compilation has completed,
# the effects of import() or unimport() may have little effect
# (given that these methods tend to modify the compilation process by importing symbols or toggling features).

# Portable programs are careful about case even if they don't have to be.

# Both use and require are case-sensitive.
# While Perl knows the difference between strict and Strict,
# your combination of operating system and file system may not.
# If you were to write (use Strict;), Perl would not find strict.pm on a case-sensitive filesystem.
# With a case-insensitive filesystem, Perl would happily load Strict.pm,
# but nothing would happen when it tried to call Strict->import().
# (strict.pm declares a package named strict.
# Strict does not exist and thus has no import() method, which is not an error.)

# ================================
# Exporting
# ================================

# A module can make package global symbols available to other packages
# through a process known as exporting—often by calling import() implicitly or directly.

# The core module Exporter is the standard way to export symbols from a module.
# Exporter relies on the presence of package global variables such as (@EXPORT_OK) and (@EXPORT),
# which list symbols to export when requested.

# Consider a StrangeMonkey::Utilities module which provides several standalone functions:
{

    package StrangeMonkey::Utilities;

    use Exporter 'import';

# Any other code now can use this module and, optionally, import any or all of the three exported functions.
    our @EXPORT_OK = qw( round translate screech );

    # You may also export variables:
    push @EXPORT_OK, qw( $spider $saki $squirrel );

    # Export symbols by default by listing them in @EXPORT instead of @EXPORT_OK
    # so that any (use StrangeMonkey::Utilities;) will import both functions.
    our @EXPORT = qw( monkey_dance monkey_sleep );

}

# Be aware that specifying symbols to import will not import default symbols;
# you only get what you request.
# To load a module without importing any symbols, use an explicit empty list:
# {
#     # make the module available, but import() nothing
#     use StrangeMonkey::Utilities ();
# }

# Regardless of any import lists,
# you can always call functions in another package with their fully-qualified names:
# {
#     StrangeMonkey::Utilities::screech();
# }

# The CPAN module Sub::Exporter provides a nicer interface to export functions without using package globals.
# It also offers more powerful options.
# However, Exporter can export variables,
# while Sub::Exporter only exports functions.
# The CPAN module Moose::Exporter offers a powerful mechanism to work with Moose-based systems,
# but the learning curve is not shallow.

done_testing();
