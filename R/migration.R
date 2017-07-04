files = list.files(
  'content/', '[.](md|markdown)$', full.names = TRUE,
  recursive = TRUE
)
for (f in files) {
  blogdown:::modify_yaml(f, slug = function(old) {
    # YYYY-mm-dd-name.md -> name
    gsub('^\\d{4}-\\d{2}-\\d{2}-|[.](md|markdown)', '', f)
  }, categories = function(old) {
    # remove the Uncategorized category
    setdiff(old, 'Uncategorized')
  }, .keep_fields = c(
    'title', 'author', 'date', 'categories', 'tags', 'slug'
  ), .keep_empty = FALSE)
}
