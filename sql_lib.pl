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
    (select name from item where tag.item_fk=item.id) as item_name,
    (select name from item where tag.related_fk=item.id) as related_name
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
    my $sql="select * from item order by lower(name)";
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

# Select tags and relations.

sub sql_select_tag
{
    my $vocab_fk = $_[0];
    my $sql="select * from vocab where type in (select id from vocab where term='tag' or term='relation') order by term";
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

# Thing is the item.term aka item name
sub sql_add_tag
{
    my %arg = @_;
    my $vocab_fk =$arg{tag};
    my $thing = $arg{thing};
    my $numeric = $arg{numeric};
    my $unit = $arg{unit};
    my $value = $arg{value};
    my $note = $arg{note};
    my $item_fk = $arg{item_fk};
    my $related_fk = $arg{related_fk};

    if (! $item_fk)
    {
        if ($thing)
        {
            $item_fk = sql_select_thing_id($thing);
        }
        else
        {
            msg("Cannot add a tag, no item_fk and no thing<br>");
            return;
        }
    }
    # msg("item_fk: $item_fk vocab_fk: $vocab_fk<br>");
    
    my $sql = "insert into tag (item_fk, vocab_fk, numeric, unit, value, note, related_fk) values (?,?,?,?,?,?,?)";
    my $sth = $dbh->prepare($sql);
    err_stuff($dbh, $sql, "exec", $db_name, (caller(0))[3]);

    $sth->execute($item_fk, $vocab_fk, $numeric, $unit, $value, $note, $related_fk);
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
    (select name from item where tag.item_fk=item.id) as item_name,
    (select name from item where tag.related_fk=item.id) as related_name
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


1;
