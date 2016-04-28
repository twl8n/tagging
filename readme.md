
### Are tags sentences?

Are lists sentences? Markup tags work well as lists. Declarative sentences appear to be alternate forms of
lists.

An entity in Richmond, in 2003 weighed 5 pounds.

`(entity (id 456) ((weight (pounds 5)) (place richmond) (date 2003)))`

A person, Pete aka Peter aka Paco is the father of john, and was born in 1945 in Ohio.

`(entity (id 1234) (entity-type person) (father-of john) (birth (date 1945) (place ohio)) (name pete) (name peter) (name paco))`

Some sentences are awkward: I want to purchase 500 things.

`(me (desire (purchase (things 500))))`

Prepositions become unambiguous by applying them to a "place" or "date", and moving the second noun into the
relative location argument. (I can never remember which is the subject and which is the object, but in this
grammar, the distinctions are both meaningless and unnecessary.) 

My classic: The red ball is behind the red door.

`(ball (place (behind door)) (color red))`

### Tagging demo

todo: See what happens if table tabletable is broken into two tables (in the tagging demo list section below).

Imagine tagging the dog, Daisy. 

Lists work much better than simple name:value pairs due to decreased ambiguity due to grouping aka association
and explicit binding of tags to other tags. In terms of clarity and simplicity, the best statements are flat,
and-ed lists. "Or" implies "uncertainty", but uncertainty is a broad, nuanced concept that may not be fully
expressed simply by "or".

Nesting arguments should probably be illegal. The inner nested tags do no describe the higher level tags, and
thus nesting creates statements that have convoluted meaning that humans can easily fail to
understand. Lacking a compelling reason for nesting, it is not supported.

todo: See what happens if table tabletable is broken into two tables (in the tagging demo list section below).

```
(owner charlotte (date 2003) (date 2002))
(name daisy (date 2002) (date 2015))
(name 'little pooh' (date 2015))
(weight (pounds 5) (place richmond) (date 2003))
(birth (date 2002) (owner charlotte) (weight (pounds 0.5)))
```

table "tag_value" (must be a vocabulary tag with unique row id tag_value.id implied)

| id       | value       | note |
|----------|-------------|------|
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



table tabletable Columns tag_fk, arg_fk must be fk to tag_value.id. Can this table be broken into two tables
based on repeats in the tag_fk column for a given sentence_fk? Probably not since tag_fk is a foreign key, not
data, so no data is repeated.


| item_fk | tag_fk   | arg_fk   | sentence_fk | note |
|---------|----------|----------|-------------|------|
| daisy   | owner-1  | date-3   |           1 |      |
| daisy   | owner-1  | date-1   |           1 |      |
| daisy   | name-1   | date-1   |           2 |      |
| daisy   | name-1   | date-2   |           2 |      |
| daisy   | name-2   | date-2   |           3 |      |
| daisy   | weight-2 | pounds-1 |           4 |      |
| daisy   | weight-2 | place-1  |           4 |      |
| daisy   | place-1  | date-3   |           4 |      |
| daisy   | birth-1  | date-1   |           5 |      |
| daisy   | birth-1  | owner-1  |           5 |      |
| daisy   | birth-1  | weight-1 |           5 |      |
| daisy   | weight-1 | pounds-2 |           5 |      |


table sentence not necessary if column item_fk exists in tabletable.

| item_fk | sentence    | note |
|---------|-------------|------|
| daisy   |           1 |      |
| daisy   |           2 |      |
| daisy   |           3 |      |
| daisy   |           4 |      |
| daisy   |           5 |      |
|         |             |      |
|         |             |      |
|         |             |      |
|         |             |      |
|         |             |      |



Some tags are exclusive-and aka multi-not-ok which means they are exclusive: place, date(?), birth,
weight. You can't be in two places at the same time. Some things cannot be true at two different times. You
can't be born twice. You only have a single weight. 

Some tags are multi-ok which means they can and with self. For example: owner, name.

Q: Can you be in two places if there is no date specified? (Yes, but birth: with two places is non-sense.)

Q: How can SQL handle multi-value matches such as date:2002 and date:2003?

Wrong due to multiple exclusive weight values, can't "and" multiple weights:
(weight-unit:pounds and weight-value:5) and place:richmond and date:2003 and (weight-unit:kg and weight-value:0.8)

Ok, uncertainty about weight:
((weight-unit:pounds and weight-value:5) or ( weight-unit:kg and weight-value:0.8)) and place:richmond and date:2003 

Two dates means something is true at both times, and must mean two events. Distinct events cannot be simultaneous in a
4 dimensional universe:
owner:charlotte and (date:2003 and date:2002)

weight: requires tag:value
date: requires value
owner: requires value
name: requires value
place: requires value(s)

| id           | tag/value   | note               |
|--------------|-------------|--------------------|
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
|--------|-----|---------|
| name-1 |     | place-1 |
| name-1 |     | date-1  |
| name-1 |     | owner-1 |
| name-2 |     | date-2  |
| date-2 |     | owner-2 |
| date-2 |     | weight  |
| birth  |     | date-1  |

| id     | op  | id      | rowid | sentence |
|--------|-----|---------|-------|----------|
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
|---------|-------|---------|----------------|
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

| id | tag            | type | notes                                          |
|----|----------------|------|------------------------------------------------|
|  1 | core           |    1 |                                                |
|  2 | language       |    1 |                                                |
|  3 | tag            |    1 | tag                                            |
| 21 | tag_one_arg    |    3 | tag need a value arg                           |
| 57 | tag_one_tag    |    3 | requires 1 tag arg                             |
| 22 | tag_multi_tag  |    3 | requires 1 or more tag args                    |
| 60 |                |      |                                                |
| 61 | et_value       |    4 | entity type value group category               |
|  4 | category       |    1 | How different from id 3?                       |
|  5 | length         |   57 | needs unit+value                               |
|  6 | eng            |    2 |                                                |
|  7 | fre            |    2 |                                                |
|  8 | measured       |    1 | core measured, has a value and unit            |
|  9 | width          |   57 | needs unit+value                               |
| 10 | tool           |    4 | tool                                           |
| 11 | person         |   61 | entity type value                              |
| 62 | corporate body |   61 | entity type value                              |
| 63 | family         |   61 | entity type value                              |
| 12 | car            |   13 | vehicle sub category                           |
| 13 | vehicle        |    4 | vehicle                                        |
| 14 | mars rover     |   13 | mars rover                                     |
| 20 | name           |   21 | name needs value                               |
| 23 | birth          |   22 | birth meta data                                |
| 24 | death          |   22 | death meta data                                |
| 25 | active         |   22 | active period meta data                        |
| 26 | entity_type    |   21 | tag, requires an et_value, could be type 3     |
| 27 | height         |   57 | needs unit+value                               |
| 28 | diagonal       |   57 | needs unit+value                               |
| 29 | latitide       |   57 | needs unit+value                               |
| 30 | longitude      |   57 | needs unit+value                               |
| 31 | place_uri      |    3 | place (type 34?)                               |
| 32 | place_name     |    3 | place (type 34?)                               |
| 33 | country_code   |    3 | needs value                                    |
| 34 | place          |   46 | group-type                                     |
| 36 | tabletable     |    1 | tabletable type, for structured                |
| 38 | visited        |   22 | needs place tag group                          |
| 40 | ultraviolet    |    3 | a category?                                    |
| 42 | unit           |   21 | unit needs an arg                              |
| 43 | sees           |   22 | vision meta data                               |
| 44 | angle_unit     |   42 | angle unit tag                                 |
| 45 | mass_unit      |   42 | mass unit tag                                  |
| 46 | group-tag      |    3 | type for tags over in tabletable               |
| 49 | distance_unit  |   42 | unit type tag, all need 1 arg                  |
| 50 | meter          |   49 | unit, distance                                 |
| 53 | degree         |   44 | unit, angle                                    |
| 54 | weight         |   57 | needs a tag arg (create a tag that needs mass) |
| 55 | pound          |   45 | mass unit                                      |
| 56 | dog            |    4 | value for entity type                          |
| 58 | date           |   46 | group-type date                                |
| 59 | kilogram       |   45 | mass unit                                      |
| 64 | gram           |   45 | mass unit                                      |
| 65 | stone          |   45 | mass unit                                      |
| 66 | radian         |   44 | angle unit                                     |

table required (allowed?) arg type

| id | arg | note                                |
|----|-----|-------------------------------------|
| 26 |  61 | entity_type arg from group et_value |
|  9 |  69 | width needs a distance unit arg     |
| 54 |  45 | weight needs a mass unit arg        |
| 23 |  46 | birth place                         |
| 23 |  58 | birth date                          |
| 23 |  54 | birth weight                        |

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
|-------|--------|------------------|
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
|-------|--------|------------------|
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
|----|-------|--------|---------------------|------|--------------------|
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
|----|-------|-----------------------------|
| 17 | drill | electric drill retail item  |
| 18 | dog   | a specific companion animal |
| 19 | rover | a specific mars rover       |


table tag

| id | item_fk | vocab_fk     | vocab_fk | vterm      | value       | unit  | group_tag_fk | note                                         |
|    |         | verb-ish     | noun-ish |            |             |       |              |                                              |
|    |         | tag          |      tag |            |             |       |              |                                              |
|----|---------|--------------|----------|------------|-------------|-------|--------------|----------------------------------------------|
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
|----|---------|----------|------------|-------------|-------|--------------|----------------------------------------------|
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
|----|---------|--------------|----------|------------|--------------|----------------------------------------------|
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
|--------|-------------|-------|------------------------------|
|     22 | Daisy       |       | the actual dog Daisy, name   |
|     26 | Little Pooh |       | Daisy alt name               |
|     24 | Opportunity |       | Opportunity, name            |
|     25 | 3           | meter | Opportunity is 3 meters long |
|     51 | 3           |       | Opp. has length meters 3     |




table mtag aka multitag

| id | item_fk | mtag_fk | value | note                              |
|----|---------|---------|-------|-----------------------------------|
| 47 |      19 |      48 |     3 | mars rover has length in meters 3 |


table sentence aka mtag link


| id | tag | note   |
|----|-----|--------|
| 48 |  44 | has    |
| 48 |   5 | length |
| 48 |  50 | meter  |


table tag or see multitag above with column value.
What happens when there are multiple values per mtag? 


| id | item_fk | mtag_fk      | value | note                         |
|----|---------|--------------|-------|------------------------------|
| 51 |      19 | 47 (mtag.id) |     3 | Opp. has length meters 3     |



table hierarchy_sort
fkid=vocabulary.id
group uses same id sequence as all record ids


| fkid | key   | group | note                                           |
|------|-------|-------|------------------------------------------------|
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
|----|------|---------|------------------------------------|
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

