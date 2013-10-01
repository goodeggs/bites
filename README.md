Bites
=====

Technical morsels

Getting Started
---------------
Install and fire up the development server

    > npm install
    > grunt dev
    
Add a new post to [src/documents/posts](https://github.com/goodeggs/bites/tree/master/src/documents/posts)

    > touch src/documents/post/YYYY-MM-DD-your-post-slug.html.md

If it's your first post, create your author page in [src/documents/authors](https://github.com/goodeggs/bites/tree/master/src/documents/authors)
    
Check it out at `http://localhost:8000/your-post-slug` or just `grunt open:preview`.  It'll regenerate when you change the source files.
    
When it looks about right

    > grunt stage
    > cd release && git diff
    
If that checks out

    > grunt release
