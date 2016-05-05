
-- Simple, works
-- insert into seq values (1);
-- update seq set id=id+1;

-- Weird, too complicated
-- insert into seq values (null); select max(rowid) from seq;
-- delete from seq where rowid < (select max(rowid) from seq);

create table seq (
        id integer primary key autoincrement
);

insert into seq values (1);

create table vocab (
        id integer primary key autoincrement,
        term text, -- controlled list of terms
        type text -- tag, unit, catagory; also controlled
        );

-- core id and type are both 1 since the "type" of core is "core".
-- Remember: the type is the vocab.id of the type's term.
insert into vocab values ((select max(id) from seq), 'core', (select max(id) from seq));
update seq set id=id+1;

create table tag_value (
        id integer primary key autoincrement,
        value text, 
        note text
        );

-- table sentence not necessary if column item_fk exists in tabletable.
create table tabletable (
        item_fk integer, -- fk to item
        tag_fk integer, -- fk to tag_value.id
        arg_fk integer, -- fk to tag_value.id
        sentence_fk integer,
        note text
        );

-- The "things" we're tagging. The tags are linked back to this table via tag.item_fk=item.id
create table item (
        id integer primary key autoincrement,
        name text,
        note text
);

insert into item values ((select max(id) from seq), 'drill');
update seq set id=id+1;

-- link table item to vocab, with instance specific values
-- length: 10, cm; color: blue; material: wood; material: metal;
-- size: 10 "mens us";
-- size: 10 "metric";
-- values are/can be vocab also?

create table tag (
        id       integer primary key autoincrement,
        item_fk    integer, -- fk to item.id
        vocab_fk   integer, -- fk to vocab.id
        numeric    float,   -- optional numeric value
        unit       text,    -- optional unit for numeric
        value      text,    -- optional text value
        related_fk integer, -- fk to item.id of the related item
        note       text
);

-- Tag vocab that applies to a given item type. Linking list category to vocab
-- category:vocab
-- drill:weight
-- drill:horsepower
-- book:npage
-- book:nillustration

create table ok_vocab (
        id          integer, -- Why do we need this?
        category_fk integer,
        vocab_fk    integer,
        can_repeat  integer -- 0 or 1 can this tag repeat
);


-- Should controlled vocab within this table use a numeric fk? tag=23, category=24, unit=25?

-- The first vocab entry is reserved for the core types
-- insert into vocab values (1, 'core', 1);
-- insert into vocab values (2, 'length', 'tag');
-- insert into vocab values (3, 'width', 'tag');
-- insert into vocab values (4, 'size', 'tag');
-- insert into vocab values (5, 'book', 'category');
-- insert into vocab values (6, 'tool', 'category');
-- insert into vocab values (7, 'corded tool', 'category');
-- insert into vocab values (8, 'hand tool', 'category');
-- insert into vocab values (9, 'paperback', 'category');
-- insert into vocab values (10, 'drill', 'category');
-- insert into vocab values (11, 'centimeter', 'unit');
-- insert into vocab values (12, 'inch', 'unit');
-- insert into vocab values (13, 'millimeter', 'unit');
-- insert into vocab values (14, 'pound', 'unit');
-- insert into vocab values (15, 'kilogram', 'unit');
-- insert into vocab values (16, 'foot', 'unit');
-- insert into vocab values (22, 'weight', 'tag');
-- insert into vocab values (23, 'type', 'tag');
-- insert into vocab values (24, 'type', 'category');
-- insert into vocab values (25, 'type', 'unit');
-- insert into vocab values (26, 'type', 'language');
-- insert into vocab values (27, 'name', 'tag');
-- insert into vocab values (28, 'animal', 'category');

-- insert into item values (17, 'drill');
-- insert into item values (18, 'George Washington');
-- insert into item values (19, 'dog');
-- insert into item values (20, 'gravity');
-- insert into item values (21, 'Titanic');

-- insert into tag values ((select max(id) from seq), 17, 7, null, null, null); -- drill, corded tool
-- update seq set id=id+1;
-- insert into tag values ((select max(id) from seq), 17, 2, 12, 12, null); -- drill, length, 12, inches
-- update seq set id=id+1;
-- insert into tag values ((select max(id) from seq), 19, 22, 13, 14, null); -- dog, weight 13, pounds
-- update seq set id=id+1;
-- insert into tag values ((select max(id) from seq), 19, 27, null, null, 'Daisy'); -- dog, name, Daisy
-- update seq set id=id+1;

-- select 
-- id, 
-- (select name||'('|| item_fk ||')' from item where item.id=tag.item_fk) as item,
-- (select term from vocab where vocab.id=tag.vocab_fk) as tag,
-- (select vocab.term||' '||tag.numeric from vocab where vocab.id=tag.vocab_fk) as xx,
-- (select term from vocab where vocab.id=tag.unit) as unit,
-- value
-- from tag;


-- insert into ok_vocab values ((select max(id) from seq), 7, 2, 0); -- corded tool, length
-- update seq set id=id+1;
-- insert into ok_vocab values ((select max(id) from seq), 7, 3, 0); -- corded tool, width
-- update seq set id=id+1;
-- insert into ok_vocab values ((select max(id) from seq), 7, 22, 0); -- corded tool, weight
-- update seq set id=id+1;
-- insert into ok_vocab values ((select max(id) from seq), 28, 22, 0); -- animal, weight
-- update seq set id=id+1;
-- insert into ok_vocab values ((select max(id) from seq), 28, 27, 0); -- animal, name
-- update seq set id=id+1;


-- Move this to vocab.type='category'
-- Nouns, as far as I can tell. Is there a reason we can't have multiple categories?  Item type, or category
-- of item.
-- 
-- book, car, power drill, hand tool,  battery, etc.
-- create table category (
--         id integer,
--         term text
-- );
