
### Tagging and categorization

This is a system of tags or categorization or markup based on a relational data model. Anything can be tagged
in any way, leaving it up to the end user to only do sensible things. Tags can be grouped, and items can know
their preferred tags.

The system is a web application currently using SQLite.

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

See demo.txt for some examples of how the internals evolved. It includes a section about creating imputed data
structures via Church encoding, and some commentary about table tabletable. tabletable is the structure of the
tags, analogous to an ontology. You can read the encoded structure, maybe, but best to let software handle
that. The code isn't ready for that, but we did it before in Deft with keystr, dcc (declare control column),
desc (declare explicit structure column) and the concept is the same here. See runtlib.pl in the Deft repo.

