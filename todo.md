### refactor
* refactor stats / calc outside of FileReporter.  that way NetworkReporter or
  other unthought of reporters can use the same set of events
* thread now through everything
* utils.split -> vim.split

### Motions
* <number>C-d/u shouldn't exist
* <number>A
* vk and vj show up.  v needs to only be i/a operations
* name C-d/u instead of code units
* gU/u
* replace?

### Testing
* how to do more integration styled tests?  what should i test?
