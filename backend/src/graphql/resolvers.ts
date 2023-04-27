import { DateTimeResolver } from "graphql-scalars";
import { Resolvers } from "./v1.gen";

export interface Context {}

export const resolvers: Resolvers<Context> = {
  DateTime: DateTimeResolver,
  Query: {
    message: async () => {
      return {
        text: "Hello World!",
        requestedAt: new Date(),
      };
    },
  },
  Message: {
    text: defaultResolver("text"),
    requestedAt: defaultResolver("requestedAt"),
  },
};

function defaultResolver<T extends Record<string, unknown>, K extends keyof T>(
  key: K
): (parent: T) => T[K] {
  return (parent) => parent[key];
}
