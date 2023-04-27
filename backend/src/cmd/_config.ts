import { config } from "dotenv-flow";
import { dirname, join } from "node:path";

config({ default_node_env: "development", path: dirname(__dirname) });

export const port = process.env.PORT || 4000;
export const env = process.env.NODE_ENV || "development";
export const staticFiles =
  process.env.STATIC_FILES_DIR ||
  join(__dirname, "..", "..", "..", "web", "dist");
export const schemaFile = join(__dirname, "..", "graphql", "v1.graphql");
