use Amnesia

defdatabase Database do
  deftable(
    Link,
    [:short_url, :long_url, :visits, :last_visited],
    type: :set,
    index: [:long_url]
  )
end
