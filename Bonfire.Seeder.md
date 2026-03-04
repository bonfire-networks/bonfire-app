# `Bonfire.Seeder`
[🔗](https://github.com/bonfire-networks/bonfire-app/blob/main/lib/bonfire/seeder.ex#L1)

A way to have data seeds that work similarly to migrations.

To generate a new seed: `mix phil_columns.gen.seed my_seed_name` will create a new module in `priv/repo/seeds`

To actually insert the seeds into your app, if that's not configured to be done automatically in your mix aliases, run `mix phil_columns.seed`

To roll-back: `mix phil_columns.rollback`

---

*Consult [api-reference.md](api-reference.md) for complete listing*
