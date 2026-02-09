path "secret/data/demo/*" {
   capabilities = ["read"]
}

path "secret/metadata/demo/*" {
   capabilities = ["list", "read"]
}
