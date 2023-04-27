import express, { Request } from "express";
import { join } from "node:path";

import { type Context } from "../graphql/resolvers";
import { createMiddleware } from "../graphql/createMiddleware";

import { port, env, staticFiles, schemaFile } from "./_config";

// app connections, configuration, etc
const createContext = async (_req: Request): Promise<Context> => {
  return {};
};

const releaseContext = async (context: Context): Promise<void> => {};

const app = express();

const graphql = createMiddleware({
  schemaFile,
  createContext,
  releaseContext,
});

const server = app.use("/graphql", graphql);

if (env === "production") {
  console.log(`serving static files from: ${staticFiles}`);
  server.use(express.static(staticFiles));
  server.get("*", (req, res) => {
    res.sendFile(join(staticFiles, "index.html"));
  });
}

server.listen(port, () => {
  console.info(`server is running on http://localhost:${port}`);
});
