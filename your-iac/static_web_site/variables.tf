variable "sites" {
  type = map(object({
    comment             = string
    default_root_object = string
    allowed_methods     = list(string)
    cached_methods      = list(string)
    default_ttl         = number
    max_ttl             = number
    locations           = list(string)
    aliases             = list(string)
    allow_addresses     = list(string)
  }))
}
