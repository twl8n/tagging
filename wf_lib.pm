
use strict;
our %ch;
our @table; # list of hash, see read_state_date() keys: edge, test, func, next
our %known_states;
our $default_state;
our $msg;

our $db_name;
our $dbh; 

my $verbose = 0;

my $config = {
              TRIM => 1,            # trim leading and trailing whitespace
              INCLUDE_PATH => './', # or list ref
              INTERPOLATE  => 0,    # expand "$var" in plain text
              POST_CHOMP   => 0,    # do not cleanup whitespace
              PRE_PROCESS  => '',   # prefix each template
              EVAL_PERL    => 0,    # evaluate Perl code blocks
              ANYCASE => 1,         # Allow directive keywords in lower case (default: 0 - UPPER only)
              ENCODING => 'utf8'    # Force utf8 encoding
             };

# require this file to get the standard functions for the work flow engine. 

sub draw_home
{
    print "Content-type:text/plain\n\nHello world.\n";
}


sub options_checkboxes
{
    my $curr_state = $_[0];
    my $html = "";
    my %unique;
    my @all_tests;
    # First we need a list of unique tests.
    foreach my $hr (@table)
    {
        if ($hr->{test} && ! exists($unique{$hr->{test}}))
        {
            $unique{$hr->{test}} = 1;
            push(@all_tests, $hr->{test});
        }
    }

    my $curr_state_test = $curr_state;
    $curr_state_test =~ s/(.*)\-input/if-page-$1/;
    
    # foreach over the sorted list so the order is always the same.
    foreach my $test (sort(@all_tests))
    {
            my $checked = '';
            my $auto_msg = '';
            my $disabled = '';

            # If a checkbox is checked, and it isn't an "if-page-x" test, then keep it checked.  Else if the
            # matches the current states if-page-x, set the check, else unchecked. dashboard-input causes
            # if-page-dashboard to be true.

            if (check_demo_cgi($test) && $test !~ m/if\-page/)
            {
                $checked = 'checked';
            }
            elsif ($test eq $curr_state_test)
            {
                $checked = 'checked';
                $auto_msg = "(auto-checked)";
            }

            if ($test =~ m/if\-not\-/)
            {
                my $not_test = $test;
                $not_test =~ s/if\-not\-(.*)/if-$1/;
                $auto_msg = "(disabled, depends on $not_test)";
                $disabled = "disabled";
            }

            # Always uncheck if-go-x because presumably we went there. Users need to say where to do on each
            # request, so we don't want these properties to carry over.

            if ($test =~ m/if\-go\-/ || $test =~ m/if\-do\-/)
            {
                $checked = '';
                $auto_msg = "(auto-cleared)";
            }

            $html .= "$test <input type=\"checkbox\" name=\"options\" value=\"$test\" $checked $disabled> $auto_msg <br>\n";
    }
    return $html;
}

sub msg
{
    $msg .= "$_[0]<br>\n";
    # print "$_[0]\n";
}

sub traverse
{
    my $curr_state = $_[0];
    my $msg;
    my $wait_next = '';
    my $last_flag = 0;
    my $do_next = 1;

    # In the old days, when we came out of wait, we ran the wait_next state. Now we start at the beginning,
    # and we have an if-test to get us back to a state that will match the rest of the input in the http
    # request.

    my $xx = 0;
    while ($do_next)
    {
        msg("<span style=\"background-color:lightblue;\">Going into state: $curr_state</span>");
        $last_flag = 0;
        foreach my $hr (@table)
        {
            if (($hr->{edge} eq $curr_state))
            {
                if ((dispatch($hr, 'test')) ||
                    ($hr->{test} eq 'true') ||
                    ($hr->{test} eq ''))
                {
                    # Defaulting to the function as the choice makes sense most of the time, but not with return()
                    # $choice = $hr->{func};
                    $last_flag = 1;

                    # Unless we hit a wait function, we continue with the next state.
                    $do_next = 1;

                    if ($hr->{func} eq 'null' || $hr->{func} eq '')
                    {
                        $curr_state = $hr->{next};
                        # Do nothing.
                    }
                    elsif ($hr->{func} =~ m/^jump\((.*)\)/)
                    {
                        # Ick. Capture inside literal parens is weird looking. (above)
                        my $jump_to_state = $1;
                        # Push the state we will transition to when we return.
                        push_state($hr->{next});
                        $curr_state = $jump_to_state;
                    }
                    elsif ($hr->{func} =~ m/^return[\(\)]*/)
                    {
                        $curr_state = pop_state();
                        # Is $curr_state really correct for the automatic choice when doing return()? $hr->{func}
                        # is not correct, btw.
                        # $choice = $curr_state
                    }
                    elsif ($hr->{func} =~ m/^wait/)
                    {
                        # Up above, this should cause all choices to become available.  We could get back pretty
                        # much any input from the user, but depending on the wait state, only certain other states
                        # will be acceptable.
                        $wait_next = $hr->{next};
                        # $wait_next = $default_state;
                        $do_next = 0;
                    }
                    else
                    {
                        msg("<span style='background-color:lightgreen;'>Dispatch function: $hr->{func}</span>");
                    
                        # Eventually, the state table will be sanity checked, and perhaps munged so that nothing
                        # bad can happen. For now do a little sanity checking right here.
                    
                        my $return_value = dispatch($hr, 'func');
                        if ($hr->{next})
                        {
                            $curr_state = $hr->{next};
                        }
                        else
                        {
                            $last_flag = 0;
                        }
                        # Else, the $curr_state is unchanged, iterate
                    }
                    # msg("end of if curr_state: $curr_state do_next: $do_next last_flag: $last_flag");
                }
                elsif ($hr->{test} && $verbose)
                {
                    msg("If: $hr->{test} is false,");
                    if ($hr->{func})
                    {
                        msg("not running func: $hr->{func}, ");
                    }
                    msg("not going to state: $hr->{next}");
                }
            }
            else
            {
                # msg("$hr->{edge} is not $curr_state last_flag: $last_flag");
            }
            if ($last_flag)
            {
                last;
            }
        }
        $xx++;
        if ($xx > 30)
        {
            msg("Error: inf loop catcher!");
            last;
        }
    }


    my %tresults; # traverse results
    $tresults{wait_next} = $wait_next;
    $tresults{msg} = $msg;
    return %tresults;
}


my @state_stack = [];

sub push_state
{
    push(@state_stack, $_[0]);
}

sub pop_state
{
    return pop(@state_stack);
}

sub table_to_html
{
    my $html = "<table border=\"1\">\n";
    $html .= "<tr bgcolor='lightgray'>\n";
    foreach my $head ('State', 'Test', 'Func', 'Next-state')
    {
        $html .= "<td>$head</td>\n";
    }
    $html .= "</tr>\n";

    foreach my $hr (@table)
    {
        $html .= "<tr>\n";
        foreach my $key ('edge', 'test', 'func', 'next')
        {
            $html .= "<td>$hr->{$key}</td>\n";
        }
        $html .= "</tr>\n";
    }
    $html .= "</table>\n";
}

sub sql_select_vocab
{
    my %arg = @_;
    
    my $sql=
    "select vocab.*,zz.term as type_name
    from vocab, (select term,id from vocab) as zz
    where
    vocab.type=zz.id order by type";

    my $sth = $dbh->prepare($sql);
    err_stuff($dbh, $sql, "exec", $db_name, (caller(0))[3]);

    $sth->execute();
    err_stuff($dbh, $sql, "exec", $db_name, (caller(0))[3]);

    my @records;
    while(my $hr = $sth->fetchrow_hashref())
    {
        push(@records, $hr);
    }
    return @records;
}

sub sql_select_core
{
    my %arg = @_;
    
    # 
    # core type happens to be 1, but use id of the record with term 'core'. The term 'core' is canonical for our system.
    # 
    my $sql="select * from vocab where type=(select id from vocab where term='core')";

    my $sth = $dbh->prepare($sql);
    err_stuff($dbh, $sql, "exec", $db_name, (caller(0))[3]);

    $sth->execute();
    err_stuff($dbh, $sql, "exec", $db_name, (caller(0))[3]);

    my @records;
    while(my $hr = $sth->fetchrow_hashref())
    {
        push(@records, $hr);
    }
    return @records;
}

sub sql_add_vocab
{
    my %arg = @_;
    my $term = $arg{term};
    my $type = $arg{type};

    print("term: $term type: $type\n");
   
    my $sql="insert into vocab (term, type) values (?,?)";
    my $sth = $dbh->prepare($sql);
    err_stuff($dbh, $sql, "exec", $db_name, (caller(0))[3]);

    $sth->execute($term, $type);
    err_stuff($dbh, $sql, "exec", $db_name, (caller(0))[3]);
    commit_handle($db_name);
}

sub sql_select_prototype
{
    my %arg = @_;
    my $db_name = $arg{db_name};
    
    my $dbh = get_db_handle($db_name);
    
    my $sql="";
    my $sth = $dbh->prepare($sql);
    err_stuff($dbh, $sql, "exec", $db_name, (caller(0))[3]);

    $sth->execute();
    err_stuff($dbh, $sql, "exec", $db_name, (caller(0))[3]);

    my @records;
    while(my $hr = $sth->fetchrow_hashref())
    {
	push(@records, $hr);
    }
    return @records;
}

# Select tagged things
sub sql_select_tagged_thing
{
    my $sql="
    select *,(select term from vocab where tag.vocab_fk=vocab.id) as vocab_name,
    (select name from item where tag.item_fk=item.id) as item_name
    from tag order by item_fk";
    my $sth = $dbh->prepare($sql);
    err_stuff($dbh, $sql, "exec", $db_name, (caller(0))[3]);

    $sth->execute();
    err_stuff($dbh, $sql, "exec", $db_name, (caller(0))[3]);

    my @records;
    while(my $hr = $sth->fetchrow_hashref())
    {
	push(@records, $hr);
    }
    return @records;
}

# Select a single item by id.
# Use when viewing or editing an item.
sub sql_select_item_info
{
    my $id = $_[0];
    my $sql="select * from item where id=?";

    my $sth = $dbh->prepare($sql);
    err_stuff($dbh, $sql, "exec", $db_name, (caller(0))[3]);

    $sth->execute($id);
    err_stuff($dbh, $sql, "exec", $db_name, (caller(0))[3]);

    my $hr = $sth->fetchrow_hashref();
    return $hr;
}

sub sql_select_thing
{
    my $sql="select * from item order by name";
    my $sth = $dbh->prepare($sql);
    err_stuff($dbh, $sql, "exec", $db_name, (caller(0))[3]);

    $sth->execute();
    err_stuff($dbh, $sql, "exec", $db_name, (caller(0))[3]);

    my @records;
    while(my $hr = $sth->fetchrow_hashref())
    {
	push(@records, $hr);
    }
    return @records;
}

sub sql_add_thing
{
    my %arg = @_;
    my $name = $arg{name};
    my $note = $arg{note};

    my $sql = "insert into item (name, note) values (?,?)";
    my $sth = $dbh->prepare($sql);
    err_stuff($dbh, $sql, "exec", $db_name, (caller(0))[3]);

    $sth->execute($name, $note);
    err_stuff($dbh, $sql, "exec", $db_name, (caller(0))[3]);
    
    commit_handle($db_name);
}

sub sql_select_thing_id
{
    my $thing = $_[0];
    my $sql="select id from item where name=?";
    my $sth = $dbh->prepare($sql);
    err_stuff($dbh, $sql, "exec", $db_name, (caller(0))[3]);

    $sth->execute($thing);
    err_stuff($dbh, $sql, "exec", $db_name, (caller(0))[3]);

    my $hr = $sth->fetchrow_hashref();
    return $hr->{id};
}

# Take optional arg as the vocab_fk and if set and if it matches an id, set the key 'selected' to 'selected'.
# Kind of icky to have what is an HTML attribute deep in the SQL code, but this is a convenient place for it.
# Convenient place to add columns that appear in the output.
sub sql_select_tag
{
    my $vocab_fk = $_[0];
    my $sql="select * from vocab where type=(select id from vocab where term='tag') order by term";
    my $sth = $dbh->prepare($sql);
    err_stuff($dbh, $sql, "exec", $db_name, (caller(0))[3]);

    $sth->execute();
    err_stuff($dbh, $sql, "exec", $db_name, (caller(0))[3]);

    my @records;
    while(my $hr = $sth->fetchrow_hashref())
    {
        $hr->{selected} = '';
        if ($vocab_fk && $hr->{id} == $vocab_fk)
        {
            $hr->{selected} = 'selected';
        }
	push(@records, $hr);
    }
    return @records;
}

sub sql_select_vocab_id
{
    my $term = $_[0];
    my $sql="select id from vocab where term=?";
    my $sth = $dbh->prepare($sql);
    err_stuff($dbh, $sql, "exec", $db_name, (caller(0))[3]);

    $sth->execute($term);
    err_stuff($dbh, $sql, "exec", $db_name, (caller(0))[3]);

    my $hr = $sth->fetchrow_hashref();
    return $hr->{id};
}


sub sql_add_tag
{
    my %arg = @_;
    my $vocab_fk =$arg{tag};
    my $thing = $arg{thing};
    my $numeric = $arg{numeric};
    my $unit = $arg{unit};
    my $value = $arg{value};
    my $note = $arg{note};
                
    my $item_fk = sql_select_thing_id($thing);

    msg("item_fk: $item_fk vocab_fk: $vocab_fk<br>");
    
    my $sql = "insert into tag (item_fk, vocab_fk, numeric, unit, value, note) values (?,?,?,?,?,?)";
    my $sth = $dbh->prepare($sql);
    err_stuff($dbh, $sql, "exec", $db_name, (caller(0))[3]);

    $sth->execute($item_fk, $vocab_fk, $numeric, $unit, $value, $note);
    err_stuff($dbh, $sql, "exec", $db_name, (caller(0))[3]);
    
    commit_handle($db_name);
}


sub sql_add_type
{
    my %arg = @_;
    my $type = $arg{type};

    my $sql="select max(type) as type from vocab";
    my $sth = $dbh->prepare($sql);
    err_stuff($dbh, $sql, "exec", $db_name, (caller(0))[3]);

    $sth->execute();
    err_stuff($dbh, $sql, "exec", $db_name, (caller(0))[3]);
    my $hr = $sth->fetchrow_hashref();

    $sql = "insert into vocab (term, type) values (?,?)";
    $sth = $dbh->prepare($sql);
    err_stuff($dbh, $sql, "exec", $db_name, (caller(0))[3]);

    $sth->execute($type, $hr->{type}+1);
    err_stuff($dbh, $sql, "exec", $db_name, (caller(0))[3]);
    
    commit_handle($db_name);
}


sub add_type
{
    sql_add_type(type => $ch{type});
}

sub add_tag
{
    sql_add_tag(tag => $ch{tag},
                thing => $ch{thing},
                numeric => $ch{numeric},
                unit => $ch{unit},
                value => $ch{value},
                note => $ch{note});
}

sub add_thing
{
    sql_add_thing(name => $ch{name}, note => $ch{name});
}

sub button_new_type
{
    if (exists($ch{button_new_type}))
    {
        return 1;
    }
    return 0;
}

sub button_new_thing
{
    if (exists($ch{button_new_thing}))
    {
        return 1;
    }
    return 0;
}

sub button_tag_add
{
    if (exists($ch{button_tag_add}))
    {
        return 1;
    }
    return 0;
}

sub button_vocab_add
{
    if (exists($ch{button_vocab_add}))
    {
        return 1;
    }
    return 0;
}

sub add_vocab
{
    msg("adding term: $ch{term} type: $ch{type}");
    sql_add_vocab(term => $ch{term}, type =>$ch{type});
}

sub save_tag
{
    msg("save_tag called<br>");
    sql_update_tag_record(id => $ch{id},
                          item_fk => $ch{item_fk},
                          vocab_fk => $ch{tag},
                          numeric => $ch{numeric},
                          name => $ch{name},
                          unit => $ch{unit},
                          value => $ch{value},
                          note => $ch{note});
                          
}

# update a single tagged record
sub sql_update_tag_record
{
    my %arg = @_;
    # my $term = $arg{term};
    # my $type = $arg{type};

    my $tag_id = $_[0];
    my $sql="
    update tag set item_fk=?, vocab_fk=?, numeric=?, unit=?, value=?, note=? where id=?";
    my $sth = $dbh->prepare($sql);
    err_stuff($dbh, $sql, "exec", $db_name, (caller(0))[3]);

    $sth->execute($arg{item_fk},
                  $arg{vocab_fk},
                  $arg{numeric},
                  $arg{unit},
                  $arg{value},
                  $arg{note},
                  $arg{id});
    err_stuff($dbh, $sql, "exec", $db_name, (caller(0))[3]);
    commit_handle($db_name);
}

# Select all the tags for a given item by item.id=tag.item_fk 
sub sql_select_tag_list
{
    my $item_fk = $_[0];
    my $sql="
    select *,(select term from vocab where tag.vocab_fk=vocab.id) as vocab_name,
    (select name from item where tag.item_fk=item.id) as item_name
    from tag where item_fk=?";
    my $sth = $dbh->prepare($sql);
    err_stuff($dbh, $sql, "exec", $db_name, (caller(0))[3]);

    $sth->execute($item_fk);
    err_stuff($dbh, $sql, "exec", $db_name, (caller(0))[3]);

    my @records;
    while(my $hr = $sth->fetchrow_hashref())
    {
        push(@records, $hr);
    }
    return @records;
}


# Select a single tag record
sub sql_select_tag_record
{
    my $tag_id = $_[0];
    my $sql="
    select *,(select term from vocab where tag.vocab_fk=vocab.id) as vocab_name,
    (select name from item where tag.item_fk=item.id) as item_name
    from tag where id=?";
    my $sth = $dbh->prepare($sql);
    err_stuff($dbh, $sql, "exec", $db_name, (caller(0))[3]);

    $sth->execute($tag_id);
    err_stuff($dbh, $sql, "exec", $db_name, (caller(0))[3]);

    my $hr = $sth->fetchrow_hashref();
    return $hr;
}

sub render_item_info
{
    # $msg .= Dumper(\%ch);

    # $tagged_record is a hashref for a single record
    my $tagged_record = sql_select_item_info($ch{id});

    # my @tag_id_list = sql_select_tag($tagged_record->{vocab_fk});
    my @tag_id_list = sql_select_tag_list($tagged_record->{id});
    # msg(Dumper(\@tag_id_list));

    # A hash reference. These are template variables.
    # Lists (and hashes?) as references.
    # Scalars as simply vars (not references).
    my $vars =
    {
     tag_id_list => \@tag_id_list,
     rec => $tagged_record,
     msg => $msg
    };

    # create Template object
    my $template = Template->new($config);

    # specify input filename, or file handle, text reference, etc.
    my $input = 'view_item.html';

    # process input template, substituting variables
    # http://search.cpan.org/~abw/Template-Toolkit-2.26/lib/Template.pm#process%28$template,_\%vars,_$output,_%options%29
    # Third arg can be a GLOB ready for output.
    # $template->process($input, $vars, $out) || die $template->error();

    print "Content-type: text/html\n\n";
    $template->process($input, $vars) || die $template->error();
    #close($out);

}

sub render_tag_edit
{
    $msg .= Dumper(\%ch);
    # $tagged_record is a hashref
    my $tagged_record = sql_select_tag_record($ch{id});

    #
    # (What?) Need to add key 'selected' for the selected tag id
    #
    my @tag_id_list = sql_select_tag($tagged_record->{vocab_fk});


    # A hash reference. These are template variables.
    # Lists (and hashes?) as references.
    # Scalars as simply vars (not references).
    my $vars =
    {
     tag_id_list => \@tag_id_list,
     rec => $tagged_record,
     msg => $msg
    };

    # create Template object
    my $template = Template->new($config);

    # specify input filename, or file handle, text reference, etc.
    my $input = 'edit_tag.html';

    # process input template, substituting variables
    # http://search.cpan.org/~abw/Template-Toolkit-2.26/lib/Template.pm#process%28$template,_\%vars,_$output,_%options%29
    # Third arg can be a GLOB ready for output.
    # $template->process($input, $vars, $out) || die $template->error();

    print "Content-type: text/html\n\n";
    $template->process($input, $vars) || die $template->error();
    #close($out);

}

sub render
{
    # my ($args) = @_;

    $msg .= Dumper(\%ch);
    my @vocab = sql_select_vocab();
    my @term_list = sql_select_core();
    my @thing_list = sql_select_thing();
    my @tag_id_list = sql_select_tag();
    my @tagged_thing_list = sql_select_tagged_thing();

    # A hash reference. These are template variables.
    # Lists (and hashes?) as references.
    # Scalars as simply vars (not references).
    my $vars =
    {
     vocab => \@vocab,
     type_list => \@term_list,
     thing_list => \@thing_list,
     tagged_thing_list => \@tagged_thing_list,
     tag_id_list => \@tag_id_list,
     msg => $msg
    };

    # create Template object
    my $template = Template->new($config);

    # specify input filename, or file handle, text reference, etc.
    my $input = 'index.html';

    # process input template, substituting variables

    # my $fn = "$render_path/$vars->{cpf_record_id}\.xml";
    # open(my $out, '>', $fn) || die "Can't open $fn for output\n";

    # http://search.cpan.org/~abw/Template-Toolkit-2.26/lib/Template.pm#process%28$template,_\%vars,_$output,_%options%29
    # Third arg can be a GLOB ready for output.
    # $template->process($input, $vars, $out) || die $template->error();

    print "Content-type: text/html\n\n";
    $template->process($input, $vars) || die $template->error();
    #close($out);

}

sub old_render
{
    my ($args) = @_;
    my $options = $args->{options};
    my $curr_state = $args->{curr_state};
    my $msg = $args->{msg};
    my $options_list_str = $args->{options_list_str};

    my $table = table_to_html();

    # print "Content-type: text/plain\n\n";
    # print "Current state: $curr_state<br>\n";
    # print $options;

    my $template = read_file('index.html');
    $template =~ s/\$options_list_str/$options_list_str/smg;
    $template =~ s/\$options/$options/smg;
    $template =~ s/\$curr_state/$curr_state/smg;
    $template =~ s/\$msg/$msg/smg;
    $template =~ s/\$table/$table/smg;
    
    print "Content-type: text/html\n\n";
    print $template;

}

# Quick shortcut to check if- functions from the CGI input. If the CGI key exists and is true, then return
# true, else return false

sub check_demo_cgi
{
    my $key = $_[0];
    my %opts;
    foreach my $opt (split("\0", $ch{options}))
    {
        $opts{$opt} = 1;
    }

    my $not_complement_key = $key;
    $not_complement_key =~ s/if\-not\-(.*)/if-$1/;
    
    if ($key =~ m/^if\-not\-/)
    {
        if ($opts{$not_complement_key})
        {
            return 0;
        }
        else
        {
            return 1;
        }
    }
    elsif ($key =~ m/^if\-/ && $opts{$key})
    {
        return 1;
    }
    return 0;
}

sub dispatch
{
    my $hr = $_[0];
    my $key = $_[1];

    my %funcs = ('button_view_item' => sub { return exists($ch{button_view_item}); },
                 'button_edit_item' => sub { return exists($ch{button_edi_item}); },
                 'button_edit_tag' => sub { return exists($ch{button_edit_tag}); },
                 'button_tag_update' => sub {  return exists($ch{button_tag_update}); },
                 'render_item_info' => \&render_item_info,
                 'render_tag_edit' => \&render_tag_edit,
                 'save_tag' => \&save_tag,
                 'button_tag_add' => \&button_tag_add,
                 'add_tag' => \&add_tag,
                 'button_new_thing' => \&button_new_thing,
                 'add_thing' => \&add_thing,
                 'button_vocab_add' => \&button_vocab_add,
                 'button_new_type' => \&button_new_type,
                 'add_type' => \&add_type,
                 'add_vocab' => \&add_vocab,
                 'render' => \&render,
                 'true' => sub { return 1; });

    my $what_to_run = $hr->{$key};

    # If no function, then default to true, but use the true function so we can always run a function. Blank
    # states are true as a convention.

    if (!$what_to_run)
    {
        $what_to_run = 'true';
    }
    if (!exists($funcs{$what_to_run}))
    {
        return 0;
    }
    return &{$funcs{$what_to_run}};

    # In the old days, we defaulted logout as a special case. Auto-clear some options based one the function
    # 'logout' or any if-do-x test option.

    if ($hr->{$key} eq 'logout')
    {
        # Yikes. A bit crude but should work. Will leave \0\0 in the options string.
        $ch{options} =~ s/if\-logged\-in//;
        # msg("logout options: $ch{options}");
    }
}



# The column args determine the name of the hash keys for the state table. That needs to be fixed, if for
# no other reason it is very obscure.
# read_state_data("states.dat", 'edge', 'test', 'func', 'next');

sub read_state_data
{
    my $data_file = shift(@_);
    my @va = @_; # remaining args are column names, va mnemonic for variables.

    # print "Reading state data file: $data_file\n";
    my($temp);
    my @fields;
    
    my $log_flag = 0;

    if (! open(IN, "<",  $data_file))
    {
        if (! $log_flag)
        {
            print ("Error: Can't open $data_file for reading\n");
            $log_flag = 1;
        }
    }
    else
    {
        my $ignore_first_line = <IN>;
        while ($temp = <IN>)
        {
            my $new_hr;

            # Remove the leading | and optional whitespace. 
            $temp =~ s/^\|\s*//;

            if ($temp =~ m/^\s*#/)
            {
                # We have a comment, ignore this line.
                next;
            }

            if ($temp =~ m/^\-\-/)
            {
                # We have a separator line, ignore.
                next;
            }

            # Don't use split because Perl will truncate the returned array due to an undersireable feature
            # where arrays returned and assigned have null elements truncated.

            # Also, make sure there is a terminal \n which makes the regex both simpler and more robust.

            if ($temp !~ m/\n$/)
            {
                $temp .= "\n";
            }

            # Get all the fields before we start so the code below is cleaner, and we want all the line
            # splitting regex to happen here so we can swap between tab-separated, whitespace-separated, and
            # whatever.

            my $has_values = 0;
            my @fields;
            while ($temp =~ s/^(.*?)(?:\s*\|\s+|\n)//smg)
            {
                # Clean up "$var" and "func()" to be "var" and "func".
                my $raw = $1;
                $raw =~ s/\(\)//;
                $raw =~ s/^\$//;

                # Trim whitespace from values. This probably only occurs when there aren't | chars on the line.
                $raw =~ s/^\s+(.*)\s+$/$1/;
                if ($raw ne '')
                {
                    $has_values = 1;
                }
                push(@fields, $raw);
            }
            
            if ($has_values)
            {
                for (my $xx=0; $xx<=$#va; $xx++)
                {
                    $new_hr->{$va[$xx]} = $fields[$xx];
                    # print "$va[$xx]: $fields[$xx]\n";
                }
                push(@table, $new_hr);
            }
        }
    }
    close(IN);
}



sub sanity_check_states
{
    my $ok = 1; # Things are ok.
    my %next_states;

    # Capture non-empty states.
    foreach my $hr (@table)
    {
        if ($hr->{edge})
        {
            $known_states{$hr->{edge}}++;
        }
        if ($hr->{next})
        {
            $next_states{$hr->{next}}++;
        }
        # jump() is a way of doing next state, so record those as well
        if ($hr->{func} =~ m/jump\((.*)\)/)
        {
            $next_states{$1}++;
        }
    }
    
    # Check for unknown states in next.
    foreach my $hr (@table)
    {
        if ($hr->{next} && ! exists($known_states{$hr->{next}}))
        {
            if  ($hr->{func} =~ m/return/)
            {
                msg("Warning: unknown state following return");
            }
            else
            {
                msg("Error: unknown state $hr->{next}");
                msg( Dumper($hr) );
                $ok = 0;
            }
        }
    }

    # Check for states which can never be reached due to no next.
    foreach my $state (keys(%known_states))
    {
        if (! exists($next_states{$state}))
        {
            msg("No next-state for: $state");
            $ok = 0;
        }
    }

    if (! $ok)
    {
        msg("Failed state table sanity check (unknown or unreachable states)");
        return 0;
    }
    return 1;
}

sub make_graph
{
    my $file = "graphviz_states.gv";
    my $out;
    if (! open($out, ">", $file))
    {
        die "Cannot open $file for output\n";
    }

    print $out 'digraph States {' . "\n"; 

    foreach my $hr (@table)
    {
        my $trans;
        if ($hr->{test} && $hr->{func})
        {
            $trans = $hr->{test} . '\n' . $hr->{func};
        }
        elsif ($hr->{test})
        {
            $trans = $hr->{test};
        }
        elsif ($hr->{func})
        {
            $trans = $hr->{func};
        }
        
        my $next = $hr->{next};
        if ($hr->{func} =~ m/^wait/)
        {
            $next = $hr->{func};
        }
        printf $out "\t\"%s\" -> \"%s\" [label=\"%s\"];\n", $hr->{edge}, $next, $trans;
    }
    
    print $out '}' . "\n";
    close($out);
    exit();
}

1;
