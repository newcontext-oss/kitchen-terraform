resource "local_file" "file_1" {
    content = "test"
    filename = "${path.module}/file_1"
}

resource "local_file" "file_2" {
    content = "test"
    filename = "${path.module}/file_2"
}