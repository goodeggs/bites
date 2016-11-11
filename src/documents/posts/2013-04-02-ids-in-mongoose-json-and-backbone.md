---
title: "Ids in Mongoose, JSON, and Backbone"
author: Adam Hull
tags: [Nodejs, Mongoose]
layout: post
disqus:
  shortname: goodeggsbytes
  url: "http://bytes.goodeggs.com/posts/ids-in-mongoose-json-and-backbone/"

style: |
  .ids {
    width: 100%;
    margin-bottom: 30px;
    table-layout: fixed;
  }

  .ids th:first-child {
    font-size: 160%;
    padding-bottom: 20px;
    padding-top: 30px;
    font-weight: normal;
    width: 40%;
  }

  .ids th {
    font-weight: bold;
    width: 30%;
  }
---
Mongoose adds [id sugar](http://mongoosejs.com/docs/guide.html#id) on top the default _id document attribute.  Backbone has [similar sugar](http://backbonejs.org/#Model-idAttribute), but the types don't line up.  Pushing bits between the two with a customary JSON document adds a third representation.

If you find yourself typing `vegetable.id` when you really needed `new ObjectID(vegetable.toJSON()._id)` this fancy chart might help:
<!-- more -->

<table class="ids">
  <tr><th>Mongoose</th><th>id</th><th>_id</th></tr>
  <tr><td><a href="http://mongoosejs.com/docs/api.html#document_Document-id">document</a></td><td>String</td><td>ObjectID</td></tr>
  <tr><td><a href="http://mongoosejs.com/docs/api.html#query_Query-lean">lean document</a></td><td>∅</td><td>ObjectID</td></tr>
  <tr><td><a href="http://mongoosejs.com/docs/api.html#document_Document-toJSON">document.toJSON()</a></td><td>∅</td><td>ObjectID</td></tr>

  <tr><th>JSON</th><th></th><th></th></tr>
  <tr><td><a href="http://www.json.org/">object</a></td><td>∅</td><td>String</td></tr>

  <tr><th>Backbone</th><th></th><th></th></tr>
  <tr><td><a href="http://backbonejs.org/#Model-id">model</td><td>String</td><td>∅</td></tr>
  <tr><td><a href="http://backbonejs.org/#Model-get">model.get()</td><td>∅</td><td>String</td></tr>
</table>



