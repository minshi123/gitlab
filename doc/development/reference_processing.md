# Reference Processing

[GitLab Flavored Markdown](../user/markdown.md) includes the ability to process references to a range
of GitLab domain objects. This is implemented by two abstractions in the `Banzai` pipeline,
`ReferenceFilter`s and `ReferenceParsers`. This document serves to explain what
these are, how they are used, and how you would implement a new filter/parser
pair.

## Reference Filters

The first way that references are handled is by reference filters. These are
the tools that identify short-code and URI references from markup documents and
transform them into structured links to the resources they represent. For
example, the class [`Banzai::Filter::IssueReferenceFilter`][issue-ref-filter] is responsible for
handling references to issues, such as `gitlab-org/gitlab#123` and
`https://gitlab.com/gitlab-org/gitlab/issues/200048`.

All reference filters are instances of [`HTML::Pipeline::Filter`][html-pipeline-filter],
and inherit (often indirectly) from [`Banzai::Filter::ReferenceFilter`][banzai-ref-filter].

`HTML::Pipeline::Filter`s have a simple interface of `#call`, a void method that
mutates the current document. `ReferenceFilter` provides methods that make
defining suitable `#call` methods easier. Most reference filters however will
not inherit from either of these classes directly, but from
[`AbstractReferenceFilter`][abstr-ref-filter], which provides a higher-level
interface. A minimum implementation of `AbstractReferenceFilter` should define:

* `.reference_type`: The type of domain object. This is usually a keyword, and is used to set the `data-reference-type` attribute on the generated link, and is an important part of the interaction with `ReferenceParser`s (see below).
* `.object_class`: a reference to the class of the objects a filter refers to. This is used to:
    - find the regular expressions used to find references. This class should include [`Referable`][referable]
      and thus define two regular expressions: `.link_reference_pattern` and `.reference_pattern`, both of which
      should contain a named capture group named the value of `ReferenceFilter.object_sym`.
    - compute the `.object_name`
    - compute the `.object_sym` (the group name in the reference pattern)
* `.parse_symbol(string)`: parse the text value to an object identifier (`#to_i` by default)
* `#record_identifier(record)`: the inverse of `.parse_symbol` - transform a domain object to an identifier (`#id` by default)
* `#url_for_object(object, parent_object)`: generate the URL for a domain object
* `#find_object(parent_object, id)`: given the parent (usually a [`Project`][project]) and an identifier, find the object.

One can easily see that this implementation won't be very efficient, because we will need to call `#find_object` for each reference, which may require issuing a DB query for every reference. For this reason, most implementations will instead use an optimisation included in `AbstractReferenceFilter`:

* `AbstractReferenceFilter` provides a lazily initialized value `#records_per_parent`, which is a mapping from parent object to a collection of domain objects.

To use this mechanism, the implementing class must implement the optional method:

* `#parent_records(parent, set_of_identifiers)`, which should return an enumerable of domain objects.

This allows such classes to define `#find_object` (as [`IssuableReferenceFilter`][issuable-filter] does) as:

```ruby
def find_object(parent, iid)
  records_per_parent[parent][iid]
end
```

Which makes the number of queries linear in the number of projects.

## Reference Parsers

In a number of cases, as a performance optimisation, we render markdown to HTML
once, cache the result and then present it to users from the cached value. For
example this happens for notes, issue descriptions, and merge request
descriptions. A consequence of this is that a rendered document might refer to
a resource that some subsequent readers should not be able to see. For example,
I might create an issue, and refer to a confidential issue `#1234`, which I have
access to. This will be rendered in the cached HTML as a link to that
confidential issue, with data attributes containing its ID, the ID of the
project and other confidential data. A later reader, who has access to my issue
might not have permission to read issue `#1234`, and so we need to _redact_
these sensitive pieces of data. This is what `ReferenceParser` classes do.

A reference parser is linked to the object that it handles by the link advertising this relationship in the `data-reference-type` attribute (set by the reference filter). This is used by the [`ReferenceRedactor`][redactor]
to compute which nodes should be visible to users:

```ruby
def nodes_visible_to_user(nodes)
  per_type = Hash.new { |h, k| h[k] = [] }
  visible = Set.new

  nodes.each do |node|
    per_type[node.attr('data-reference-type')] << node
  end

  per_type.each do |type, nodes|
    parser = Banzai::ReferenceParser[type].new(context)

    visible.merge(parser.nodes_visible_to_user(user, nodes))
  end

  visible
end
```

The key part here is `Banzai::ReferenceParser[type]`, which is used to look up the correct reference parser for each type of domain object. This requires that each reference parser must be:

* Placed in the `Banzai::ReferenceParser` name-space.
* Implement the `.nodes_visible_to_user(user, nodes)` method

In practice, all reference parsers inherit from [`BaseParser`][base-parser], and are implemented by defining:

* `.reference_type`, which should equal `ReferenceFilter.reference_type`
* implementing one or more of:
    - `#nodes_visible_to_user(user, nodes)` for finest grain control
    - `#can_read_reference?` needed if `nodes_visible_to_user` is not overridden.
    - `#references_relation` an active record relation for objects by ID
    * `#nodes_user_can_reference(user, nodes)` to filter nodes directly

A failure to implement this class for each reference type means that the
application will raise exceptions during markdown processing.

[html-pipeline-filter]: https://www.rubydoc.info/github/jch/html-pipeline/v1.11.0/HTML/Pipeline/Filter
[banzai-ref-filter]: ../../lib/banzai/filter/reference_filter.rb
[issue-ref-filter]: ../../lib/banzai/filter/issue_reference_filter.rb
[abstr-ref-filter]: ../../lib/banzai/filter/abstract_reference_filter.rb
[project]: ../../app/models/project.rb
[issuable-filter]: ../../lib/banzai/filter/issuable_reference_filter.rb
[redactor]: ../../lib/banzai/reference_redactor.rb
[base-parser]: ../../lib/banzai/reference_parser/base_parser.rb
