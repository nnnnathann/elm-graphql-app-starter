### Full Stack Elm + Typescript

The idea behind this repo is to get some of the benefits of static types,
along with hassle-free RPC between server and client, while still maintaining
separation between API and client code.

Overall, the dev server (started with `pnpm dev` will run a few different watchers)

1. GraphQL Schema at `backend/src/graphql/v1.graphql` will be compiled (via @graphql-codegen) into a typescript type definition file whenever it changes
2. The typescript based GraphQL server process will restart on typescript changes via tsx
3. The `elm-gql` generated code in the web folder will re-generate on schema or query change, but wait a second for the graphql server to restart (it loads schema from the URL itself)
4. Vite will reload the assets and html changes for the web client
5. `elm-watch` will hot-reload the elm client code

#### Development Workflow

* Schema-First GraphQL + Codegen on both backend and frontend (start with the schema, then fill in the resolvers or queries)
* Typesafe, frontend code with Elm without writing decoders for server calls
* Typesafe(ish) backend code with Typescript
* Server code goes in "backend", browser code goes in "web"
* Multi-Process CLI management with `run-pty` (dashboard for concurrent processes, single terminal)

#### List of included libraries

* [pnpm](https://pnpm.io/) - fast, deterministic package manager
* [elm](https://elm-lang.org/) - frontend language
* [tailwindcss](https://tailwindcss.com/) - utility-first CSS framework
* [graphql-codegen](https://graphql-code-generator.com/) - generate typescript types from graphql schema
* [elm-gql](https://github.com/vendr/elm-gql)) - generate elm types from graphql schema
* [elm-animator](https://package.elm-lang.org/packages/mdgriffith/elm-animator/latest/) - animation library
* [elm-watch](https://github.com/lydell/elm-watch) - hot-reload elm code
