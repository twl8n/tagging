
### Tagging and categorization

This is a system of tags or categorization or markup based on a relational data model. Anything can be tagged
in any way, leaving it up to the end user to only do sensible things. Tags can be grouped, and items can know
their preferred tags. SQL can be used to query the resulting tags. The tagging system is fully normalized and
conforms to all the usual RDBMS rules.

The system is a web application currently using SQLite, but I tend to think of row ids and other
auto-increment as coming from a sequence (Postgres), so the examples below may be a bit contrived because
SQLite lacks sequences.

### Workflow engine

This application uses a fairly recent version of my workflow engine. The workflows are in states.dat

### Installation

You'll need SQLite, Perl, the Template Tookit Perl module, and Apache httpd (or equivalent). Copy
app_config.dist to .app_config and edit for the location of the database file. Initialize the db with
schema.sql. Apple Mac OS X users may need to set some "interesting" permissions so that the web server has
permission to use the scripts and database. I had to add myself to group _www, then

```
chmod g+w .
chmod g+w tag.db
```

On right-thinking systems with suexec and Apache UserDir and mod_userdir enabled, none of that is necessary if
you install in your public_html directory.

Once installed the URL is something like:

`
http://localhost/~mst3k/tagging/index.pl
`

My minimal .htaccess usually looks like:

```
Options ExecCGI Indexes FollowSymLinks
AddHandler cgi-script .pl

DirectoryIndex index.pl index.html
```

### Conceptual demo

Below are some examples of how the internals evolved and are evolving. In some cases multiple solutions are
posed for various issues.

Table tabletable is the structure of the tags, analogous to an ontology, or in fact nearly any structure. You
can read the encoded structure, maybe, but best to let software handle that. The code isn't ready for
arbitrary structure in tabletable.

An analagous problem has previously been solved in Deft with keystr, dcc (declare control column), desc
(declare explicit structure column) and the concept is the same here. See runtlib.pl in the Deft repo.

See Documents/tagging.odb

table vocabulary

| id | tag          | type | notes                            |
|----+--------------+------+----------------------------------|
|  1 | core         |    1 |                                  |
|  2 | language     |    1 |                                  |
|  3 | noun-tag     |    1 | See 42 verb-tag                  |
|  4 | category     |    1 | How different from id 3?         |
|  5 | length       |    3 |                                  |
|  6 | eng          |    2 |                                  |
|  7 | fre          |    2 |                                  |
|  8 | ger          |    2 |                                  |
|  9 | width        |    3 | has width                        |
| 10 | tool         |    4 | tool                             |
| 11 | person       |    4 | person                           |
| 12 | car          |    4 | car                              |
| 13 | vehicle      |    4 | vehicle                          |
| 14 | mars rover   |    4 | mars rover                       |
| 20 | name         |    3 | name                             |
| 21 | dimension    |    3 | grouping fk to group.group       |
| 22 | xlength      |   21 | no! Avoid self join              |
| 23 | xwidth       |   21 | no! problems by moving           |
| 24 | xheight      |   21 | no! groups-type tags to          |
| 25 | xdiagnonal   |   21 | no! tabletable.                  |
| 26 | width        |    3 | has width (duplicates id 9)      |
| 27 | height       |    3 | has height                       |
| 28 | diagonal     |    3 | has diagonal length              |
| 29 | latitide     |    3 | place (type 34?)                 |
| 30 | longitude    |    3 | place (type 34?)                 |
| 31 | place_uri    |    3 | place (type 34?)                 |
| 32 | place_name   |    3 | place (type 34?)                 |
| 33 | country_code |    3 | place (type 34?)                 |
| 34 | place        |   46 | group-type                       |
| 36 | tabletable   |    1 | tabletable type, for structured  |
| 38 | visited      |   42 | visited                          |
| 40 | ultraviolet  |    3 | ultraviolet as a noun            |
| 42 | verb-tag     |    1 | See 2 noun-tag                   |
| 43 | sees         |   42 | is able to visually distinguish  |
| 44 | has-a        |   42 | or has                           |
| 45 | is-a         |   42 |                                  |
| 46 | group-tag    |    1 | type for tags over in tabletable |
| 49 | unit         |    1 | core unit type                   |
| 50 | meter        |   50 | unit-type                        |

After much discussion with Noah, we have concluded that combining table vocab and tabletable is a bad
idea. Adding a column to vocab would enable tags and arbitrary complexity. Even though self joins work, and
might not be too horrible, they won't scale well. Or at least they might not scale well and their only chance
of scaling well is for Postgres or which ever database to be very clever. Better to just have two tables. Thus
rows 22 through 15 are wrong.

Also decided is that tags are singletons, and it is up to the user to combine them. Verb-ish tags can be a
core category, but are simply tags. Noun-ish tags are another core category, but are also simply tags.

Still undecided is values that go with tags. Noah says tag and value is simply a tag. It is unclear how
numerical or string values can be a controlled vocabulary without the database exploding. The discriminating
quality and rules that govern value vs tag has not yet been clarified.

Is there a group description vs a group instance? (Group instance is group_tag.) Group 35 describes a
place. Where is the data for a place instance stored? (Answer: table group_tag.) Once we have group, why is a
singleton tag not a group with a singleton member? (Answer: only because singletons are simpler, and don't
need group complexity. However, notice that table vocabulary could be tabletable by adding column "group".)

What is the relationship between a singleton longitude and place:longitude? They are the same number and
units, but one is a singleton and the other only exists in a group. The label and description can be the same,
so they could be from the same vocabulary.

table tabletable aka group aka group-link

| group | member | note             |
|-------+--------+------------------|
|    21 |      5 | dimension:length |
|    21 |     26 | dimension:width  |
|    21 |     27 | dimension:height |
|    35 |     29 | place:lat        |
|    35 |     30 | place:lon        |
|    35 |     31 | place:uri        |
|    35 |     32 | place:name       |
|    35 |     33 | place:c_code     |

It appears that all group type are noun-ish, but I don't see any computational reason why verb-ish tags
couldn't be group-type as well. (The groups don't have is-a or has-a qualities.) If there are verb-ish group
types, we probably need a new core type for them.

tabletable is a linking table between types of tags. The simple, original use is link group-tag types with
noun-tag types creating group tags.


table group_tag aka group_vocab

| id | group | member | number | unit | value               | note         |
|----+-------+--------+--------+------+---------------------+--------------|
| 39 |    35 |     29 |    127 |      |                     | lat          |
| 39 |    35 |     30 |     45 |      |                     | lon          |
| 39 |    35 |     31 |        |      | http://foo.org/1234 | uri          |
| 39 |    35 |     32 |        |      | Isle Dulce          | name         |
| 39 |    35 |     33 |        |      | exm                 | country code |


group_tag.id = tag.group_tag_fk

Like tag, but the tags are groups from tabletable. This is a controlled vocabulary table, but consists of
groups of tag with values. It is unclear why it is ok to have controlled values here, but table tag below has
values for each tag instance as applied to a thing.

We could have per-instance values in group_tag. However, in order to have a controlled group_vocab, at least
part of this table must be controlled values.

By putting all tags into tabletable and singletons are just groups of one, then all tagging can go into
group_tag, and table tag would be dropped.


table item aka thing

| id | name  | note                        |
|----+-------+-----------------------------|
| 17 | drill | electric drill retail item  |
| 18 | dog   | a specific companion animal |
| 19 | rover | a specific mars rover       |


table tag

| id | item_fk | vocab_fk     | vocab_fk | vterm      | numeric | unit  | value       | group_tag_fk | note                                         |
|    |         | verb-ish     | noun-ish |            |         |       |             |              |                                              |
|    |         | tag          |      tag |            |         |       |             |              |                                              |
|----+---------+--------------+----------+------------+---------+-------+-------------+--------------+----------------------------------------------|
| 21 |      17 | 45 (is-a)    |       10 | tool       |         |       |             |              | a drill is a tool                            |
| 22 |      18 | 44 (has-a)   |       20 | name       |         |       | Daisy       |              | the actual dog Daisy                         |
| 26 |      18 | 44           |       20 | name       |         |       | Little Poo  |              | Daisy alt name                               |
| 37 |      18 | 38 (visited) |       38 | visited    |         |       |             |           39 | Daisy visited this place, fk to group_tag.id |
| 23 |      19 | 45 (is-a)    |       14 | mars rover |         |       |             |              | Opportunity is-a mars rover                  |
| 24 |      19 | 44 (has-a)   |       20 | name       |         |       | Opportunity |              | Opportunity has name ...                     |
| 25 |      19 | 44 (has-a)   |        5 | length     |       3 | meter |             |              | Opportunity is 3 meters long                 |
| 51 |      19 | 47 (mtag.id) |          |            |       3 |       |             |              | Opp. has length meters 3                  |

Q: Seems like we could put date and date range in this table, but then date would not be universal to all
tables.
A: Add column group_tag_fk and put groupish tags over in table group_tag, with an fk here. Table tabletable
becomes a more complex vocabulary. Ask Noah if tabletable and group_tag is the "multivalued column" he was
talking about.

Perhaps all tags could be done via a linking table where there are N tags combined and every tag is
potentially a group. has-length-meters is 3 tags. Unclear where the value goes, but it goes somewhere.

table mtag aka multitag

| id | item_fk | mtag_fk | value | note                              |
|----+---------+---------+-------+-----------------------------------|
| 47 |      19 |      48 |     3 | mars rover has length in meters 3 |


table sentence aka mtag link


| id | tag | note   |
|----+-----+--------|
| 48 |  44 | has    |
| 48 |   5 | length |
| 48 |  50 | meter  |


table tag or see multitag above with column value.
What happens when there are multiple values per mtag? 


| id | item_fk | mtag_fk      | value | note                         |
|----+---------+--------------+-------+------------------------------|
| 51 |      19 | 47 (mtag.id) |     3 | Opp. has length meters 3     |



table hierarchy_sort
fkid=vocabulary.id
group uses same id sequence as all record ids


| fkid | key   | group | note                                           |
|------+-------+-------+------------------------------------------------|
|   11 | ata   |    15 | car is a type of vehicle                       |
|   12 | a     |    15 | vehicle is root                                |
|   13 | ataa  |    15 | rover is a type of vehicle and sorts after car |
|   11 | ata   |    16 | car is a type of vehicle                       |
|   12 | a     |    16 | vehicle is root                                |
|   13 | atata |    16 | mars rover is a type of car                    |


date_link
fk=hierarchy.group
fk=tag.id


| fk | from | to      |                                    |
|----+------+---------+------------------------------------|
| 15 | 1999 | 2010    | older hierarchy                    |
| 16 | 2010 | present | newer hierarchy                    |
| 22 | 2003 | present | Daisy named this since birth       |
| 26 | 2015 | present | Daisy new alt name since last year |

### Imputed data structures via Church encoding.

Imagine two columns. One column is data. The second column is an encoding of structure of the first. Church
encoding is handy for creating the second structure column. The methods below have the advantage that nodes
can always be inserted between any two nodes. 

The number of distinct letters is determined by the degree of complexity necessary in resulting data
structures. A simple sort with insert-ability can be represented by 3 letters.

a peer
t sub
g tween

2^n+1 chars

a  super ordinate peer

g  sub ordinate peer

tc sub order

? What is the rule for using "t" vs "tc"?

e cap aka tween, >a >c <t <g Use this after creating the data, before sorting. (Or can the list be built with
  the cap, as long as all insert operations ignore (remove) the cap?)

h  [ct]+ root: >g and <t 

b  [ag]+ root: >a and <c

This regex will match any valid encoding: ^b[ag]*(?:h[ct]*b[cg]*)*d$

a
 \
  ag
   |
  agg -  aggcc -  aggc    -    aggctc   -    aggctt
               |               \
             aggca           aggctcc - aggctc - aggct - aggctt
                                                  \
                                                 aggcta  

  a
  |
  ag
   |
  agg - aggcc -  aggc    -    aggctc   -    aggctt
                  |               |
                 aggca           aggctcc                                                              + aggctc - aggct - aggctt
                                   |                                                                               \
                                 aggctcca - aggctccat - aggctccatt                                                 aggcta  
                                                |
                                             aggctccata

  a
  |
  ag
   |
  agg - aggcc -  aggc    -    aggctc   -    aggctt
                  |              |
                 aggca        aggctcc 
                                   |
                                 aggctcca - aggctccat - aggctccatt
                                                |
                                             aggctccata



So strings of 't' or 'c', /[ct]+/, refer to an ordered set of subordinate groups to the node referred to by
cutting the string before the beginning of a ct section, s/[ag]+([ct]+[ag]+){$nn}[ct].*// where $nn =
{0,1,2..} refers to the number of intervening hierarchies in the system. 

left: c
right: t

(Editied for 'c' first.) All subordinate groups start with member 'c' and each subsequent member is placed into the tree by building a
unique string according to the rule first=='c' second=='t' (where first is the parent entity, or more important)

This gets complicated with peer groups at multiple hierarchical levels but for simple examples I think it aids
clarity.

Explain: ... also [ag]+ strings must start with 'g', same reason.

Also I would say capped sorted and imputed
ad
	agd
	aggd
	aggtcd
	aggtd


ad
agd
aggd
aggtcd
aggtd

