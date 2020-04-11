
create table master (
        id integer primary key autoincrement,
        vv text
);

create table tagkv (
        id integer,
        key text,
        value text,
        ref integer
);

-- The constraint is more complicated than a unique index.
-- Unless we update parent rows with their rowid in the ref col, but since rowid is unique, there's little point in that.
-- we want unique id,key,value except where value is null.
-- create unique index ndx1 on tagkv (id,key,value);

-- This needs to a CTE for the first query, unioned (and joined?) with the second query.
select (select null) parent,key,value,ref
from master,tagkv
where
    master.id=tagkv.id
union
select (select ii.key from tagkv as ii where ii.ref=oo.ref) parent,oo.key, oo.value,oo.ref
from tagkv oo
where oo.ref=1 and value is not null;

-- use of last_insert_rowid() may be less that ideally robust.
-- Can we emulate placeholders? Maybe with a spare column? Or a temp table?
begin;
insert into master (vv) values ('');
insert into tagkv values ((select max(id) from master),':color',':black',null);
insert into master (vv) values ('ref');
insert into tagkv values (1,':born',null,null);
update tagkv set ref=rowid() where id=last_insert_rowid();
insert into tagkv values (null,':city','Paris',(select max(rowid) from tagkv where id=1 and key=":born"));
insert into tagkv values (null,':state','TX',(select max(rowid) from tagkv where id=1 and key=":born"));
insert into tagkv values (1,':color',':black',null);
insert into tagkv values (1,':color',':white',null);
commit;





---------------- old -------------------
select * from big_view where name='Daisy';

create table tagkv (
        master_id integer primary key autoincrement,
        -- rowid sqlite automatic rowid 
        group_id integer,
        key text,
        ref integer,
        value text
        );

create temp table mref (id integer);
insert into mref values (0);

insert into tagkv (key,ref,value) values (':name',null,'Daisy');
insert into tagkv (key,ref,value) values (':born',last_insert_rowid(),null);
insert into tagkv (key,ref,value) values (':city',last_insert_rowid(),'Richmond');
insert into tagkv (key,ref,value) values (':state',last_insert_rowid(),'VA');


insert into tagkv (key,ref,value) values (':address',1,null);
update mref set id=last_insert_rowid();

insert into tagkv (key,ref,value) values ('',null,'Daisy');
