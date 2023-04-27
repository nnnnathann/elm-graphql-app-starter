import { createSchema, createYoga } from "graphql-yoga";
import { readFileSync } from "node:fs";
import { RequestListener, IncomingMessage } from "node:http";
import { resolvers } from "./resolvers";

interface Config<C, Req> {
  createContext: (req: Req) => Promise<C>;
  releaseContext: (context: C) => Promise<void>;
  schemaFile: string;
}

export function createMiddleware<
  C extends Record<string, any>,
  Req extends IncomingMessage
>(config: Config<C, Req>): RequestListener {
  const { schemaFile, createContext, releaseContext } = config;
  const yoga = createYoga({
    schema: createSchema({
      typeDefs: readFileSync(schemaFile, {
        encoding: "utf-8",
      }),
      resolvers,
    }),
  });

  return async (req, res) => {
    const ctx = await createContext(req as Req);
    const response = await yoga(req, res, ctx);
    await releaseContext(ctx);
    return response;
  };
}
