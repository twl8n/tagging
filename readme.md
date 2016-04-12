
### Are tags sentences?

Are lists sentences? Markup tags work well as lists:

(thing (id 456) ((weight (pounds 5)) (place richmond) (date 2003)))

"In Richmond, in 2003 weight was 5 pounds."

Declarative sentences appear to be alternate forms of lists. 

Pete aka Peter aka Paco is the father of john, and was born in 1945 in Ohio.

(thing (id 1234) (father-of john) (birth (date 1945) (place ohio)) (name pete) (name peter) (name paco))

"I want to purchase 500 things."

(me (desire (purchase (things 500))))

These two examples are still unclear:

My classic: The ball is behind the red door.

(door (behind ball) (color red))
(door (behind-self ball) (color red)) 
(door (furthest (ball (location (behind door)))) (color red))
;; This might be best:
(door (ball (location (behind door))) (color red))
(door (things-in-front-of-self null) (things-behind-self ball) (color red))

As opposed to: Behind the red ball is the door.

(ball (color red) (behind door))

### Tagging demo

todo: See what happens if table tabletable is broken into two tables (in the tagging demo list section below).

Imagine tagging the dog, Daisy. 

Lists work much better due to less ambiguity based on grouping aka association and explicit binding of tags to
other tags. There seems to be no need for "and" or "or". I can't tell the difference between "date or date"
and "date and date". "Or" may imply "uncertainty", but uncertainty is a broad, nuanced concept not quite
captured by "or".

todo: See what happens if table tabletable is broken into two tables (in the tagging demo list section below).

(owner charlotte (date 2003) (date 2002))
(name daisy (date 2002) (date 2015))
(name 'little pooh' (date 2015))
(weight (pounds 5) (place richmond (date 2003)))
(birth (date 2002) (owner charlotte) (weight (pounds 0.5)))

table "tag_value" (must be a vocabulary tag with unique row id tag_value.id implied)

| id       | value       | note |
|----------+-------------+------|
| name-1   | daisy       |      |
| name-2   | little pooh |      |
| pounds-1 | 5           |      |
| place-1  | richmond    |      |
| owner-1  | charlotte   |      |
| date-1   | 2002        |      |
| date-2   | 2015        |      |
| date-3   | 2003        |      |
| owner-2  | abby        |      |
| pounds-2 | 0.5         |      |
| weight-1 |             |      |
| weight-2 |             |      |
| birth-1  |             |      |

table tabletable (Both id columns must be fk to tag_value) Can this table be broken into two tables? Notice
the repeats in the first column. However, remember that both id columns are fks, not data.

| id       | id       | sentence | note |
|----------+----------+----------+------|
| owner-1  | date-3   |        1 |      |
| owner-1  | date-1   |        1 |      |
| name-1   | date-1   |        2 |      |
| name-1   | date-2   |        2 |      |
| name-2   | date-2   |        3 |      |
| weight-2 | pounds-1 |        4 |      |
| weight-2 | place-1  |        4 |      |
| place-1  | date-3   |        4 |      |
| birth-1  | date-1   |        5 |      |
| birth-1  | owner-1  |        5 |      |
| birth-1  | weight-1 |        5 |      |
| weight-1 | pounds-2 |        5 |      |

table item

| item_fk | sentence | note |
|---------+----------+------|
| daisy   |        1 |      |
| daisy   |        2 |      |
| daisy   |        3 |      |
| daisy   |        4 |      |
| daisy   |        5 |      |
|         |          |      |
|         |          |      |
|         |          |      |
|         |          |      |
|         |          |      |


Older thoughts:

Kind of name:value tags. These are more ambiguous and overall less satisfying than the lists above.

owner:charlotte and (date:2003 or date:2002)
name:daisy and (date:2002 or date:2015)
name:little pooh and date:2015
(weight-unit:pounds and weight-value:5) and place:richmond and date:2003
birth: and date:2002 and owner:charlotte and (weight-unit:pounds and weight-value:0.5)

I'm leaning towards "and" for all relationships, and queries can allow alternation (or), similar to strings
which a not uncertain, but you can still use alternation in a regex against a string.



The work below is older than the list system above.

Born in 2002 in Richmond. Owned by Charlotte. Weighing 0.5 pounds. Etc. Below
are some example "sentences". There are a few rules. Some tags have a required value. Some tags have required
"and" tags. Some tags are exclusive for "and" (multiple "and" instances not allowed, such as date, weight). 

Some tags are exclusive-and aka multi-not-ok which means they are exclusive: place, date(?), birth,
weight. You can't be in two places at the same time. Some things cannot be true at two different times. You
can't be born twice. You only have a single weight. 

Some tags are multi-ok which means they can and with self. For example: owner, name.

Q: Can you be in two places if there is no date specified? (Yes, but birth: with two places is non-sense.)

Q: Does the computer system care about nonsense? Some obvious nonsense can be prevented by having a rule
system.

Q: What is the meaning of "or"? Is it "can match either value in a WHERE clause"?

Q: How to encode () parenthesis grouping in the db?

Q: Is the meaning of "and" "must satisfy all these constraints when matching a WHERE clause"?

Q: How can SQL handle multi-value matches such as date:2002 and date:2003?

Wrong due to multiple exclusive weight values, can't "and" multiple weights:
(weight-unit:pounds and weight-value:5) and place:richmond and date:2003 and (weight-unit:kg and weight-value:0.8)

Ok, uncertainty about weight:
((weight-unit:pounds and weight-value:5) or ( weight-unit:kg and weight-value:0.8)) and place:richmond and date:2003 

?Wrong, something can't happen simultaneously at two different times:
owner:charlotte and (date:2003 and date:2002)

weight: requires tag:value
date: requires value
owner: requires value
name: requires value
place: requires value(s)

| id           | tag/value   | note               |
|--------------+-------------+--------------------|
| name-1       | daisy       | daisy name-1 value |
| name-2       | little pooh | name-2 value       |
| weight-unit  | pounds      |                    |
| weight-value | 13          |                    |
| place        | richmond    |                    |
| owner        | charlotte   |                    |
| date-1       | 2002        |                    |
| date-2       | 2015        |                    |
| owner-2      | abby        |                    |

| id     | and | id      |
|--------+-----+---------|
| name-1 |     | place-1 |
| name-1 |     | date-1  |
| name-1 |     | owner-1 |
| name-2 |     | date-2  |
| date-2 |     | owner-2 |
| date-2 |     | weight  |
| birth  |     | date-1  |

| id     | op  | id      | rowid | sentence |
|--------+-----+---------+-------+----------|
| name-1 | and | place-1 |     1 |        1 |
| name-1 | and | date-1  |     2 |        1 |
| name-1 | and | owner-1 |     3 |        1 |
| name-2 | and | date-2  |     4 |        2 |
| date-2 | and | owner-2 |     5 |        2 |
| date-2 | and | weight  |     6 |        2 |
| birth  | and | date-1  |     7 |        3 |
| date-1 | or  | date-2  |     8 |          |
| name-1 | and | row-8   |     9 |        5 |


| item_fk | group | tag     | note           |
|---------+-------+---------+----------------|
| daisy   |    21 | name-1  | daisy name     |
| daisy   |    21 | name-2  | daisy alt name |
| daisy   |    21 | weight  | daisy weight   |
| daisy   |    21 | dog     | daisy is a dog |
| daisy   |    21 | place-1 |                |
|         |       | owner-1 |                |
|         |       | date-1  |                |
|         |       | date-2  |                |
|         |       | owner-2 |                |
|         |       | birth   |                |


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

| id | tag          | type | notes                               |
|----+--------------+------+-------------------------------------|
|  1 | core         |    1 |                                     |
|  2 | language     |    1 |                                     |
|  3 | noun-tag     |    1 | See 42 verb-tag                     |
|  4 | category     |    1 | How different from id 3?            |
|  5 | length       |    8 | measured-type                       |
|  6 | eng          |    2 |                                     |
|  7 | fre          |    2 |                                     |
|  8 | measured     |    1 | core measured, has a value and unit |
|  9 | width        |    8 | measured-type                       |
| 10 | tool         |    4 | tool                                |
| 11 | person       |    4 | person                              |
| 12 | car          |    4 | car                                 |
| 13 | vehicle      |    4 | vehicle                             |
| 14 | mars rover   |    4 | mars rover                          |
| 20 | name         |    3 | name                                |
| 21 | dimension    |    3 | grouping fk to group.group          |
| 22 | xlength      |   21 | no! Avoid self join                 |
| 23 | xwidth       |   21 | no! problems by moving              |
| 24 | xheight      |   21 | no! groups-type tags to             |
| 25 | xdiagnonal   |   21 | no! tabletable.                     |
| 26 | width        |    3 | has width (duplicates id 9)         |
| 27 | height       |    8 | measured-type                       |
| 28 | diagonal     |    8 | measured-type                       |
| 29 | latitide     |    8 | measured-type, place (type 34?)     |
| 30 | longitude    |    8 | measured-type, place (type 34?)     |
| 31 | place_uri    |    3 | place (type 34?)                    |
| 32 | place_name   |    3 | place (type 34?)                    |
| 33 | country_code |    3 | place (type 34?)                    |
| 34 | place        |   46 | group-type                          |
| 36 | tabletable   |    1 | tabletable type, for structured     |
| 38 | visited      |   42 | visited                             |
| 40 | ultraviolet  |    3 | ultraviolet as a noun               |
| 42 | verb-tag     |    1 | See 2 noun-tag                      |
| 43 | sees         |   42 | is able to visually distinguish     |
| 44 | has-a        |   42 | or has                              |
| 45 | is-a         |   42 |                                     |
| 46 | group-tag    |    1 | type for tags over in tabletable    |
| 49 | unit         |    1 | core unit type, all have values     |
| 50 | meter        |   49 | unit-type                           |
| 53 | degree       |   49 | unit-type                           |
| 54 | weight       |    8 | measured-type                       |
| 55 | pound        |   49 |                                     |
| 56 | dog          |    3 | (is-a) dog                          |

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

table tabletable with singletons and values

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
|    51 |     26 | width, singleton |
|    51 |     50 | width, meter     |



Organizational depth
1) birth, weight name, owner
2) date, pounds, kilograms, place

daisy:
    dog:
    weight: 
        pounds: 13
        kilograms: 5.9
    weight: pounds: 13, kilograms: 5.9
    5.9: kilograms, pounds: 13, weight
    5.9: pounds, kilograms: weight: 13 (wrong!)
    weight:
        date: 2003
        pounds: 5
    weight: 
      |   |
      |   5:pounds or pounds:5 (commutative)
      |   
      date:2003 or 2003:date (commutative)

    (weight:pounds:5) and (date:2003) and (place:richmond) and (owner:charlotte) [ok, but all these are 'and']


    (weight: (pounds:5))
    (weight: ) and (date:2003) [Wrong, missing required unit:value]
    (weight: (place:richmond)) [Wrong, missing required unit:value]
    (weight: (owner:charlotte)) [Wrong, missing required unit:value]

    (weight:pounds:5) and (place:richmond) and (date:2003)
    (date:2003) and (owner:charlotte)

    select * from self where weight=5pounds; [ok, but not very sensible]
    (weight: pounds:5 and date:2003 and place:richmond and owner:charlotte) 

    select * from self where date=2003;
    (weight: pounds:5 date:2003)
    (owner:charlotte date:2003)
    (place:richmond date:2003)
    (place:richmond date:2002

    (place: richmond owner:charlottesville)

    (place: richmond birth:)
    
    select * from self where place:richmond
    (birth: and date:2002 and owner:charlotte and weight:pounds:0.5)
    (date:2003 and owner:charlotte and weight:pounds:5)

    (birth: date: 2002) [can only have a date, cannot have anything else, cannot have a place]
    (place:richmond date:2002) [link to birth, but not attribute of birth]
    (weight: pounds:0.5 date:2002) [link this to birth, but not attribute of birth]

    (date:2002 birth: place:richmond weight:pounds:5) [ok, all have date:2002 in common]

    date: birth: 2002 [wrong, date has required value]
    birth: and (date: 2002)
    2002: birth: date: [wrong, value "2002" is not a tag, date is missing required value]
    name: daisy
    name: little pooh and date:2015
    owner: abby
    owner: tom
    owner: charlotte  and date:2003 and date:2002

table group_tag aka group tag instance, group_tag.id = tag.group_tag_fk
(Linking table between tabletable and tag, instances of tabletable linked to table tag)

| id | group | member | value               | unit | note               |
|----+-------+--------+---------------------+------+--------------------|
| 39 |    35 |     29 | 127                 | 53   | lat, degrees       |
| 39 |    35 |     30 | 45                  | 53   | lon, degrees       |
| 39 |    35 |     31 | http://foo.org/1234 |      | uri                |
| 39 |    35 |     32 | Isle Dulce          |      | name               |
| 39 |    35 |     33 | idl                 |      | country code       |
| 54 |    51 |     26 |                     | na   | length (awkward)   |
| 54 |    51 |     50 | 3                   | na   | 3 meters (awkward) |


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

| id | item_fk | vocab_fk     | vocab_fk | vterm      | value       | unit  | group_tag_fk | note                                         |
|    |         | verb-ish     | noun-ish |            |             |       |              |                                              |
|    |         | tag          |      tag |            |             |       |              |                                              |
|----+---------+--------------+----------+------------+-------------+-------+--------------+----------------------------------------------|
| 21 |      17 | 45 (is-a)    |       10 | tool       |             |       |              | a drill is a tool                            |
| 22 |      18 | 44 (has-a)   |       20 | name       | Daisy       |       |              | the actual dog Daisy                         |
| 26 |      18 | 44           |       20 | name       | Little Pooh |       |              | Daisy alt name                               |
| 37 |      18 | 38 (visited) |       38 | visited    |             |       |           39 | Daisy visited this place, fk to group_tag.id |
| 23 |      19 | 45 (is-a)    |       14 | mars rover |             |       |              | Opportunity is-a mars rover                  |
| 24 |      19 | 44 (has-a)   |       20 | name       | Opportunity |       |              | Opportunity has name ...                     |
| 25 |      19 | 44 (has-a)   |        5 | length     | 3           | meter |              | Opportunity is 3 meters long                 |
| 51 |      19 | 47 (mtag.id) |          |            | 3           |       |              | Opp. has length meters 3                     |




| id | item_fk | vocab_fk | vterm      | value       | unit  | group_tag_fk | note                                         |
|    |         | noun-ish |            |             |       |              |                                              |
|    |         |      tag |            |             |       |              |                                              |
|----+---------+----------+------------+-------------+-------+--------------+----------------------------------------------|
| 21 |      17 |       10 | tool       |             |       |              | a drill is a tool                            |
| 22 |      18 |       20 | name       | Daisy       |       |              | the actual dog Daisy                         |
| 26 |      18 |       20 | name       | Little Pooh |       |              | Daisy alt name                               |
| 37 |      18 |       38 | visited    |             |       |           39 | Daisy visited this place, fk to group_tag.id |
| 23 |      19 |       14 | mars rover |             |       |              | Opportunity (is-a) mars rover                |
| 24 |      19 |       20 | name       | Opportunity |       |              | Opportunity (has) name ...                   |
| 25 |      19 |        5 | length     | 3           | meter |              | Opportunity (is) 3 meters long               |
| 51 |      19 |        ? |            | 3           |       |            ? | Opp. (has) length meters 3                   |
| 55 |      19 |          |            |             |       |           54 | Opp. length 3 meters                         |


Q: Seems like we could put date and date range in this table, but then date would not be universal to all
tables.
A: Add column group_tag_fk and put groupish tags over in table group_tag, with an fk here. Table tabletable
becomes a more complex vocabulary. Ask Noah if tabletable and group_tag is the "multivalued column" he was
talking about.

Perhaps all tags could be done via a linking table where there are N tags combined and every tag is
potentially a group. has-length-meters is 3 tags. Unclear where the value goes, but it goes somewhere.

table tag, related to table value_unit

| id | item_fk | vocab_fk     | vocab_fk | vterm      | group_tag_fk | note                                         |
|    |         | verb-ish     | noun-ish |            |              |                                              |
|    |         | tag          |      tag |            |              |                                              |
|----+---------+--------------+----------+------------+--------------+----------------------------------------------|
| 21 |      17 | 45 (is-a)    |       10 | tool       |              | a drill is a tool                            |
| 22 |      18 | 44 (has-a)   |       20 | name       |              | the actual dog Daisy                         |
| 26 |      18 | 44           |       20 | name       |              | Daisy alt name                               |
| 37 |      18 | 38 (visited) |       38 | visited    |           39 | Daisy visited this place, fk to group_tag.id |
| 23 |      19 | 45 (is-a)    |       14 | mars rover |              | Opportunity is-a mars rover                  |
| 24 |      19 | 44 (has-a)   |       20 | name       |              | Opportunity has name ...                     |
| 25 |      19 | 44 (has-a)   |        5 | length     |              | Opportunity is 3 meters long                 |
| 51 |      19 | 47 (mtag.id) |          |            |              | Opp. has length meters 3                     |

table value_unit value_unit.tag_fk=tag.id

| tag_fk | value       | unit  | note                         |
|        |             |       |                              |
|        |             |       |                              |
|--------+-------------+-------+------------------------------|
|     22 | Daisy       |       | the actual dog Daisy, name   |
|     26 | Little Pooh |       | Daisy alt name               |
|     24 | Opportunity |       | Opportunity, name            |
|     25 | 3           | meter | Opportunity is 3 meters long |
|     51 | 3           |       | Opp. has length meters 3     |




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


### Tagging and categorization

todo: See what happens if table tabletable is broken into two tables (in the tagging demo list section below).

This is a system of tags or categorization or markup based on a relational data model. Anything can be tagged
in any way, leaving it up to the end user to only do sensible things. Tags can be grouped, and items can know
their preferred tags. SQL can be used to query the resulting tags. The tagging system is fully normalized and
conforms to all the usual RDBMS rules.

The system is a web application currently using SQLite, but I tend to think of row ids and other
auto-increment as coming from a sequence (Postgres), so the examples below may be a bit contrived because
SQLite lacks sequences.

### Workflow engine

This application uses a fairly recent version of my workflow engine. The workflows are in states.dat

