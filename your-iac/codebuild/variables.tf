variable "repositories" {
  type = map(object({
    repository_name = string
    source_version  = string
    buildspec       = string
  }))
}