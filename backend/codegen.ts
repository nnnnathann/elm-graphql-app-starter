import type { CodegenConfig } from "@graphql-codegen/cli";

const config: CodegenConfig = {
  overwrite: true,
  schema: "./src/graphql/v1.graphql",
  generates: {
    "./src/graphql/v1.gen.ts": {
      plugins: ["typescript", "typescript-resolvers"],
      config: {
        avoidOptionals: true,
        immutableTypes: true,
      },
    },
  },
};

export default config;
