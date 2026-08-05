import { defineCollection, z } from "astro:content";
import { glob } from "astro/loaders";

const blog = defineCollection({
  loader: glob({ pattern: "**/*.md", base: "./src/content/blog" }),
  schema: z.object({
    title: z.string(),
    date: z.coerce.date().optional(),
    dateLabel: z.string().optional(),
    tags: z.array(z.string()).default([]),
    summary: z.string(),
    draft: z.boolean().default(false),
    references: z.array(z.object({ label: z.string(), url: z.string() })).default([]),
  }),
});

const projects = defineCollection({
  loader: glob({ pattern: "**/*.md", base: "./src/content/projects" }),
  schema: z.object({
    title: z.string(),
    status: z.enum(["In Progress", "Complete", "Planned"]).default("Complete"),
    tags: z.array(z.string()).default([]),
    summary: z.string(),
    order: z.number().default(0),
    hasWriteup: z.boolean().default(true),
    externalNote: z.string().optional(),
  }),
});

export const collections = { blog, projects };
