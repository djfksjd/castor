import { Router } from "express";
import { db } from "./db";

export const router = Router();

// Public status page: anyone may read component health. No account data here.
router.get("/status/components/:id", async (req, res) => {
  const { rows } = await db.query(
    "select id, name, state, updated_at from status_components where id = $1",
    [req.params.id],
  );
  if (rows.length === 0) return res.status(404).end();
  res.set("Cache-Control", "public, max-age=30").json(rows[0]);
});
