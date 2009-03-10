---
layout: default
title: Sinatra-REST
---

# What is it?

Actually it's a set of templates to introduce [RESTful](http://en.wikipedia.org/wiki/Representational_State_Transfer) 
routes into [Sinatra](http://www.sinatrarb.com/). The only thing for you to do is to provide the views.


# Installation

Guess what!

    sudo gem source --add http://gems.github.com
    sudo gem install blindgaenger-sinatra-rest


# Usage

Of course you need to require the gem in your sinatra application:

    require 'sinatra'
    require 'sinatra/rest'

It's very similar to defining routes in Sinatra (`get`, `post`, ...). But this 
time you don't define the routes by yourself, but use the model's name for 
convention.

For example, if the model's class is called `Person` you only need to add this 
line:

    rest Person

Which will add the following RESTful routes to your application. (Note the 
pluralization of `Person` to the `/people/*` routes.)

<table>
  <thead>
    <tr>
      <th>Verb</th>
      <th>Route</th>        
      <th>Controller</th>
      <th>View</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>GET</td>
      <td>/people</td>
      <td>index</td>
      <td>/people/index.haml</td>
    </tr>
    <tr>
      <td>GET</td>
      <td>/people/new</td>
      <td>new</td>
      <td>/people/new.haml</td>
    </tr>
    <tr>
      <td>POST</td>
      <td>/people</td>
      <td>create</td>
      <td>&rarr; redirect to show</td>
    </tr>
    <tr>
      <td>GET</td>
      <td>/people/1</td>
      <td>show</td>
      <td>/people/show.haml</td>
    </tr>
    <tr>
      <td>GET</td>
      <td>/people/1/edit</td>
      <td>edit</td>
      <td>/people/edit.haml</td>
    </tr>
    <tr>
      <td>PUT</td>
      <td>/people/1</td>
      <td>update</td>
      <td>&rarr; redirect to show</td>
    </tr>
    <tr>
      <td>DELETE</td>
      <td>/people/1</td>
      <td>destroy</td>
      <td>&rarr; redirect to index</td>
    </tr>
  </tbody>
</table>

As you can see, each route is also associated with a named code block in the 
controller. The controller does the minimum to make the routes work. Based on 
the route it treates the model and redirects or renders the expected view.

So imagine the following steps to show a single person:

1. request from the client's browser<br/>
   `GET http://localhost:4567/people/99`
2. Find and set `@person` in the controller<br/>
   `@person = Person.find_by_id(99)`
3. render the view to show `@person`<br/>
   `render VIEW_DIR/people/show.haml`

It's up to you to provide the views, because this goes beyond the restful 
routing. The variable `@person` is correctly named and injected into the view. 
So maybe you'd like to do something like this:

    <html>
    <body>
      <div>ID: <%= @person.id %></div>
      <div>Name: <%= @person.name %></div>
    </body>
    </html>

That's it!


# Contact

You can contact me via mail at blindgaenger at gmail dot com, or leave me a 
message on my [Github profile](http://github.com/blindgaenger).



