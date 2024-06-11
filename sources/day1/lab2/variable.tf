variable "string_exam" {
    type        = string
    description = "This is a string example."
    default     = "value"
}

variable "number_exam" {
    type        = number
    description = "This is a number example."
    default     = 0.43
    # sensitive   = true

    validation {
      condition = var.number_exam < 10
      error_message = "This value is less then 10."
    }
}

variable "bool_exam" {
    type        = bool
    description = "This is a boolean example."
    default     = false
}

variable "list_exam" {
    type        = list(string)
    description = "This is a list example."
    default     = [ "list1", "list2" ]
}

variable "tuple_exam" {
    type        = tuple([string,number])
    description = "This is a tuple example."
    default     = [ "test", 3.24 ]
}

variable "set_exam" {
    type        = set(string)
    description = "This is a set example."
    default     = [ "unique value" ]
}

variable "map_exam" {
    type        = map(string)
    description = "This is a map example."
    default = {
        "name" = "sejun"
    }
}

variable "object_exam" {
    type        = object({
        name      = string,
        address   = string,
        class     = number
    })
    description = "This is a object example."
    default = {
        name = "sejun",
        address = "seoul",
        class = 8
    } 
}

output "string_exam" {
    value = var.string_exam
}

output "number_exam" {
    value = var.number_exam
}

output "bool_exam" {
    value = var.bool_exam
}

output "list_exam" {
    value = var.list_exam
}

output "tuple_exam" {
    value = var.tuple_exam
}

output "set_exam" {
    value = var.set_exam
}

output "map_exam" {
    value = var.map_exam
}

output "object_exam" {
    value = var.object_exam
}