# Needle.ULID

[![hex.pm](https://img.shields.io/hexpm/v/needle_ulid)](https://hex.pm/packages/needle_ulid)
[hexdocs](https://hexdocs.pm/needle_ulid)

A ULID datatype and some postgres support for ULID operations (`min` and `max` functions and aggregates)

Originally forked from
[ecto-ulid](https://github.com/TheRealReal/ecto-ulid) but the internals have been replaced with a dependency on [ex_ulid](https://github.com/omgnetwork/ex_ulid) 

## Installation

```elixir
{:needle_ulid, git: "https://github.com/bonfire-networks/needle_ulid", branch: "main"}
```

## Copyright and License

Copyright (c) 2021 Bonfire contributors.
Copyright (c) 2018 The RealReal, Inc.
Copyright (c) 2020 needle_ulid contributors.

Licensed under the terms of the MIT License.

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
