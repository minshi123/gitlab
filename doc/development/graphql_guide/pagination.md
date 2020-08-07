# GraphQL Pagination Implementation

All GraphQL defaults to using keyset pagination (`Gitlab::Graphql::Pagination::Keyset::Connection`) for the reasons above.  There are some cases where we have to use offset pagination (OffsetActiveRecordRelationConnection), such as when sorting by label priority in issues, because the sorting is too complex.

If the frontend can support non-page style pagination in all cases, then on the backend we can choose the best performing method to support that.  If we have to use page-style, then we can only use the slower, more error prone type on the backend.

## Offset Pagination

This is the traditional, page by page pagination that is most common, and was used across most of GitLab.  It means when I click on "Page 100", we send `100` to the backend.  It knows that each page has 20 items, so `20 * 100 = 2000`, and it queries the database by offsetting 2000 records, and pulls the next 20.

```
page number * page size = where to find my records
```

There are a couple problems with this:

1. Performance. When we query for page 100 (which gives an offset of 2000), then the database has to scan through the table to that specific offset, and then picks up the next 20 records.  As the offset increases, the performance degrades quickly, like in http://allyouneedisbackend.com/blog/2017/09/24/the-sql-i-love-part-1-scanning-large-table/

2. Data stability.  When you get the 20 items for page 100 (at offset 2000), it will show those 20 items.  If someone then deletes or adds records in page 100 or before, then the items at offset 2000 are a different set of items.  You can even get into a situation where when paginating, you could "skip" over items, because it keeps changing (discussed in https://coderwall.com/p/lkcaag/pagination-you-re-probably-doing-it-wrong)

But it's very easy to program.  Most of our pagination uses it, and the API does (except I think in some experimental version that use keyset pagination).

## Keyset Pagination

Given any specific record, if you know how to calculate what comes after it, you can query the DB for those specific records.  For example, a list of issues sorted by creation date.  If I know the first item on a page has a specific date (say Jan 1), I can ask for all records that were created after that date and take the first 20.  It no longer matters if many are deleted or added - I always ask for the ones after that date, and will get the correct items.

But there is no way to know that the issue created on Jan 1 is on page 20 or page 100.

1. Performance is much better

1. Data stability - you're not going to miss records because of deletion/insertions

1. Best way to do infinite scrolling

1. But much more difficult to program.  Easy for updated_at and sort_order, complicated (or impossible) for complex sorting scenarios.

## External Pagination

