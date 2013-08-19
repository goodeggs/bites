Bites
=====

Technical morsels

Getting Started
---------------
Install and fire up the development server

    > npm install
    > grunt dev
    
Add a new post to [src/documents](https://github.com/goodeggs/bites/tree/master/src/documents)

    > touch src/documents/YYYY-MM-DD-your-post-slug.html.md 
    
Check it out at `http://localhost:8000/your-post-slug` or just `grunt open:preview`.  It'll regenerate when you change the source files.
    
When it looks about right

    > grunt stage
    > cd release && git diff
    
If that checks out

    > grunt release
