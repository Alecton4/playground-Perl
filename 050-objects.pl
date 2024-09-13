#!/usr/bin/env perl
# REF: http://modernperlbooks.com/books/modern_perl_2016/07-object-oriented-perl.html#T2JqZWN0cw
# REF: [perlootut - Object-Oriented Programming in Perl Tutorial - Perldoc Browser](https://perldoc.perl.org/perlootut)
# REF: [perlobj - Perl object reference - Perldoc Browser](https://perldoc.perl.org/perlobj)

use 5.034;
use warnings;
use autodie;
use feature 'say';

use Test::More;

# Every large program has several levels of design.
# At the bottom, you have specific details about the problem you're solving.
# At the top levels, you have to organize the code so it makes sense.
# Our only hope to manage this complexity is to exploit abstraction (treating similar things similarly)
# and encapsulation (grouping related details together).

# Functions alone are insufficient for large problems.
# Several techniques group functions into units of related behaviors;
# you've already seen higher-order functions.
# Another popular technique is object orientation (OO),
# or object oriented programming (OOP),
# where programs work with objects—discrete, unique entities with their own identities.

# ================================
# Moose: See 051-moose
# ================================

# ================================
# Blessed References
# ================================

# Perl's core object system is deliberately minimal.
# It has only three rules:
#
#     A class is a package.
#     A method is a function.
#     A (blessed) reference is an object.
#
# You can build anything else out of those three rules.
# This minimalism can be impractical for larger projects—
# in particular, the possibilities for greater abstraction through metaprogramming (Code Generation)
# are awkward and limited.
# Moose (Moose) is a better choice for modern programs larger than a couple of hundred lines,
# although plenty of legacy code uses Perl's default OO.

# You've seen the first two rules already.
# The bless builtin associates the name of a class with a reference.
# That reference is now a valid invocant.
# Perl will perform method dispatch on it.

# A constructor is a method which creates and blesses a reference.
# By convention, constructors are named new().
# Constructors are also almost always class methods.

# (bless) takes two operands,
# a reference and a class name,
# and evaluates to the reference.
# The reference may be any valid reference, empty or not.
# The class does not have to exist yet.
# You may even use (bless) outside of a constructor or a class,
# but you violate encapsulation to expose the details of object construction outside of a constructor.
# A constructor can be as simple as:
sub new {
    my $class = shift;
    bless {}, $class;    # NOTE: implicit return
        # my $self = bless {}, $class;    # ??? How about this one?
}

# By design, this constructor receives the class name as the method's invocant.
# You may also hard-code the name of a class at the expense of flexibility.
# A parametric constructor—one which relies on the invocant to determine the class name—
# allows reuse through inheritance, delegation, or exporting.

# The type of reference used is relevant only to how the object stores its own instance data.
# It has no other effect on the resulting object.
# Hash references are most common,
# but you can bless any type of reference:
# {
#     my $array_obj  = bless [],          $class;
#     my $scalar_obj = bless \$scalar,    $class;
#     my $func_obj   = bless \&some_func, $class;
# }

# Moose classes define object attributes declaratively,
# but Perl's default OO is lax.
# A class representing basketball players
# which stores jersey number and position might use a constructor like:
{

    package Player {

        sub new {
            my ( $class, %attrs ) = @_;
            bless \%attrs, $class;
        }
    }
}

# ... and create players with:
{
    my $joel   = Player->new( number => 10, position => 'center' );
    my $damian = Player->new( number => 0,  position => 'guard' );
}

# The class's methods can access object attributes as hash elements directly:
sub Player::format {
    my $self = shift;
    return '#' . $self->{number} . ' plays ' . $self->{position};
}

# ... but so can any other code,
# so any change to the object's internal representation may break other code.
# Accessor methods are safer:
sub Player::number   { return shift->{number} }
sub Player::position { return shift->{position} }

# ... and now you're starting to write yourself what Moose gives you for free.
# Better yet, Moose encourages people to use accessors instead of direct attribute access
# by generating the accessors itself.
# You won't see them in your code. Goodbye, temptation.

# ================================
# Blessed References - Method Lookup and Inheritance
# ================================

# Given a blessed reference, a method call of the form:
{
    my $joel = Player->new( number => 10, position => 'center' );

    my $number = $joel->number;
}

# ... looks up the name of the class associated with the blessed reference $joel—
# in this case, Player.
# Next, Perl looks for a function named number() in Player.
# (Remember that Perl makes no distinction between functions in a namespace and methods.)
# If no such function exists and if Player extends a parent class,
# Perl looks in the parent class (and so on and so on) until it finds a number().
# If Perl finds number(), it calls that method with $joel as an invocant.
# You've seen this before with Moose; it works the same way here.

# The namespace::autoclean CPAN module
# can help avoid unintentional collisions between imported functions and methods.

# Moose provides extends to track inheritance relationships,
# but Perl uses a package global variable named @ISA.
# The method dispatcher looks in each class's @ISA to find the names of its parent classes.
# If InjuredPlayer extends Player, you might write:
package InjuredPlayer_1 {
    @InjuredPlayer::ISA = 'Player';
}

# The parent pragma (Pragmas) is cleaner:
package InjuredPlayer_2 {

    # use parent 'Player';
    use parent -norequire, 'Player';
}

# Moose has its own metamodel which stores extended inheritance information.
# This allows Moose to provide additional metaprogramming opportunities.

# You may inherit from multiple parent classes:
# package InjuredPlayer {
#     use parent qw( Player Hospital::Patient );
# }

# ... though the caveats about multiple inheritance and method dispatch complexity apply.
# Consider instead roles (Roles) or Moose method modifiers.

# ================================
# Blessed References - AUTOLOAD
# ================================

# If there is no applicable method in the invocant's class or any of its superclasses,
# Perl will next look for an AUTOLOAD() function (AUTOLOAD)
# in every applicable class
# according to the selected method resolution order.
# Perl will invoke any AUTOLOAD() it finds.

# In the case of multiple inheritance,
# AUTOLOAD() can be very difficult to understand.

# ================================
# Blessed References - Method Overriding and SUPER
# ================================

# As with Moose, you may override methods in basic Perl OO.
# Unlike Moose, Perl provides no mechanism for indicating your intent to override a parent's method.
# Worse yet, any function you predeclare, declare, or import into the child class
# may silently override a method in the parent class.
# Even if you forget to use Moose's override system, at least it exists.
# Basic Perl OO offers no such protection.

# To override a parent method in a child class,
# declare a method of the same name.
# Within an overridden method,
# call the parent method with the SUPER:: dispatch hint:
sub overridden {
    my $self = shift;
    warn 'Called overridden() in child!';
    return $self->SUPER::overridden(@_);
}

# The (SUPER::) prefix to the method name
# tells the method dispatcher to dispatch to an overridden method of the appropriate name.
# You can provide your own arguments to the overridden method,
# but most code reuses @_.
# Be careful to shift off the invocant if you do.

# SUPER:: has a confusing misfeature:
# it dispatches to the parent of the package
# into which the overridden method was compiled.
# If you've imported this method from another package,
# Perl will happily dispatch to the wrong parent.
# The desire for backwards compatibility has kept this misfeature in place.
# The SUPER module from the CPAN offers a workaround.
# Moose's super() does not suffer the same problem.

# ================================
# Blessed References - Strategies for Coping with Blessed References
# ================================

# Blessed references may seem simultaneously minimal and confusing.
# Moose is much easier to use, so use it whenever possible.
# If you do find yourself maintaining code which uses blessed references,
# or if you can't convince your team to use Moose in full yet,
# you can work around some of the problems of blessed references with a few rules of thumb:
#
#     Do not mix functions and methods in the same class.
#
#     Use a single .pm file for each class,
#         unless the class is a small, self-contained helper used from a single place.
#
#     Follow Perl standards,
#         such as naming constructors new() and using $self as the invocant name.
#
#     Use accessor methods pervasively,
#         even within methods in your class.
#         A module such as Class::Accessor helps to avoid repetitive boilerplate.
#
#     Avoid AUTOLOAD() where possible.
#         If you must use it, use function forward declarations (Declaring Functions) to avoid ambiguity.
#
#     Expect that someone, somewhere will eventually need to subclass
#         (or delegate to or reimplement the interface of) your classes.
#         Make it easier for them by not assuming details of the internals of your code,
#         by using the two-argument form of bless,
#         and by breaking your classes into the smallest responsible units of code.
#
#     Use helper modules such as Role::Tiny to allow better use and reuse.

# ================================
# Reflection
# ================================

# Reflection (or introspection) is the process of asking a program about itself as it runs.
# By treating code as data you can manage code in the same way that you manage data.
# That sounds like a truism,
# but it's an important insight into modern programming.
# It's also a principle behind code generation (Code Generation).

# Moose's Class::MOP (Class::MOP) simplifies many reflection tasks for object systems.
# Several other Perl idioms help you inspect and manipulate running programs.

# ================================
# Reflection - Checking that a Module Has Loaded
# ================================

# If you know the name of a module,
# you can check that Perl believes it has loaded that module by looking in the %INC hash.
# When Perl loads code with use or require,
# it stores an entry in %INC where the key is the file path of the module to load
# and the value is the full path on disk to that module.
# In other words, loading Modern::Perl effectively does:
# {
#     $INC{'Modern/Perl.pm'} = '.../lib/site_perl/5.22.1/Modern/Perl.pm';
# }

# The details of the path will vary depending on your installation.
# To test that Perl has successfully loaded a module,
# convert the name of the module into the canonical file form
# and test for that key's existence within %INC:
sub module_loaded {
    ( my $modname = shift ) =~ s!::!/!g;
    return exists $INC{ $modname . '.pm' };
}

# As with @INC, any code anywhere may manipulate %INC.
# Some modules (such as Test::MockObject or Test::MockModule) manipulate %INC for good reasons.
# Depending on your paranoia level,
# you may check the path and the expected contents of the package yourself.

# The Class::Load CPAN module's is_class_loaded() function
# does all of this for you without making you manipulate %INC.

# ================================
# Reflection - Checking that a Package Exists
# ================================

# To check that a package exists somewhere in your program—
# if some code somewhere has executed a package directive with a given name—
# check that the package inherits from UNIVERSAL.
# Anything which extends UNIVERSAL must somehow provide the can() method
# (whether by inheriting it from UNIVERSAL or overriding it).
# If no such package exists,
# Perl will throw an exception about an invalid invocant,
# so wrap this call in an eval block:
# {
#     say "$pkg exists" if eval { $pkg->can( 'can' ) };
# }

# An alternate approach is to grovel through Perl's symbol tables.
# You're on your own here.

# ================================
# Reflection - Checking that a Class Exists
# ================================

# Because Perl makes no strong distinction between packages and classes,
# the best you can do without Moose is to check that a package of the expected class name exists.
# You can check that the package can() provide new(),
# but there is no guarantee that any new() found is either a method or a constructor.

# ================================
# Reflection - Checking a Module Version Number
# ================================

# Modules do not have to provide version numbers,
# but every package inherits the VERSION() method
# from the universal parent class UNIVERSAL (The UNIVERSAL Package):
# {
#     my $version = $module->VERSION;
# }

# VERSION() returns the given module's version number, if defined.
# Otherwise it returns undef.
# If the module does not exist, the method will likewise return undef.

# ================================
# Reflection - Checking that a Function Exists
# ================================

# To check whether a function exists in a package,
# call can() as a class method on the package name:
# {
#     say "$func() exists" if $pkg->can( $func );
# }

# Perl will throw an exception unless $pkg is a valid invocant;
# wrap the method call in an eval block if you have any doubts about its validity.
# Beware that a function implemented in terms of AUTOLOAD() (AUTOLOAD) may report the wrong answer
# if the function's package has not predeclared the function or overridden can() correctly.
# This is a bug in the other package.

# Use this technique to determine if a module's import() has imported a function into the current namespace:
# {
#     say "$func() imported!" if __PACKAGE__->can( $func );
# }

# As with checking for the existence of a package,
# you can root around in symbol tables yourself,
# if you have the patience for it.

# ================================
# Reflection - Checking that a Method Exists
# ================================

# There is no foolproof way for reflection to distinguish between a function or a method.

# ================================
# Reflection - Rooting Around in Symbol Tables
# ================================

# A symbol table is a special type of hash
# where the keys are the names of package global symbols
# and the values are typeglobs.
# A typeglob is an internal data structure
# which can contain a scalar, an array, a hash, a filehandle, and a function—any or all at once.

# Access a symbol table as a hash by appending double-colons to the name of the package.
# For example, the symbol table for the MonkeyGrinder package is available as (%MonkeyGrinder::).

# You can test the existence of specific symbol names within a symbol table
# with the exists operator (or manipulate the symbol table to add or remove symbols, if you like).
# Yet be aware that certain changes to the Perl core
# have modified the details of what typeglobs store and when and why.

# See the "Symbol Tables" section in perldoc perlmod for more details,
# then consider the other techniques explained earlier instead.
# If you really need to manipulate symbol tables and typeglobs,
# use the Package::Stash CPAN module.

# ================================
# Advanced OO Perl
# ================================

# Creating and using objects in Perl with Moose (Moose) is easy.
# Designing good programs is not.
# It's as easy to overdesign a program as it is to underdesign it.
# Only practical experience can help you understand the most important design techniques,
# but several principles can guide you.

# ================================
# Advanced OO Perl - Favor Composition Over Inheritance
# ================================

# Novice OO designs often overuse inheritance to reuse code and to exploit polymorphism.
# The result is a deep class hierarchy with responsibilities scattered all over the place.
# Maintaining this code is difficult—
# who knows where to add or edit behavior?
# What happens when code in one place conflicts with code declared elsewhere?

# Inheritance is only one of many tools for OO programmers.
# It's not always the right tool.
# It's often the wrong tool.
# A Car may extend Vehicle::Wheeled (an is-a relationship),
# but Car may better contain several Wheel objects as instance attributes (a has-a relationship).

# Decomposing complex classes into smaller, focused entities
# improves encapsulation
# and reduces the possibility that any one class or role does too much.
# Smaller, simpler, and better encapsulated entities are easier to understand, test, and maintain.

# ================================
# Advanced OO Perl - Single Responsibility Principle
# ================================

# When you design your object system,
# consider the responsibilities of each entity.
# For example, an (Employee) object
# may represent specific information about a person's name, contact information, and other personal data,
# while a (Job) object
# may represent business responsibilities.
# Separating these entities in terms of their responsibilities
# allows the (Employee) class to consider only
# the problem of managing information specific to who the person is
# and the (Job) class to represent what the person does.
# (Two (Employee)s may have a (Job)-sharing arrangement,
# for example, or one Employee may have the CFO and the COO Jobs.)

# When each class has a single responsibility,
# you reduce coupling between classes
# and improve the encapsulation of class-specific data and behavior.

# ================================
# Advanced OO Perl - Don't Repeat Yourself
# ================================

# Complexity and duplication complicate development and maintenance.
# The DRY principle (Don't Repeat Yourself) is a reminder to seek out
# and to eliminate duplication within the system.
# Duplication exists in data as well as in code.
# Instead of repeating configuration information,
# user data, and other important artifacts of your system,
# create a single, canonical representation of that information
# from which you can generate the other artifacts.

# This principle helps you to find the optimal representation of your system
# and its data and reduces the possibility that duplicate information will get out of sync.

# ================================
# Advanced OO Perl - Liskov Substitution Principle
# ================================

# The Liskov substitution principle suggests that
# you should be able to substitute a specialization of a class or a role for the original
# without violating the original's API.
# In other words, an object should be as or more general with regard to what it expects
# and at least as specific about what it produces as the object it replaces.

# Imagine two classes, Dessert and its child class PecanPie.
# If the classes follow the Liskov substitution principle,
# you can replace every use of Dessert objects with PecanPie objects in the test suite,
# and everything should pass.
# See Reg Braithwaite's "IS-STRICTLY-EQUIVALENT-TO-A" http://weblog.raganwald.com/2008/04/is-strictly-equivalent-to.html. for more details.

# ================================
# Advanced OO Perl - Subtypes and Coercions
# ================================

# Moose allows you to declare and use types
# and extend them through subtypes
# to form ever more specialized descriptions of what your data represents and how it behaves.
# These type annotations help verify that the function and method parameters are correct—
# or can be coerced into the proper data types.

# For example, you may wish to allow people to provide dates to a Ledger entry as strings
# while representing them as DateTime instances internally.
# You can do this by creating a Date type and adding a coercion from string types.
# See Moose::Util::TypeConstraints and MooseX::Types for more information.

# ================================
# Advanced OO Perl - Immutability
# ================================

# With a well-designed object, you tell it what to do, not how to do it.
# If you find yourself accessing object instance data (even through accessor methods)
# outside of the object itself,
# you may have too much access to an object's internals.

# OO novices often treat objects as if they were bundles of records
# which use methods to get and set internal values.
# This simple technique leads to the unfortunate temptation
# to spread the object's responsibilities throughout the entire system.

# You can prevent inappropriate access by making your objects immutable.
# Provide the necessary data to their constructors,
# then disallow any modifications of this information from outside the class.
# Expose no methods to mutate instance data—
# make all of your public accessors read-only and use internal attribute writers sparingly.
# Once you've constructed such an object, you know it's always in a valid state.
# You can never modify its data to put it in an invalid state.

# This takes tremendous discipline,
# but the resulting systems are robust, testable, and maintainable.
# Some designs go as far as to prohibit the modification of instance data within the class itself.

done_testing();
