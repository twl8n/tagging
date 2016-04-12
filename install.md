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
