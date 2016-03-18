#!/usr/bin/perl

#!/opt/pkg/bin/perl

# Version 4 of the engine. This variant always starts every iteration (start and after wait) by going back to
# the top of the state table. The starting state is set to login, but could be @table[0] or the equivalent.

# Run what might euphemistically called the v3 state table. This has 4 columns, test are functions, empty test
# defaults to true, empty function defaults to no-op (aka null),

use strict;
use Template;
use Data::Dumper;
$Data::Dumper::Sortkeys = 1;
use CGI;
# use CGI::Carp qw(fatalsToBrowser);
use session_lib qw(:all);
require 'wf_lib.pm';


# Usage: ./demo_v3.pl A state file 'state_v3.dat' is expected in he current directory. The state file is
# expected to be in Emacs org-table format.

# sub read_state_data() is hard coded for our needs, but Perl's Text::Table might handle it, and more
# flexibly.

# http://search.cpan.org/~shlomif/Text-Table-1.130/lib/Text/Table.pm

# Also: http://search.cpan.org/~perlancar/Org-Parser-0.44/

our @table; # state table, our to share with wf_lib.pm
our %ch; # CGI hash, our to share with wf_lib.pm
our %known_states;
our $default_state = 'start'; 
our $msg = '';
our $db_name;
our $dbh; 

main();

sub main
{
    $| = 1; # unbuffer stdout

    # The column args determine the name of the hash keys for the state table. That needs to be fixed, if for
    # no other reason it is very obscure.
    read_state_data("states.dat", 'edge', 'test', 'func', 'next');

    sanity_check_states();

    my $qq = new CGI;
    %ch = $qq->Vars();
    
    #$db_name = 'tag';
    $db_name = '/Users/twl/Sites/tagging/tag.db';

    # Based on a quick read of sqlite_db_handle() there is special stuff that has not yet been integrated into
    # get_db_handle(). Use sqlite_db_handle for now.

    # $dbh = get_db_handle($db_name);
    $dbh = sqlite_db_handle($db_name);

    $msg =  Dumper($dbh);

    my $temp;

    # Works
    # foreach my $var ($qq->param('options'))
    # {
    #     $temp .= "$var<br>\n";
    # }

    # also works
    # foreach my $var (split("\0", $ch{options}))
    # {
    #     $temp .= "$var<br>\n";
    # }
    
    # my $curr_state = $default_state;
    # if ($ch{curr_state})
    # {
    #     $curr_state = $ch{curr_state};
    # }
    # my $wait_next = '';
    
    # All this happens based on the cgi params
    
    my %trav = traverse($default_state);
    
    my $curr_state = $trav{wait_next};
        
    msg(sprintf("Upcoming choices will be: (for: $curr_state)"));
    my $options_list_str = '';
    my $checked = '';
    foreach my $hr (@table)
    {
        if (! $checked)
        {
            $checked = "checked";
        }
        if (($hr->{edge} eq $curr_state) && $hr->{test})
        {
            $options_list_str .= sprintf("$hr->{test}<br>\n");
        }
        $checked = ' '; # ugly way of setting checked to a non-value.
    }
    
    # render({options => options_checkboxes($curr_state),
    #         options_list_str => $options_list_str,
    #         curr_state => $trav{wait_next},
    #         msg => "$msg$trav{msg}"});
    
}

