A script that generates a list of names that used to be popular in among US births and has fallen in popularity.

`unzip names.zip`
`bundle`
update `.select { |row| row[1] == 'F' }` to be `F` or `M`
update `if year <= 1935` to be the last year you're looking for old peak popularity
update `if year > 1965` to be the first year you're looking for new peak popularity
`bundle exec ruby countercyclicalnames.rb`
