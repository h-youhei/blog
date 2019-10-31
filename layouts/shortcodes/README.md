# Shortcodes
## table
convert csv to html table

### positional parameter
example<br>
table "sample.csv"

The parameter is path to a csv file to convert relative to the markdown file that call this shortcode.

### named parameters
example<br>
table file="sample.csv" caption="test" v="t"

parameters<br>
file<br>
path to a csv file to convert relative to the markdown file that call this shortcode.

caption<br>
table caption

sep<br>
default ","<br>
csv separator

v<br>
default "false"<br>
vertical header

h<br>
default "true"<br>
horizontal header

