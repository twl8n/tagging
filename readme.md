
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

`
chmod g+w .
chmod g+w tag.db
`
