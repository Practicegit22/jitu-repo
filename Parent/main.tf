module "rg_name" {
  source = "../Child/rg_group"
# fegfefe
# wwwcw
# ewewed
# fsnknkf
# fkewfnwkfn
}
module "stg" {
  source     = "../Child/stg_group"
  depends_on = [module.rg_name]
}
