#!/usr/bin/env perl
# REF: http://modernperlbooks.com/books/modern_perl_2016/09-managing-real-programs.html#RmlsZXM

use 5.034;
use warnings;
use autodie;
use feature 'say';

use Test::More;

# Most programs interact with the real world mostly by reading, writing, and otherwise manipulating files.
# Perl began as a tool for system administrators
# and is still a language well suited for text processing.

# ================================
# Input and Output
# ================================

# A filehandle represents the current state of one specific channel of input or output.
# Every Perl program starts with three standard filehandles,
# STDIN (the input to the program),
# STDOUT (the output from the program),
# and STDERR (the error output from the program).
# By default, everything you print or say goes to STDOUT,
# while errors and warnings go to STDERR.
# This separation of output allows you to redirect useful output and errors to two different places—
# an output file and error logs, for example.

# Use the open builtin to initialize a filehandle.
# To open a file for reading:
sub demo_open {
    my $filename = '';

    open my $fh, '<', 'filename' or die "Cannot read '$filename': $!\n";
}

# The first operand is a lexical which will contain the filehandle.
# The second operand is the file mode,
# which determines the type of file operation (reading, writing, appending, et cetera).
# The final operand is the name of the file on which to operate.
# If the open fails, the die clause will throw an exception,
# with the reason for failure in the ($!) magic variable.

# You may open files for writing, appending, reading and writing, and more.
# Some of the most important file modes are:
#
#     <, which opens a file for reading.
#     >, which open for writing, clobbering existing contents if the file exists and creating a new file otherwise.
#     >>, which opens a file for writing, appending to any existing contents and creating a new file otherwise.
#     +<, which opens a file for both reading and writing.
#     -|, which opens a pipe to an external process for reading.
#     |-, which opens a pipe to an external process for writing.

# You may also create filehandles which read from or write to plain Perl scalars,
# using any existing file mode:
sub demo_open_scalars {
    my $fake_input      = '';
    my $captured_output = '';

    open my $read_fh,  '<', \$fake_input;
    open my $write_fh, '>', \$captured_output;

    do_something_awesome( $read_fh, $write_fh );
}

# perldoc perlopentut explains in detail more exotic uses of open,
# including its ability to launch and control other processes,
# as well as the use of sysopen for finer-grained control over input and output.
# perldoc perlfaq5 includes working code for many common IO tasks.

# Assume the examples in this section have use autodie; enabled
# so as to elide explicit error handling.
# If you choose not to use autodie,
# check the return values of all system calls to handle errors appropriately.

# ================================
# Input and Output - Unicode, IO Layers, and File Modes
# ================================

# In addition to the file mode,
# you may add an IO encoding layer which allows Perl to encode to or decode from a Unicode encoding.
sub demo_encoding_layers {
    my $infile  = '';
    my $outfile = '';

    # For example, to read a file written in the UTF-8 encoding:
    open my $in_fh, '<:encoding(UTF-8)', $infile;

    # ... or to write to a file using the UTF-8 encoding:
    open my $out_fh, '>:encoding(UTF-8)', $outfile;
}

# ================================
# Input and Output - Two-argument open
# ================================

# Older code often uses the two-argument form of open(),
# which jams the file mode with the name of the file to open:
sub demo_two_arg_open {
    my $file = '';
    open my $fh, "> $file" or die "Cannot write to '$file': $!\n";
}

# Perl must extract the file mode from the filename.
# That's a risk; anytime Perl has to guess at what you mean, it may guess incorrectly.
# Worse, if $file came from untrusted user input, you have a potential security problem,
# as any unexpected characters could change how your program behaves.

# The three-argument open() is a safer replacement for this code.

# The special package global DATA filehandle represents the current file of source code.
# When Perl finishes compiling a file,
# it leaves DATA open and pointing to the end of the compilation unit
# if the file has a __DATA__ or __END__ section.
# Any text which occurs after that token is available for reading from DATA.
# The entire file is available if you use seek to rewind the filehandle.
# This is useful for short, self-contained programs.
# See perldoc perldata for more details.

# ================================
# Input and Output - Reading from Files
# ================================

# Given a filehandle opened for input,
# read from it with the readline builtin,
# also written as <>.
# A common idiom reads a line at a time in a while() loop:
sub demo_readline {
    open my $fh, '<', 'some_file';

    while (<$fh>) {
        chomp;
        say "Read a line '$_'";
    }
}

# In scalar context, readline reads a single line of the file and returns it,
# or undef if it's reached the end of file (test that condition with the eof builtin).
# Each iteration in this example returns the next line or undef.
# This while idiom explicitly checks the definedness of the variable used for iteration,
# so only the end of file condition will end the loop.
# This idiom is equivalent to:
sub demo_check_eof {
    open my $fh, '<', 'some_file';

    while ( defined( $_ = <$fh> ) ) {
        chomp;
        say "Read a line '$_'";
        last if eof $fh;
    }
}

# NOTE: Why use while and not for?
# for imposes list context on its operands.
# When in list context, readline will read the entire file before processing any of it.
# while performs iteration and reads a line at a time.
# When memory use is a concern, use while.

# Every line read from readline includes the character or characters which mark the end of a line.
# In most cases, this is a platform-specific sequence
# consisting of a newline (\n), a carriage return (\r), or a combination of the two (\r\n).
# Use chomp to remove it.

# The cleanest way to read a file line-by-line in Perl is:
sub demo_cleanest_readline {
    my $filename = '';

    open my $fh, '<', $filename;

    while ( my $line = <$fh> ) {
        chomp $line;
        ...;
    }
}

# Perl assumes that files contain text by default.
# If you're reading binary data—a media file or a compressed file, for example—
# use binmode before performing any IO.
# This will force Perl to treat the file data as pure data,
# without modifying it in any way,
# such as translating \n into the platform-specific newline sequence.
# While Unix-like platforms may not always need binmode,
# portable programs play it safe (Unicode and Strings).

# ================================
# Input and Output - Writing to Files
# ================================

# Given a filehandle open for output, print or say to write to the file:
sub demo_write {
    open my $out_fh, '>', 'output_file.txt';

    print $out_fh "Here's a line of text\n";
    say $out_fh "... and here's another";
}

# NOTE the lack of comma between the filehandle and the next operand.

# Damian Conway's Perl Best Practices recommends enclosing the filehandle in curly braces as a habit.
# This is necessary to disambiguate parsing of a filehandle
# contained in anything other than a plain scalar—
# a filehandle in an array or hash or returned from an object method—
# and it won't hurt anything in the simpler cases.

# TODO: review
# Both print and say take a list of operands.
# Perl uses the magic global ($,) as the separator between list values.
# Perl uses any value of ($\) as the final argument to print
# (but always uses \n as an implicit final argument to say).
# Remember that ($\) is undef by default.
# These two examples produce the same result:
{
    my @princes = qw( Corwin Eric Random ... );
    local $\ = "\n\n";

    # prints a list of princes, followed by two newlines
    print @princes;

    local $\ = '';
    print join( $,, @princes ) . "\n\n";
}

# ================================
# Input and Output - Closing Files
# ================================

# When you've finished working with a file,
# close its filehandle explicitly or allow it to go out of scope.
# Perl will close it for you.
# The benefit of calling close explicitly is that you can check for—and recover from—specific errors,
# such as running out of space on a storage device
# or a broken network connection.

# As usual, autodie handles these checks for you:
sub demo_close {
    use autodie qw( open close );

    my $file = '';
    open my $fh, '>', $file;

    ...;

    close $fh;
}

# ================================
# TODO: review Input and Output - Special File Handling Variables
# ================================

# For every line read,
# Perl increments the value of the variable ($.),
# which serves as a line counter.

# (readline) uses the current contents of $/ as the line-ending sequence.
# The value of this variable defaults to
# the most appropriate line-ending character sequence for text files on your current platform.
# The word line is a misnomer, however.
# ($/) can contain any sequence of characters (but not a regular expression).
# This is useful for highly-structured data in which you want to read a record at a time.

# NOTE: Given a file with records separated by two blank lines,
# set $/ to \n\n to read a record at a time.
# Use chomp on a record read from the file to remove the double-newline sequence.

# Perl buffers its output by default,
# performing IO only when the amount of pending output exceeds a threshold.
# This allows Perl to batch up expensive IO operations
# instead of always writing very small amounts of data.
# Yet sometimes you want to send data as soon as you have it without waiting for that buffering—
# especially if you're writing a command-line filter connected to other programs
# or a line-oriented network service.

# The $| variable controls buffering on the currently active output filehandle.
# When set to a non-zero value, Perl will flush the output after each write to the filehandle.
# When set to a zero value, Perl will use its default buffering strategy.

# Files default to a fully-buffered strategy.
# (STDOUT) when connected to an active terminal—
# but not another program—
# uses a line-buffered strategy,
# where Perl flushes (STDOUT) every time it encounters a newline in the output.

# Instead of cluttering your code with a global variable,
# use the autoflush() method to change the buffering behavior of a lexical filehandle:
sub demo_autoflush {
    open my $fh, '>', 'pecan.log';
    $fh->autoflush(1);
}

# You can call any method provided by IO::File on a filehandle.
# For example,
# the input_line_number() and input_record_separator() methods do the job of ($.) and ($/) on individual filehandles.
# See the documentation for IO::File, IO::Handle, and IO::Seekable.

# ================================
# Directories and Paths
# ================================

# Working with directories is similar to working with files,
# except that you cannot write to directories.
# Open a directory handle with the opendir builtin:
sub demo_opendir {
    opendir my $dirh, '/home/monkeytamer/tasks/';
}

# The readdir builtin reads from a directory.
# As with readline, you may iterate over the contents of directories one entry at a time
# or you may assign everything to an array in one swoop:
sub demo_readdir {

    # iteration
    opendir my $dirh, '';
    while ( my $file = readdir $dirh ) {
        ...;
    }

    # flatten into a list, assign to array
    opendir my $otherdirh, '';
    my @files = readdir $otherdirh;
}

# In a while loop, readdir sets $_:
sub demo_readdir_magic_variable {
    opendir my $dirh, 'tasks/circus/';

    while ( readdir $dirh ) {
        next if /^\./;
        say "Found a task $_!";
    }
}

# The curious regular expression in this example skips so-called hidden files on Unix and Unix-like systems,
# where a leading dot prevents them from appearing in directory listings by default.
# It also skips the two special files . and ..,
# which represent the current directory and the parent directory respectively.

# The names returned from readdir are relative to the directory itself.
# (Remember that an absolute path is a path fully qualified to its filesystem.)
# If the tasks/ directory contains three files
# named eat, drink, and be_monkey,
# readdir will return eat, drink, and be_monkey
# instead of tasks/eat, tasks/drink, and task/be_monkey.

# Close a directory handle with the closedir builtin or by letting it go out of scope.

# ================================
# Directories and Paths - Manipulating Paths
# ================================

# Perl offers a Unixy view of your filesystem
# and will interpret Unix-style paths appropriately for your operating system and filesystem.
# If you're using Microsoft Windows,
# you can use the path C:/My Documents/Robots/Bender/
# just as easily as you can use the path C:\My Documents\Robots\Caprica Six\.

# Even though Perl uses Unix file semantics consistently,
# cross-platform file manipulation is much easier with a module.
# The core File::Spec module family lets you manipulate file paths safely and portably.
# It's a little clunky, but it's well documented.

# The Path::Class distribution on the CPAN has a nicer interface.
# {
#     use Path::Class;
#
#     # Use the dir() function to create an object representing a directory
#     # and the file() function to create an object representing a file:
#     my $meals = dir( 'tasks', 'cooking' );
#     my $file  = file( 'tasks', 'health', 'robots.txt' );
#
#     # You can get file objects from directories and vice versa:
#     my $lunch      = $meals->file('veggie_calzone');
#     my $robots_dir = $robot_list->dir;
#
#     # You can even open filehandles to directories and files:
#     my $dir_fh    = $dir->open;
#     my $robots_fh = $robot_list->open('r') or die "Open failed: $!";
#
#     # Both Path::Class::Dir and Path::Class::File offer further useful behaviors—
#     # though beware that if you use a Path::Class object of some kind
#     # with an operator or function which expects a string containing a file path,
#     # you need to stringify the object yourself.
#     # This is a persistent but minor annoyance.
#     # (If you find it burdensome, try Path::Tiny as an alternative.)
#     my $contents = read_from_filename("$lunch");
# }

# ================================
# File Manipulation
# ================================

# Besides reading and writing files,
# you can also manipulate them as you would directly from a command line or a file manager.
# The file test operators,
# collectively called the -X operators,
# examine file and directory attributes.
# To test that a file exists:
sub demo_file_existence {
    my $filename = '';
    say 'Present!' if -e $filename;
}

# The -e operator has a single operand,
# either the name of a file
# or handle to a file or directory.
# If the file or directory exists,
# the expression will evaluate to a true value.
# perldoc -f -X lists all other file tests.

# -f returns a true value if its operand is a plain file.
# -d returns a true value if its operand is a directory.
# -r returns a true value if the file permissions of its operand permit reading by the current user.
# -s returns a true value if its operand is a non-empty file.
# Look up the documentation for any of these operators with perldoc -f -r, for example.

# The rename builtin can rename a file or move it between directories.
# It takes two operands, the old path of the file and the new path:
sub demo_rename {
    rename 'death_star.txt', 'carbon_sink.txt';

    # or if you're stylish:
    rename 'death_star.txt' => 'carbon_sink.txt';
}

# There's no core builtin to copy a file,
# but the core File::Copy module provides both copy() and move() functions.
# Use the unlink builtin to remove one or more files.
# (The delete builtin deletes an element from a hash, not a file from the filesystem.)
# These functions and builtins all return true values on success and set $! on error.

# Path::Class also provides convenience methods to remove files completely
# and portably as well as to check certain file attributes.

# Perl tracks its current working directory.
# By default, this is the active directory from where you launched the program.
# The core Cwd module's cwd() function returns the name of the current working directory.
# The builtin chdir attempts to change the current working directory.
# Working from the correct directory is essential to working with files with relative paths.

# The CPAN module File::chdir makes manipulating the current working directory easier.
# If you're a fan of the command line and use pushd and popd, see also File::pushd.

done_testing();
