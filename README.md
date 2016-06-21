![Cassius](logo.png)

Cassius
=======

Cassius synthesizes CSS from examples of how a website should look.
Unlike WYSIWYG tools like Dreamweaver or Photoshop,
  Cassius can generate responsive designs
  that work well even when the content or screen size change.

Installing
------------

You'll need to install Racket (6.3 or later) <http://racket-lang.org>
and Z3 <https://github.com/Z3Prover/z3> (4.3 or later). Once Racket
and Z3 are set up, edit the `z3.sh` script, to call your installation
of Z3. (Make sure to pass through all arguments.)

Test out your Cassius installation by running, from the top-level directory,

    ./cassius accept bench/introex.rkt verify

This should churn for a few seconds and say, "Accepted".

Using Cassius
----------------

Run Cassius with

    ./cassius [tool] [file] [instance]

The `./cassius` script runs Cassius. It takes four arguments: the tool
to run, the file to run on, and the example in that file. 

The currently-supported tools are:

- `smt2`: Output constraints generated by Cassius
- `render`: Render the page using a known CSS file
- `sketch`: Synthesize a CSS file from a known rendering
- `verify`: Look for counterexamples to a property
- `debug`: Print out CSS properties responsible for measurement

For example, to run the the `smt2` tool, run:

    ./cassius smt2 bench/introex.rkt sketch > /tmp/out.z3

This puts a file with all the generated constraints into
`/tmp/out.z3`.

Collecting Examples
-----------------------

You can collect examples to run Cassius on from Firefox. If you have
Firefox and the Selenium packages for Python installed, you can run

    python2 get_bench.py URL

to run Firefox on the URL in question and dump the resulting layout
into a file somewhere in `bench/`.

Current Status
--------------

Cassius currently supports a fragment of CSS 2.1:
+ Widths, padding, and margins, including `auto` margins
+ Margin collapsing
+ Floats
+ Percentage margins, widths, or padding
+ Borders
+ Some positioning
+ A few miscellaneous properties, like `box-sizing`.

Cassius development is tracked
[on Trello](https://trello.com/b/ylAVgJh3/cassius). Email
[Pavel Panchekha](mailto:me@pavpanchekha.com) to be added to the
project.
